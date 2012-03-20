# Author:: Pascal Morillon (<pascal.morillon@irisa.fr>)
# Date:: Wed Feb 29 15:07:38 +0100 2012
#

require 'mixlib/cli'
require 'oar/scripting/constants'
require 'oar/scripting/config'

class OAR::Scripting::Application
  include Mixlib::CLI

  def initialize
    super

    trap("TERM") do
      OAR::Scripting::Application.fatal!("SIGTERM received, stopping", 1)
    end

    trap("INT") do
      OAR::Scripting::Application.fatal!("SIGINT received, stopping", 2)
    end
  end # Definition:: initialize

  def run
    # use parse_options from Mixlib
    parse_options

    # Run application
    run_application
  end # Definition:: run

  def run_application
    raise "#{self.to_s}: you must override run_application"
  end # Definition:: run_application

  class << self
    def fatal!(msg, err = -1)
      STDERR.puts("FATAL: #{msg}")
      Process.exit err
    end # Definition:: fatal!(msg, err = -1)

    def exit!(msg, err = -1)
      Process.exit err
    end # Definition:: exit!(msg, err = -1)
  end

end # class:: OAR::Scripting::Application
