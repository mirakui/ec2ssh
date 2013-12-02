module Ec2ssh
  class Dsl
    attr_reader :result

    def initialize
      @result = {}
    end

    def aws_keys(*keys)
      @result[:aws_keys] = keys
    end

    def regions(*regions)
      @result[:regions] = regions
    end

    def host_lines(erb)
      @result[:host_lines_erb] = erb
    end

    def reject(&block)
      @result[:reject] = block
    end

    def path(str)
      @result[:path] = str
    end
  end
end
