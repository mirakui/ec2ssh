# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ec2ssh/version"

Gem::Specification.new do |s|
  s.name        = "ec2ssh"
  s.version     = Ec2ssh::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Issei Naruta"]
  s.email       = ["mimitako@gmail.com"]
  s.homepage    = "http://github.com/mirakui/ec2ssh"
  s.license     = "MIT"
  s.summary     = %q{A ssh_config manager for AWS EC2}
  s.description = %q{ec2ssh is a ssh_config manager for AWS EC2}
  s.required_ruby_version = ">= 2.6.0"

  s.add_dependency "thor", ">= 1.2", "< 2.0"
  s.add_dependency "highline", ">= 1.6", "< 3.0"
  s.add_dependency "aws-sdk-core", "~> 3"
  s.add_dependency "aws-sdk-ec2", "~> 1"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
