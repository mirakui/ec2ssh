require 'ec2ssh/exceptions'
require 'ec2ssh/command'
require 'ec2ssh/ssh_config'

module Ec2ssh
  module Command
    class Remove < Base
      def initialize(cli)
        super
      end

      def run
        ssh_config = SshConfig.new(ssh_config_path)
        raise MarkNotFound unless ssh_config.mark_exist?

        ssh_config.replace! ""
      end
    end
  end
end
