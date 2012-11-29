# Author:: Pascal Morillon (<pascal.morillon@irisa.fr>)
# Date:: Wed Feb 22 17:42:52 +0100 2012
#

$:.unshift File.expand_path('../lib/', __FILE__)

require 'rubygems'
require 'rubygems/package_task'
require 'oar/scripting/constants'
require 'yard'

gemspec = Gem::Specification.load(
  File.expand_path("../oar-scripting.gemspec", __FILE__)
)

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc "Show version"
task :version do
  puts OAR::Scripting::VERSION
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--any', '--extra', '--opts']
end

