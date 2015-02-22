require 'ec2ssh/ec2_instances'
require 'erb'
require 'stringio'

module Ec2ssh
  class Builder
    def initialize(container)
      @container = container
      safe_level = nil
      erb_trim_mode = '%-'
      @host_lines_erb = ERB.new @container.host_line, safe_level, erb_trim_mode
    end

    def build_host_lines
      out = StringIO.new
      @container.aws_keys.each do |name, key|
        out.puts "# section: #{name}"
        ec2s.instances(name).each do |instance|
          bind = instance.instance_eval { binding }
          next if @container.reject && @container.reject.call(instance)
          line = @host_lines_erb.result(bind).rstrip
          out.puts line unless line.empty?
        end
      end
      out.string.rstrip
    end

    def ec2s
      @ec2s ||= Ec2Instances.new @container.aws_keys, @container.regions
    end
  end
end
