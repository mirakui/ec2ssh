module Ec2ssh
  class AwsEnvNotDefined < StandardError; end
  class Hosts
    def initialize(options)
      pit_key = options[:pit_key]

      if ENV["AMAZON_ACCESS_KEY_ID"] && ENV["AMAZON_SECRET_ACCESS_KEY"]
        @access_key_id = ENV["AMAZON_ACCESS_KEY_ID"].to_s
        @secret_access_key = ENV["AMAZON_SECRET_ACCESS_KEY"].to_s
      elsif pit_key
        config = Pit.get(pit_key, :require => {
          'access_key_id'     => 'Your Access Key ID to AWS',
          'secret_access_key' => 'Your Secret Access Key to AWS',
        })
        @access_key_id     = config['access_key_id'].to_s
        @secret_access_key = config['secret_access_key'].to_s
      end

      if (!@access_key_id     || @access_key_id.empty?) ||
         (!@secret_access_key || @secret_access_key.empty?)
        raise AwsEnvNotDefined
      end
    end

    def all
      ec2 = AWS::EC2.new(
        :access_key_id     => @access_key_id,
        :secret_access_key => @secret_access_key,
      )

      regions = ec2.regions
      regions.map do |region|
        process_region region
      end.flatten
    end

    private
    def process_region(region)
      hosts = region.tags.map do |tag|
        next unless tag.key == 'Name' &&
                    tag.resource.class == AWS::EC2::Instance

        instance_name = tag.value
        dns_name      = tag.resource.dns_name

        (instance_name.empty? || dns_name.empty?) ? nil : {
          :host     => "#{instance_name}.#{region.name}",
          :dns_name => dns_name
        }
      end

      hosts.compact
    end
  end
end
