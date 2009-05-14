# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oauth-active-resource}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["jwagener"]
  s.date = %q{2009-05-13}
  s.email = %q{johannes@wagener.cc}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/oauth_active_resource.rb",
    "lib/oauth_active_resource/connection.rb",
    "lib/oauth_active_resource/resource.rb",
    "lib/oauth_active_resource/collection.rb",
    "spec/oauth_active_resource_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jwagener/oauth-active-resource}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}
  s.test_files = [
    "spec/oauth_active_resource_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
