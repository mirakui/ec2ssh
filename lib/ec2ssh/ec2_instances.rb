require 'aws-sdk'

module Ec2ssh
  class Ec2Instances
    attr_reader :ec2s, :aws_keys

    class InstanceWrapper
      def initialize(ec2_instance)
        @ec2_instance = ec2_instance
      end

      def tags
        @tags ||= @ec2_instance.tags.each_with_object({}) {|t, h| h[t.key] = t.value }
      end

      private

      def method_missing(name, *args)
        @ec2_instance.send(name, *args)
      end

      def respond_to_missing?(symbol, include_private)
        @ec2_instance.respond_to?(symbol, include_private)
      end
    end

    def initialize(aws_keys, regions)
      @aws_keys = aws_keys
      @regions = regions
    end

    def make_ec2s
      _ec2s = {}
      aws_keys.each do |name, key|
        _ec2s[name] = {}
        @regions.each do |region|
          client = Aws::EC2::Client.new region: region, credentials: key
          _ec2s[name][region] = Aws::EC2::Resource.new client: client
        end
      end
      _ec2s
    end

    def ec2s
      @ec2s ||= make_ec2s
    end

    def instances(key_name)
      @regions.map {|region|
        ec2s[key_name][region].instances(
          filters: [{ name: 'instance-state-name', values: ['running'] }]
        ).
        to_a.
        map {|ins| InstanceWrapper.new(ins) }.
        sort_by {|ins| ins.tags['Name'].to_s }
      }.flatten
    end

    def self.expand_profile_name_to_credential(profile_name)
      client = Aws::STS::Client.new(profile: profile_name)
      client.config.credentials
    end
  end
end
