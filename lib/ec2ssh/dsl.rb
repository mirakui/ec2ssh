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

    def skip_if(&block)
      @result[:skip_if] = block
    end
  end
end
