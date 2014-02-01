require 'ec2ssh/dsl'

module Ec2ssh
  class Migrator
    def initialize(dotfile_path)
      @dotfile_path = dotfile_path
    end

    def check_version
      str = File.read @dotfile_path
      begin
        hash = YAML.load str
        return '2' if hash.keys.include? 'aws_keys'
      rescue Psych::SyntaxError
      end

      begin
        Dsl::Parser.parse str
        return '3'
      rescue DotfileSyntaxError
      end

      raise InvalidDotfile
    end
  end
end
