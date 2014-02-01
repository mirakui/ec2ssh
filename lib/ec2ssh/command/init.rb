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
        raise MarkAlreadyExists if ssh_config.mark_exist?
        ssh_config.append_mark!
        cli.green "Added mark to #{ssh_config_path}"
        #dotfile = Dotfile.update_or_create(options.dotfile, 'path' => config_path)
        cli.yellow "Please check and edit #{dotfile_path} before run `ec2ssh update`"
      end

      def ssh_config
        @ssh_config ||= SshConfig.new(ssh_config_path)
      end
    end
  end
end
