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
        config = SshConfig.new(ssh_config_path, cli.options.aws_key)
        unless config.mark_exist?
          red "Marker not found on #{ssh_config_path}"
          red "Execute '#{$0} init --path=/path/to/ssh_config' first!"
          return
        end

        config.parse!
        result = builder.result
        config_str = config.wrap result
        config.replace! config_str
        cli.yellow config_str
        #cli.green "Updated #{hosts.size} hosts on #{config_path}"
        cli.green "Updated #{config_path}"
      rescue AwsEnvNotDefined, AwsKeyNotFound
        cli.red "Set aws keys at #{options.dotfile}"
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
