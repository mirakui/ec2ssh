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
    def all(use_private_dns)
      @dotfile['regions'].map {|region|
        process_region region, use_private_dns
      }.flatten
    end

    private
      def process_region(region, use_private_dns)
        hosts = instances(region).map {|instance|
          name_tag = instance[:tag_set].find {|tag| tag[:key] == 'Name' }
          next nil if name_tag.nil? || name_tag[:value].nil?
          dns_name = instance[use_private_dns ? :private_dns_name : :dns_name] or next nil
          {:host => "#{name_tag[:value]}.#{region}",
           :name => name_tag[:value],
           :dns_name => dns_name,
           :instance_id => instance[:instance_id]}
        }.compact
        
        host_names = hosts.map {|host| host[:name] }

        hosts.map {|host|
          suffix = region
          suffix = "#{host[:instance_id]}.#{suffix}" unless host_names.one?{|name| name == host[:name]}
          host[:host] = "#{host[:name]}.#{suffix}"

          host
        }.sort {|a,b| a[:host] <=> b[:host] }
      end

      def instances(region)
        response = @ec2[region].instances.tagged('Name').filtered_request(:describe_instances)
        response[:instance_index].values
      end
  end
end
