require 'ec2ssh/ec2_instances'
require 'erb'
require 'stringio'

module Ec2ssh
  class Builder
    def initialize(container)
      @container = container
      @host_lines_erb = ERB.new @container.host_line
    end

    def build_host_lines
      out = StringIO.new
      @container.aws_keys.each do |name, key|
        out.puts "# section: #{name}"
        ec2s.instances(name).each do |instance|
          bind = instance.instance_eval { binding }
          next if @container.reject && @container.reject.call(instance)
          out.puts @host_lines_erb.result(bind)
        end
      end
      out.string
    end

    def ec2s
      @ec2s ||= Ec2Instances.new @container.aws_keys, @container.regions
    end
  end
end
