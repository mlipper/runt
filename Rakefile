# Rakefile for runt        -*- ruby -*-
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/contrib/sshpublisher'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'

# Build Settings
PKG_VERSION = "0.0.4"

# Files to be included in Runt distribution
PKG_FILES = FileList[
  'setup.rb',
  '[A-Z]*',
  'lib/**/*.rb',
  'test/**/*.rb',
  'doc/**/*',
  'site/**/*'
].exclude("*.ses")

# build directory
TARGET_DIR = "target"

# Targets
task :default => [:test]
task :clobber => [:clobber_build_dir]

# Make the build directory
directory TARGET_DIR

desc "Clobber the entire build directory."
task :clobber_build_dir do |t|
    puts "It's clobberin' time! (hello from task #{t.name})"
    CLOBBER.include(TARGET_DIR)
end

Rake::RDocTask.new do |rd|
  rd.rdoc_dir="#{TARGET_DIR}/doc"
  rd.options << "-S"
  rd.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc','[A-Z]*')
  rd.rdoc_files.exclude('test/*.rb','[A-Z]*.ses','Rakefile')
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = 'test/alltests.rb'
  t.verbose = true
end

Rake::PackageTask.new("runt", PKG_VERSION) do |p|
  p.package_dir="#{TARGET_DIR}/#{p.package_dir}"
  p.need_tar = true
  p.need_zip = true
  p.package_files.include(PKG_FILES)
end

desc "Copy html files for the Runt website to the build directory."
file "copy_site" => TARGET_DIR
file "copy_site" do
    cp_r Dir["site/*.{html,gif,png}"], TARGET_DIR
end

desc "Publish the Documentation to RubyForge."
task :publish => [:rdoc,:copy_site,:clobber_package] do |t|
  publisher = Rake::CompositePublisher.new
	publisher.add Rake::SshDirPublisher.new("mlipper@rubyforge.org", "/var/www/gforge-projects/runt",TARGET_DIR)
  publisher.upload
end

desc "Publish the Documentation to the build dir."
task :test_publish => [:rerdoc,:copy_site,:clobber_package] do |t|
  puts "YAY! We've tested publish! YAY!"
end