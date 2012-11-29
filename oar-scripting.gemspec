# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib/', __FILE__)

require 'oar/scripting/constants'

Gem::Specification.new do |s|
  s.name              = OAR::Scripting::GEM
  s.version           = OAR::Scripting::VERSION
  s.platform          = Gem::Platform::RUBY
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.rdoc"]
  s.summary           = "OAR helper library for prologue/epilogue scripting"
  s.description       = s.summary
  s.author            = "Pascal Morillon"
  s.email             = "pascal.morillon@irisa.fr"
  s.homepage          = "https://github.com/pmorillon/oar-scripting"

  s.add_dependency "mixlib-cli", ">=1.1.0"
  s.add_dependency "rubyvis", ">=0.5.1"
  s.add_dependency "json", ">=1.6.5"

  s.add_development_dependency "rake", "0.8.7"
  s.add_development_dependency "yard", "~>0.8.2.1"

  s.bindir            = "bin"
  s.executables       = %w( oar-scripting-graph )
  s.require_path      = ["lib"]
  s.files             = %w( README.rdoc ) + Dir.glob("lib/**/*")
end
