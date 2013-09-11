require 'ec2ssh/dsl'
require 'aws-sdk'
require 'erb'
require 'stringio'

module Ec2ssh
  class DslParser
    def initialize
    end

    def parse(str)
      dsl = Dsl.new
      dsl.instance_eval str
      @dsl = dsl.result
    end

    def host_lines
      @host_lines ||= build_host_lines
    end

    def build_host_lines
      out = StringIO.new
      regions.each do |region|
        aws_keys.each do |key|
          options = key.merge ec2_region: region
          ec2 = AWS::EC2.new options
          _build_host_lines(ec2, out)
        end
      end
      out.string
    end

    def _build_host_lines(ec2, out)
      AWS.memoize do
        instances(ec2).each do |instance|
          bind = instance.instance_eval { binding }
          next if skip_if && skip_if.call(instance)
          out.puts host_lines_erb.result(bind)
        end
      end
    end

    def instances(ec2)
      ec2.instances.
        filter('instance-state-name', 'running')
    end

    def regions
      @dsl[:regions] || []
    end

    def aws_keys
      @dsl[:aws_keys] || []
    end

    def host_lines_erb
      @host_lines_erb ||= ERB.new(@dsl[:host_lines_erb])
    end

    def skip_if
      @dsl[:skip_if]
    end

    def evaluate_host_lines(erb)
    end
  end
end

if $0 == __FILE__
  parser = Ec2ssh::DslParser.new
  path = File.expand_path('../../../example/example.ec2ssh', __FILE__)
  out = parser.parse File.read(path)
  puts parser.host_lines
end
