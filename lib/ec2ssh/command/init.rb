require 'ec2ssh/command'
require 'ec2ssh/ssh_config'
require 'ec2ssh/exceptions'

module Ec2ssh
  module Command
    class Init < Base
      def initialize(cli)
        super
      end

      def run
        begin
          init_ssh_config
        rescue DotfileNotFound
          init_dotfile
          retry
        end
      end

      def init_dotfile
        if File.exist?(dotfile_path)
          cli.yellow "Warning: #{dotfile_path} already exists."
          return
        end

        write_dotfile_example

        cli.green "Generated #{dotfile_path}"
        cli.yellow "Please check and edit #{dotfile_path} before run `ec2ssh update`"
      end

      def write_dotfile_example
        example = <<-DOTFILE
path '#{ENV['HOME']}/.ssh/config'
aws_keys(
  default: {
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  },
  # my_key1: { access_key_id: '...', secret_access_key: '...' }, ...
)
regions ENV['AWS_REGION'] || ENV['AMAZON_REGION'] || ENV['AWS_DEFAULT_REGION'] || 'us-east-1'
# Enable regions as you like
# regions *%w(ap-northeast-1 ap-southeast-1 ap-southeast-2 eu-west-1 sa-east-1 us-east-1 us-west-1 us-west-2)

# You can use methods of AWS::EC2::Instance.
# See http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/EC2/Instance.html
host_line <<END
Host <%= tags['Name'] %>.<%= availability_zone %>
  HostName <%= dns_name || private_ip_address %>
END
        DOTFILE

        File.open(dotfile_path, 'w') {|f| f.write example }
      end

      def init_ssh_config
        if ssh_config.mark_exist?
          raise MarkAlreadyExists
        else
          ssh_config.append_mark!
          cli.green "Added mark to #{ssh_config_path}"
        end
      end

      def ssh_config
        @ssh_config ||= SshConfig.new(ssh_config_path)
      end
    end
  end
end
