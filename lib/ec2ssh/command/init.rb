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

        example = <<-DOTFILE
path '#{ENV['HOME']}/.ssh/config'
aws_keys(
  default: {
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  },
  # my_key1: { access_key_id: '...', secret_access_key: '...' }, ...
)
regions 'us-east-1'
#reject {|instance| instance.tags['Name'] =~ /.../ }
host_line <<END
Host <%= tags['Name'] %>
  HostName <%= private_ip_address %>
END
        DOTFILE

        File.open(dotfile_path, 'w') {|f| f.write example }
        cli.green "Generated #{dotfile_path}"
        cli.yellow "Please check and edit #{dotfile_path} before run `ec2ssh update`"
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
