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
        case version
        when '2'
          cli.red "Current dotfile version is #{version} (#{dotfile_path})"
          new_dotfile_str = migrator.migrate_from_2
          cli.red "Ec2ssh is migrating your dotfile to version 3 style as follows:"
          cli.yellow new_dotfile_str
          if cli.yes? "Are you sure to migrate #{dotfile_path} to version 3 style? (y/n)"
            backup_path = migrator.backup!
            puts "Creating backup as #{backup_path}"
            migrator.replace! new_dotfile_str
            cli.green 'Migrated successfully.'
          end
        when '3'
          cli.green "Current dotfile version is #{version} (#{dotfile_path})"
          cli.green 'Your dotfile is up-to-date.'
        end
      end

      def dsl
        @dsl ||= Ec2ssh::Dsl::Parser.parse File.read(dotfile_path)
      end
    end
  end
end
