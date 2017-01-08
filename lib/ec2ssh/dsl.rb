require 'ec2ssh/exceptions'

module Ec2ssh
  class Dsl
    attr_reader :_result

    def initialize
      @_result = Container.new
    end

    def aws_keys(keys)
      @_result.aws_keys = keys
    end

    def profiles(*profiles)
      @_result.profiles = profiles
    end

    def regions(*regions)
      @_result.regions = regions
    end

    def host_line(erb)
      @_result.host_line = erb
    end

    def reject(&block)
      @_result.reject = block
    end

    def path(str)
      @_result.path = str
    end

    class Container < Struct.new(*%i[
      profiles
      regions
      host_line
      reject
      path
    ])
    end

    module Parser
      def self.parse(dsl_str)
        dsl = Dsl.new
        dsl.instance_eval dsl_str
        dsl._result.tap {|result| validate result }
      rescue SyntaxError => e
        raise DotfileSyntaxError, e.to_s
      end

      def self.parse_file(path)
        raise DotfileNotFound, path.to_s unless File.exist?(path)
        parse File.read(path)
      end

      def self.validate(result)
      end
    end
  end
end
