# Author:: Pascal Morillon (<pascal.morillon@irisa.fr>)
# Date:: Mon Feb 27 13:42:10 +0100 2012
#

require 'oar/scripting'
require 'json'

class OAR::Scripting::Script

  def self.init(type)
    @@resources = []
    @@start_at = Time.new
    @@job = getargs
    @@type ||= type
    @@logger ||= Logger.new(File.join(OAR::Scripting::Config[:log_path], "#{@@job[:id]}-#{@@type.to_s}-#{@@job[:user]}.log"))
    @@logger.info "[begin]"
    @@stats = { "job" => @@job, "steps" => [] }
    @@steps = []
    @@disabled_steps = []
  end # def:: initialize

  def self.load_steps
    dir = OAR::Scripting::Config["#{@@type}_d_path".to_sym]
    if File.exist? dir
      Dir[File.join dir, "*.rb"].each do |file|
        load file
      end
    end
  end # def:: self.load_scripts

  def self.getargs
    job = { :id         => ARGV[0],
            :user       => ARGV[1],
            :nodesfile  => ARGV[2] }
    begin
      File.open(job[:nodesfile]).each { |line| @@resources << line.chomp }
    rescue
      # let @@resources empty
    end
    job[:resources_count] = @@resources.length
    job[:host_count] = @@resources.uniq.length
    job
  end # def:: getargs

  def self.logger
    @@logger
  end # def:: logger

  def self.type
    @@type
  end # def:: type

  def self.job
    @@job
  end # def:: self.job

  def self.steps
    @@steps
  end # def:: self.steps

  def self.oarstat
    @@oarstat ||= JSON.parse(%x[oarstat -f -j @@job[:id] -J])[@@job[:id]]
  end # def:: self.oarstat

  def self.execute
    @@steps.sort! { |a,b| a[:order] <=> b[:order] }
    @@steps.each do |step|
      @@logger.info "[begin_step]#{step[:name]}"
      start = Time.new
      begin
        step[:proc].call
      rescue Exception => e
        @@logger.debug "[Error] step #{step[:name]} failed (describe in #{step[:file]}"
        @@logger.debug e.message
        @@logger.debug e.backtrace
        raise unless step[:continue]
      end
      @@logger.info "[end_step]#{step[:name]}"
      @@stats["steps"] << { "name" => step[:name].to_s, "duration" => (Time.now - start), "order" => step[:order] }
    end
    @@logger.info "[end]"
    @@stats["duration"] = Time.now - @@start_at
    @@logger.info "[stats]" + @@stats.to_json
  end # def:: execute

  def self.stats
    @@stats
  end # def:: self.stats

  def self.disabled_steps
    @@disabled_steps
  end # def:: self.disabled_steps

  def self.disable_steps(steps)
    steps = [steps] unless steps.class == Array
    @@disabled_steps += steps
    steps2disable = Script.steps.select { |step| steps.include? step[:name] }
    Script.logger.info "[disable_loaded_steps]#{steps2disable.inspect}"
    @@steps -= steps2disable
  end # def:: self.disable_steps(steps)

end # class:: OAR::Scripting::Script

