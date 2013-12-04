require 'aws-sdk'

module Ec2ssh
  class Ec2Instances
    attr_reader :ec2s, :aws_keys

    def initialize(aws_keys, regions)
      AWS.start_memoizing
      @aws_keys = aws_keys
      @regions = regions
      @ec2s = {}
      aws_keys.each do |key|
        key_name = aws_keys[:key_name] || aws_keys[:access_key_id]
        @ec2s[key_name] = {}
        regions.each do |region|
          options = key.merge ec2_region: region
          @ec2s[key_name][region] = AWS::EC2.new options
        end
      end
    end

    def instances(key_name)
      @regions.map {|region|
        @ec2s[key_name][region].instances.
          filter('instance-state-name', 'running').
          to_a.
          sort_by {|ins| ins.tags['Name'] }
      }.flatten
    end
  end
end
