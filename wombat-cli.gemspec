# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "wombat/version"
require "English"

Gem::Specification.new do |gem|
  gem.name          = "wombat-cli"
  gem.version       = Wombat::VERSION
  gem.license       = "Apache-2.0"
  gem.authors       = ["Andre Elizondo", "Seth Thomas"]
  gem.email         = ["sthomas@chef.io"]
  gem.description   = "With a tough barrel-like body, short powerful legs, " \
                      "and long flat claws, the wombat walks with a shuffling " \
                      "gait but is extremely adept at tunneling"
  gem.summary       = "Make Chef demos delightful with Wombat"
  gem.homepage      = "http://kitchen.ci"

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.bindir = "bin"
  gem.executables   = %w[wombat]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.4.1"

  gem.add_dependency 'rake', '~> 11.2'
  gem.add_dependency 'berkshelf', '~> 5.0'
  gem.add_dependency 'net-ssh', '~> 3.2'
  gem.add_dependency 'parallel', '~> 1.9'
  gem.add_dependency 'aws-sdk', '~> 2.5'
  gem.add_dependency 'azure_mgmt_resources', '= 0.14.0'
  gem.add_dependency 'azure_mgmt_storage', '= 0.14.0'
  gem.add_dependency 'azure_mgmt_network', '= 0.14.0'
  gem.add_dependency 'azure-storage', '~> 0.14.0.preview'
  gem.add_dependency 'github_changelog_generator'
end
