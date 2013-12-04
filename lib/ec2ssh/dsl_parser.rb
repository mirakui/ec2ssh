require 'ec2ssh/dsl'

module Ec2ssh
  class DslParser
    def initialize(str)
      @dsl_str = str
    end

    def parse!
      dsl = Dsl.new
      dsl.instance_eval @dsl_str
      dsl.result
    end
  end
end
