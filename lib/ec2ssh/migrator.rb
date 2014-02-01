require 'ec2ssh/dsl'

module Ec2ssh
  class Migrator
    def initialize(dotfile_path)
      @dotfile_path = dotfile_path
    end

    def check_version
      str = File.read @dotfile_path
      begin
        YAML.load str
        return 2
      rescue
      end

      begin
        Dsl::Parser.parse str
        return 3
      rescue
      end

      raise InvalidDotfile
    end
  end
end
