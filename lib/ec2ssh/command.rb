require 'ec2ssh/dsl'

module Ec2ssh
  module Command
    class Base
      attr_reader :cli

      def initialize(cli)
        @cli = cli
      end

      def dotfile
        @dotfile ||= Ec2ssh::Dsl::Parser.parse_file(dotfile_path)
      end

      def ssh_config_path
        cli.options.path || dotfile.path || "#{$ENV['HOME']}/.ssh/config"
      end

      def dotfile_path
        cli.options.dotfile
      end
    end
  end
end
