# Rakefile for runt        -*- ruby -*-

begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/contrib/sshpublisher'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'

#####################################################################
# Constants
#####################################################################

# Build Settings
PKG_VERSION = "0.6.0"

# Files to be included in Runt distribution
PKG_FILES = FileList[
  'setup.rb',
  '[A-Z]*',
  'lib/**/*.rb',
  'test/**/*.rb',
  'examples/**/*.rb',
  'doc/**/*',
  'site/**/*'
].exclude("*.ses")

if(RUBY_PLATFORM =~ /win32/i)
  PKG_EXEC_TAR = false
else
  PKG_EXEC_TAR = true 
end
  
# build directory
TARGET_DIR = "target"

#####################################################################
# Targets
#####################################################################

task :default => [:test]
task :clobber => [:clobber_build_dir]

# Make the build directory
directory TARGET_DIR

# Calling this task directly doesn't work?
desc "Clobber the entire build directory."
task :clobber_build_dir do |t|
    CLOBBER.include(TARGET_DIR)
end

Rake::RDocTask.new do |rd|
  rd.rdoc_dir="#{TARGET_DIR}/doc"
  rd.options << "-S"
  rd.rdoc_files.include('lib/*','doc/*.rdoc','README','CHANGES','TODO','LICENSE.txt')
end

Rake::TestTask.new do |t|
  t.libs << "test" << "examples"
  t.pattern = '**/*test.rb'
  t.verbose = false	
end

desc "Copy html files for the Runt website to the build directory."
file "copy_site" => TARGET_DIR
file "copy_site" do
    cp_r Dir["site/*.{html,gif,png,css}"], TARGET_DIR
end

desc "Publish the Documentation to RubyForge."
task :publish => [:rdoc,:copy_site,:clobber_package] do |t|
  publisher = Rake::CompositePublisher.new
        publisher.add Rake::SshDirPublisher.new("mlipper@rubyforge.org", "/var/www/gforge-projects/runt",TARGET_DIR)
  publisher.upload
end

desc "Publish the Documentation to the build dir."
task :test_publish => [:rdoc,:copy_site,:clobber_package] do |t|
  puts "YAY! We've tested publish! YAY!"
end


if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|
    s.platform = Gem::Platform::RUBY
    s.summary = "Ruby Temporal Expressions."
    s.name = 'runt'
    s.version = PKG_VERSION
    s.requirements << 'none'
    s.require_path = 'lib'
    s.autorequire = 'runt'
    s.files = PKG_FILES.to_a
    s.author = 'Matthew Lipper'
    s.email = 'mlipper@gmail.com'
    s.homepage = 'http://runt.rubyforge.org'
    s.has_rdoc = true
    s.rdoc_options += %w{--main README --title Runt}
    s.extra_rdoc_files = FileList["README","CHANGES","TODO","LICENSE.txt","doc/*.rdoc"]    
    s.test_files = Dir['**/*test.rb']
    s.rubyforge_project = 'runt'
    s.description = <<EOF
Runt is a Ruby version of temporal patterns by
Martin Fowler. Runt provides an API for scheduling
 recurring events using set-like semantics. 
EOF
  end
  
  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = PKG_EXEC_TAR
  end
end
