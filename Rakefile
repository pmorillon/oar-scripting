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

desc "Publish in g5kgems repository"
task :publish => [:gem] do
  sh "scp pkg/#{OAR::Scripting::GEM}-#{OAR::Scripting::VERSION}.gem git.grid5000.fr:/tmp"
  sh "ssh git.grid5000.fr sudo mv /tmp/#{OAR::Scripting::GEM}-#{OAR::Scripting::VERSION}.gem /var/www/gems.grid5000.fr/htdocs/gems"
  sh "ssh git.grid5000.fr sudo gem generate_index --directory /var/www/gems.grid5000.fr/htdocs/"
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--any', '--extra', '--opts']
end

