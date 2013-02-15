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
      dotfile['regions'].map {|region|
        process_region region
      }.flatten
    end

    private
      def process_region(region)
        ec2(region).instances.map {|instance|
          name = instance.tags['Name'] or next nil
          dns = instance.dns_name or next nil
          name.empty? || dns_name.empty? ? nil : {:host => "#{name}.#{region}", :dns_name => dns}
        }.compact
      end
  end
end
