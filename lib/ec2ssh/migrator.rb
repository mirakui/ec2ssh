require 'yaml'
require 'stringio'
require 'ec2ssh/dsl'

module Ec2ssh
  class Migrator
    def initialize(dotfile_path)
      @dotfile_path = dotfile_path
    end

    def dotfile_str
      @dotfile_str ||= File.read(@dotfile_path)
    end

    def check_version
      begin
        hash = YAML.load dotfile_str
        return '2' if hash.keys.include? 'aws_keys'
      rescue Psych::SyntaxError
      end

      begin
        Dsl::Parser.parse dotfile_str
        return '3'
      rescue DotfileSyntaxError
      end

      raise InvalidDotfile
    end

    def migrate_from_2
      hash = YAML.load dotfile_str
      out = StringIO.new

      out.puts "path '#{hash['path']}'" if hash['path']

      out.puts 'aws_keys('
      out.puts hash['aws_keys'].map {|name, key|
        "  #{name}: { access_key_id: '#{key['access_key_id']}', secret_access_key: '#{key['secret_access_key']}' }"
      }.join(",\n")
      out.puts ')'

      if hash['regions']
        regions = hash['regions'].map{|r| "'#{r}'" }.join(', ')
        out.puts "regions #{regions}"
      end

      out.string
    end
  end
end
