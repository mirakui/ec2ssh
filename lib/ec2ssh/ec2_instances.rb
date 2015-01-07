require 'aws-sdk'

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
          select {|ins| ins.tags['Name'] }.
          sort_by {|ins| ins.tags['Name'] }
      }.flatten
    end
  end
end
