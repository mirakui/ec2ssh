module Ec2ssh
  class Dsl
    attr_reader :_result

    def initialize
      @_result = Container.new
    end

    def aws_keys(keys)
      @_result.aws_keys = keys
    end

    def regions(*regions)
      @_result.regions = regions
    end

    def host_lines(erb)
      @_result.host_lines = erb
    end

    def reject(&block)
      @_result.reject = block
    end

    def path(str)
      @_result.path = str
    end

    class Container < Struct.new(*%i[
      aws_keys
      regions
      host_lines
      reject
      path
    ])
    end

    module Parser
      def self.parse(dsl_str)
        dsl = Dsl.new
        dsl.instance_eval dsl_str
        dsl._result
      end
    end
  end
end
