require 'aws-sdk'
require 'ec2ssh/dotfile'

module Ec2ssh
  class AwsEnvNotDefined < StandardError; end
  class Hosts
    def initialize(dotfile, keyname)
      @dotfile = dotfile
      @ec2 = Hash.new do |h,region|
        key = dotfile.aws_key(keyname)
        raise AwsEnvNotDefined if key['access_key_id'].nil? || key['secret_access_key'].nil?
        h[region] = AWS::EC2.new(
          :ec2_endpoint      => "#{region}.ec2.amazonaws.com",
          :access_key_id     => key['access_key_id'],
          :secret_access_key => key['secret_access_key']
        )
      end
    end

    def all dns_name_key
      @dotfile['regions'].map {|region|
        process_region region, dns_name_key
      }.flatten
    end

    private
      def process_region(region, dns_name_key)
        instances(region).map {|instance|
          name_tag = instance[:tag_set].find {|tag| tag[:key] == 'Name' }
          next nil if name_tag.nil? || name_tag[:value].nil?
          name = "#{name_tag[:value]}_#{instance[:instance_id]}"
          dns_name = instance[dns_name_key.to_sym] or next nil
          {:host => "#{name}.#{region}", :dns_name => dns_name}
        }.compact.sort {|a,b| a[:host] <=> b[:host] }
      end

      def instances(region)
        response = @ec2[region].instances.tagged('Name').filtered_request(:describe_instances)
        response[:instance_index].values
      end
  end
end
