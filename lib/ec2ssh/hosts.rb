module Ec2ssh
  class AwsEnvNotDefined < StandardError; end
  class Hosts
    def initialize
      @access_key_id = ENV["AMAZON_ACCESS_KEY_ID"].to_s
      @secret_access_key = ENV["AMAZON_SECRET_ACCESS_KEY"].to_s
      if @access_key_id.length == 0 || @secret_access_key.length == 0
        raise AwsEnvNotDefined
      end
    end

    def all
      ec2 = RightAws::Ec2.new(@access_key_id, @secret_access_key)
      regions = ec2.describe_regions
      regions.map do |region|
        process_region region
      end.flatten
    end

    private
    def process_region(region)
      ec2 = RightAws::Ec2.new(@access_key_id, @secret_access_key, :region => region)
      instance_names = {}
      ec2.describe_tags.each do |tag|
        next unless tag[:key]=='Name' && tag[:resource_type]=='instance'
        instance_names[tag[:resource_id]] = tag[:value]
      end
      ec2.describe_instances.map do |instance|
        instance_name = instance_names[instance[:aws_instance_id]]
        instance_name ? {:host => "#{instance_name}.#{region}", :dns_name => instance[:dns_name]} : nil
      end.compact
    end
  end
end
