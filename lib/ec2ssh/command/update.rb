require 'ec2ssh/exceptions'
require 'ec2ssh/command'
require 'ec2ssh/ssh_config'
require 'ec2ssh/builder'
require 'ec2ssh/dsl'

module Ec2ssh
  module Command
    class Update < Base
      def initialize(cli)
        super
      end

      def run
        ssh_config = SshConfig.new(cli.options.path, cli.options.aws_key)
        raise MarkNotFound unless ssh_config.mark_exist?

        ssh_config.parse!
        lines = builder.build_host_lines
        ssh_config_str = ssh_config.wrap lines
        ssh_config.replace! ssh_config_str
        cli.yellow ssh_config_str
      end

      def builder
        @builder ||= Builder.new dsl
      end

      def dsl
        @dsl ||= Ec2ssh::Dsl::Parser.parse File.read(dotfile_path)
      end
    end
  end
end
