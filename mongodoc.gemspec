# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongodoc}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Les Hill"]
  s.date = %q{2009-10-01}
  s.description = %q{ODM for MongoDB}
  s.email = %q{leshill@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "data/.gitignore",
     "lib/mongodoc.rb",
     "lib/mongodoc/base.rb",
     "lib/mongodoc/connection.rb",
     "lib/mongodoc/exceptions.rb",
     "lib/mongodoc/ext/array.rb",
     "lib/mongodoc/ext/boolean_class.rb",
     "lib/mongodoc/ext/date.rb",
     "lib/mongodoc/ext/date_time.rb",
     "lib/mongodoc/ext/hash.rb",
     "lib/mongodoc/ext/nil_class.rb",
     "lib/mongodoc/ext/numeric.rb",
     "lib/mongodoc/ext/object.rb",
     "lib/mongodoc/ext/regexp.rb",
     "lib/mongodoc/ext/string.rb",
     "lib/mongodoc/ext/symbol.rb",
     "lib/mongodoc/ext/time.rb",
     "lib/mongodoc/json.rb",
     "mongodoc.gemspec",
     "script/console",
     "spec/base_spec.rb",
     "spec/connection_spec.rb",
     "spec/json_matchers.rb",
     "spec/json_spec.rb",
     "spec/spec_helper.rb",
     "spec/test_classes.rb",
     "spec/test_documents.rb"
  ]
  s.homepage = %q{http://github.com/leshill/mongodoc}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{ODM for MongoDB}
  s.test_files = [
    "spec/base_spec.rb",
     "spec/connection_spec.rb",
     "spec/json_matchers.rb",
     "spec/json_spec.rb",
     "spec/spec_helper.rb",
     "spec/test_classes.rb",
     "spec/test_documents.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end