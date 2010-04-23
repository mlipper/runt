require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "runt"

    gem.authors = ["Matthew Lipper"]
    gem.summary = %q{Runt is a Ruby[http://www.ruby-lang.org/en/] implementation of select Martin Fowler  patterns[http://www.martinfowler.com/articles].}
    gem.description = %Q{
Runt is an implementation of select temporal patterns by Martin Fowler in the super-fantastic Ruby language. Runt provides:

  * ability to define recurring events using simple, set-like expressions
  * an interfaced-based API for creating schedules for arbitrary events/objects
  * precisioned date types using Time Points
  * date Ranges
  * everlasting peace and/or eternal life
    }
    gem.email = ["mlipper@gmail.com"]
    gem.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt"]
    gem.files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt", "Rakefile", "TODO", "examples/payment_report.rb", "examples/payment_reporttest.rb", "examples/reminder.rb", "examples/schedule_tutorial.rb", "examples/schedule_tutorialtest.rb", "lib/runt.rb", "lib/runt/daterange.rb", "lib/runt/dprecision.rb", "lib/runt/expressionbuilder.rb", "lib/runt/pdate.rb", "lib/runt/schedule.rb", "lib/runt/sugar.rb", "lib/runt/temporalexpression.rb", "runt.gemspec", "setup.rb", "site/blue-robot3.css", "site/dcl-small.gif", "site/index.html", "site/logohover.png", "site/runt-logo.gif", "site/runt-logo.psd", "test/aftertetest.rb", "test/baseexpressiontest.rb", "test/beforetetest.rb", "test/collectiontest.rb", "test/combinedexpressionstest.rb", "test/daterangetest.rb", "test/dayintervaltetest.rb", "test/difftest.rb", "test/dimonthtest.rb", "test/diweektest.rb", "test/dprecisiontest.rb", "test/everytetest.rb", "test/expressionbuildertest.rb", "test/icalendartest.rb", "test/intersecttest.rb", "test/pdatetest.rb", "test/redaytest.rb", "test/remonthtest.rb", "test/reweektest.rb", "test/reyeartest.rb", "test/temporalrangetest.rb", "test/runttest.rb", "test/scheduletest.rb", "test/temporaldatetest.rb", "test/sugartest.rb", "test/temporalexpressiontest.rb", "test/uniontest.rb", "test/wimonthtest.rb", "test/yeartetest.rb"]
    gem.has_rdoc = true
    gem.homepage = %q{http://github.com/paydici/runt}
    gem.rdoc_options = ["--main", "README.txt"]
    gem.require_paths = ["lib"]
    gem.rubyforge_project = %q{Runt}
    gem.rubygems_version = %q{1.3.1}
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/*test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/*test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "runt #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
