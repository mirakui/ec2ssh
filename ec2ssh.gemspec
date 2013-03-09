# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ec2ssh/version"

Gem::Specification.new do |s|
  s.name        = "ec2ssh"
  s.version     = Ec2ssh::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["mirakui"]
  s.email       = ["mirakui@tsuyabu.in"]
  s.homepage    = "http://github.com/mirakui/ec2ssh"
  s.summary     = %q{A ssh_config manager for AWS EC2}
  s.description = %q{A ssh_config manager for AWS EC2}

  s.rubyforge_project = "ec2ssh"
  s.add_dependency "thor", "~> 0.14.6"
  s.add_dependency "highline", "~> 1.6"
  s.add_dependency "ktheory-right_aws", "~> 2.0.3"
  s.add_dependency "pit", "~> 0.0.7"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
