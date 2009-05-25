# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oauth-active-resource}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Johannes Wagener"]
  s.date = %q{2009-05-25}
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
    "lib/oauth_active_resource/fake_oauth_access_token.rb",
    "lib/oauth_active_resource/resource.rb",
    "lib/oauth_active_resource/unique_resource_array.rb",
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
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<activeresource>, [">= 0"])
      s.add_runtime_dependency(%q<multipart>, [">= 0"])
    else
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<activeresource>, [">= 0"])
      s.add_dependency(%q<multipart>, [">= 0"])
    end
  else
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<activeresource>, [">= 0"])
    s.add_dependency(%q<multipart>, [">= 0"])
  end
end
