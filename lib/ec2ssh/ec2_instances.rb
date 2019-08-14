require 'aws-sdk-v1'

module Ec2ssh
  class Ec2Instances
    attr_reader :ec2s, :aws_keys

    def initialize(aws_keys, container)
      @aws_keys = aws_keys
      @container = container
      @regions = @container.regions
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

        instances = ec2s[key_name][region].instances
        if @container.filters
          @container.filters.each do |filter|
            instances.filter(filter['key'], filter['value'])
          end
        else
          instances.filter('instance-state-name', 'running')
        end
        instances.to_a.sort_by {|ins| ins.tags['Name'].to_s }
      }.flatten
    end

    def self.expand_profile_name_to_credential(profile_name)
      provider = AWS::Core::CredentialProviders::SharedCredentialFileProvider.new(profile_name: profile_name)
      provider.credentials
    end
  end
end
