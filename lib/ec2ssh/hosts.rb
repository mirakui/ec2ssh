require 'aws-sdk'
require 'ec2ssh/dotfile'

module Ec2ssh
  class AwsEnvNotDefined < StandardError; end
  class Hosts
    def initialize(dotfile)
      @dotfile = dotfile
      @ec2 = Hash.new do |h,region|
        raise AwsEnvNotDefined if dotfile['access_key_id'].empty? || dotfile['secret_access_key'].empty?
        h[region] = AWS::EC2.new(
          :ec2_endpoint      => "#{region}.ec2.amazonaws.com",
          :access_key_id     => dotfile['access_key_id'],
          :secret_access_key => dotfile['secret_access_key'],
        )
      end
    end

    def all
      @dotfile['regions'].map {|region|
        process_region region
      }.flatten
    end

    private
      def process_region(region)
        instances(region).map {|instance|
          name_tag = instance[:tag_set].find {|tag| tag[:key] == 'Name' }
          next nil if name_tag.nil? || name_tag[:value].empty?
          name = name_tag[:value]
          dns_name = instance[:dns_name] or next nil
          {:host => "#{name}.#{region}", :dns_name => dns_name}
        }.compact.sort {|a,b| a[:host] <=> b[:host] }
      end

      def instances(region)
        response = @ec2[region].instances.tagged('Name').filtered_request(:describe_instances)
        response[:instance_index].values
      end
  end
end
