require 'ec2ssh/exceptions'
require 'aws-sdk'

module Ec2ssh
  class Dsl
    attr_reader :_result

    CREDENTIAL_CLASSES = [Aws::Credentials, Aws::SharedCredentials, Aws::InstanceProfileCredentials, Aws::AssumeRoleCredentials].freeze
    private_constant :CREDENTIAL_CLASSES

    def initialize
      @_result = Container.new
    end

    def aws_keys(keys)
      unless keys.all? {|_, v| v.is_a?(Hash) && v.each_value.all? {|c| CREDENTIAL_CLASSES.any?(&c.method(:is_a?)) } }
        abort 'aws_keys structure is changed. Please change your .ec2ssh syntax.'
      end
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
      aws_keys
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
        if result.aws_keys && result.profiles
          raise DotfileValidationError, "`aws_keys` and `profiles` doesn't work together in dotfile."
        end
      end
    end
  end
end
