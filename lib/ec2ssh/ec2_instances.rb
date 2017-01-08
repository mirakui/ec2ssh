require 'aws-sdk'

module Ec2ssh
  class Ec2Instances
    attr_reader :ec2s

    def initialize(regions, profiles)
      @regions = regions
      @profiles = profiles
    end

    def make_ec2s
      _ec2s = {}
      @profiles.each do |profile|
        options = { profile: profile }
        _ec2s[profile] = {}
        @regions.each do |region|
          options.merge! region: region
          _ec2s[profile][region] = Aws::EC2::Resource.new options
        end
      end
      _ec2s
    end

    def ec2s
      @ec2s ||= make_ec2s
    end

    def instances(profile)
      @regions.map {|region|
        ec2s[profile][region].instances(
          filters: [{
            name:   'instance-state-name',
            values:  %w(running)
          }]).
          to_a.
          sort_by do |ins|
            ins.tags.find_all do |tag|
              tag.key == 'Name'
            end.to_s
          end
      }.flatten
    end

    def self.expand_profile_name_to_credential(profile_name)
      provider = AWS::Core::CredentialProviders::SharedCredentialFileProvider.new(profile_name: profile_name)
      provider.credentials
    end
  end
end
