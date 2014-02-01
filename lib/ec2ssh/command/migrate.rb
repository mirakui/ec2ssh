require 'ec2ssh/exceptions'
require 'ec2ssh/command'
require 'ec2ssh/migrator'

module Ec2ssh
  module Command
    class Migrate < Base
      def initialize(cli)
        super
      end

      def run
        migrator = Migrator.new dotfile_path
        version = migrator.check_version
        cli.yellow "Current dotfile version is #{version} (#{dotfile_path})"
      end

      def dsl
        @dsl ||= Ec2ssh::Dsl::Parser.parse File.read(dotfile_path)
      end
    end
  end
end
