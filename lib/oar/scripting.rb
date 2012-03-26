# Author:: Pascal Morillon (<pascal.morillon@irisa.fr>)
# Date:: Wed Feb 22 17:36:57 +0100 2012
#

require 'oar/scripting/constants'
require 'oar/scripting/script'
require 'oar/scripting/config'
require 'logger'
require 'backports'

module OAR
  module Scripting

    def sh(cmd, options = {})
      options = options.symbolize_keys
      options[:stderr] ||= true
      cmd += options[:stderr] == false ? " 2>/dev/null" : " 2>&1"
      result = ""
      Script.logger.info "[command] " + cmd
      IO.popen(cmd) do |io|
        result = io.read.strip
        Script.logger.debug "[result]\n" + result
      end
      $? != 0 ? Script.logger.debug("[command_failure]") : Script.logger.debug("[command_success]")
      result if options[:return]
    end # def:: sh(cmd)

    def step(name, *args, &block)
      step = Hash.new
      raise(ArgumentError, "Step name must be a symbol") unless name.kind_of?(Symbol)
      step = args.first unless args.first.nil?
      step[:name] = name
      step[:order] ||= OAR::Scripting::Config[:default_step_order]
      step[:continue] ||= true
      step[:proc] = block
      pre_step = Script.steps.select { |a| a[:name] == name }
      unless pre_step.empty?
        if step[:overwrite]
          Script.logger.info "[step_overwrites] replace #{pre_step.first.inspect} by #{step.inspect}"
          Script.steps.delete pre_step.first
          Script.steps << step
        else
          Script.logger.info "[step_already_defined] skip #{step.inspect}"
        end
      else
        Script.steps << step
      end
    end # def:: step(name)

    def job
      Script.job
    end # def:: job

    def oarstat
      Script.oarstat
    end # def:: oarstat

  end # module:: Scripting
end # module:: OAR

