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
      aws_keys.each do |name, key|
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
      @ec2s ||= Ec2Instances.new aws_keys, filters
    end

    def aws_keys
      @aws_keys ||= if @container.profiles
                      keys = {}
                      @container.profiles.each do |profile_name|
                        keys[profile_name] = {}
                        @container.regions.each do |region|
                          keys[profile_name][region] = Ec2Instances.expand_profile_name_to_credential profile_name, region
                        end
                      end
                      keys
                    else
                      @container.aws_keys
                    end
    end

    def filters
      @filters = @container.filters || [{
        name: 'instance-state-name',
        values: ['running']
      }]
    end
  end
end
