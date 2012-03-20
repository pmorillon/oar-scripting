# Author:: Pascal Morillon (<pascal.morillon@irisa.fr>)
# Date:: Wed Feb 29 15:31:57 +0100 2012
#

class OAR::Scripting::Config

  @@config = Hash.new

  @@config[:output]             = File.expand_path(ENV["PWD"])
  @@config[:oar_conf_path]      = "/etc/oar"
  @@config[:prologue_d_path]    = File.join @@config[:oar_conf_path], "prologue.d"
  @@config[:epilogue_d_path]    = File.join @@config[:oar_conf_path], "epilogue.d"
  @@config[:default_step_order] = 50
  @@config[:log_path]           = "/var/log/oar"

  def self.[](opt)
    @@config[opt.to_sym]
  end # def:: self.[](opt)

  def self.[]=(opt, value)
    @@config[opt.to_sym] = value
  end # def:: self.[]=(opt, value)

  def self.method_missing(method_symbol, *args)
    @@config[method_symbol] = args[0]
    @@config[method_symbol]
  end # def:: self.method_missing(method_symbol), *args)

  def self.inspect
    @@config
  end # def:: self.inspect

end # class:: OAR::Scripting::Config
