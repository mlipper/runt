Gem::Specification.new do |s|
  s.name = %q{runt}
  s.version = "0.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Lipper"]
  s.date = %q{2008-12-11}
  s.description = %q{}
  s.email = ["mlipper@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt", "Rakefile", "TODO", "examples/payment_report.rb", "examples/payment_reporttest.rb", "examples/reminder.rb", "examples/schedule_tutorial.rb", "examples/schedule_tutorialtest.rb", "lib/runt.rb", "lib/runt/daterange.rb", "lib/runt/dprecision.rb", "lib/runt/expressionbuilder.rb", "lib/runt/pdate.rb", "lib/runt/schedule.rb", "lib/runt/sugar.rb", "lib/runt/temporalexpression.rb", "runt.gemspec", "setup.rb", "site/blue-robot3.css", "site/dcl-small.gif", "site/index.html", "site/logohover.png", "site/runt-logo.gif", "site/runt-logo.psd", "test/aftertetest.rb", "test/baseexpressiontest.rb", "test/beforetetest.rb", "test/collectiontest.rb", "test/combinedexpressionstest.rb", "test/daterangetest.rb", "test/dayintervaltetest.rb", "test/difftest.rb", "test/dimonthtest.rb", "test/diweektest.rb", "test/dprecisiontest.rb", "test/everytetest.rb", "test/expressionbuildertest.rb", "test/icalendartest.rb", "test/intersecttest.rb", "test/pdatetest.rb", "test/redaytest.rb", "test/remonthtest.rb", "test/reweektest.rb", "test/reyeartest.rb", "test/rspectest.rb", "test/runttest.rb", "test/scheduletest.rb", "test/spectest.rb", "test/sugartest.rb", "test/temporalexpressiontest.rb", "test/uniontest.rb", "test/wimonthtest.rb", "test/yeartetest.rb"]
  s.has_rdoc = true
  s.homepage = %q{Runt is a Ruby[http://www.ruby-lang.org/en/] implementation of select Martin Fowler  patterns[http://www.martinfowler.com/articles].}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{Runt}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
