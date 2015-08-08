require 'aws-sdk-v1'

module Ec2ssh
  class Ec2Instances
    attr_reader :ec2s, :aws_keys

    def initialize(aws_keys, regions)
      @aws_keys = aws_keys
      @regions = regions
    end

    def make_ec2s
      AWS.start_memoizing
      _ec2s = {}
      aws_keys.each do |name, key|
        _ec2s[name] = {}
        @regions.each do |region|
          options = key.merge ec2_region: region
          _ec2s[name][region] = AWS::EC2.new options
        end
      end
      _ec2s
    end

    def ec2s
      @ec2s ||= make_ec2s
    end

    def instances(key_name)
      @regions.map {|region|
        ec2s[key_name][region].instances.
          filter('instance-state-name', 'running').
          to_a.
          sort_by {|ins| ins.tags['Name'].to_s }
      }.flatten
    end

    def self.expand_profile_name_to_credential(profile_name)
      provider = AWS::Core::CredentialProviders::SharedCredentialFileProvider.new(profile_name: profile_name)
      provider.credentials
    end
  end
end
