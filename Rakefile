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
PKG_VERSION = "0.0.3"

# Files to be included in Runt distribution
PKG_FILES = FileList[
  'setup.rb',
  '[A-Z]*',
  'bin/**/*',
  'lib/**/*.rb',
  'test/**/*.rb',
  'doc/**/*',
  'site/**/*'
].exclude("*.ses")

# Directory for temporary artifacts produced by this script
TARGET_DIR = "target"

# Targets
task :default => [:test]

Rake::RDocTask.new do |rd|
  #~ rd.rdoc_dir = 'html'
  rd.rdoc_dir="#{TARGET_DIR}/doc"
  rd.options << "-S"
  rd.rdoc_files.exclude('test/*.rb')
  rd.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
  rd.rdoc_files.include('README','LICENSE.txt')
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

desc "Publish the Documentation to RubyForge."
task :publish => [:rerdoc, :rdoc] do |t|
  publisher = Rake::CompositePublisher.new
  #~ publisher.add Rake::RubyForgePublisher.new('runt', 'mlipper')
	publisher.add Rake::SshDirPublisher.new("mlipper@rubyforge.org", "/var/www/gforge-projects/runt","site")
  publisher.upload
end
