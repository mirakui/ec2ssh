require 'thor'
require 'right_aws'
require 'highline'

module Ec2ssh
  class CLI < Thor
    path_option = [:path, {:banner => "/path/to/ssh_config", :default=>"#{ENV['HOME']}/.ssh/config"}]

    desc "init", "Add ec2ssh marker to ssh_config"
    method_option *path_option
    def init
      config = Config.new(options.path)
      if config.marker_exist?
        red "Marker already exists on #{options.path}"
        return
      end
      config.append_marker!
      green "Added marker to #{options.path}"
    end

    desc "update", "Update ec2 hosts list in ssh_config"
    method_option *path_option
    def update
      config = Config.new(options.path)
      unless config.marker_exist?
        red "Marker not found on #{options.path}"
        red "Execute '#{$0} init --path=#{options.path}' first!"
        return
      end
      hosts = Hosts.new.all
      config_str = config.wrap(hosts.map{|h|<<-END}.join)
Host #{h[:host]}
  HostName #{h[:dns_name]}
      END
      config.replace! config_str
      yellow config_str
      green "Updated #{hosts.size} hosts on #{options.path}"
    rescue AwsEnvNotDefined
      red <<-END 
Set environment variables to access AWS such as:
  export AMAZON_ACCESS_KEY_ID="..."
  export AMAZON_SECRET_ACCESS_KEY="..."
      END
    end

    desc "remove", "Remove ec2ssh marker from ssh_config"
    method_option *path_option
    def remove
      config = Config.new(options.path)
      unless config.marker_exist?
        red "Marker not found on #{options.path}"
        return
      end
      config.replace! ""
      green "Removed marker from #{options.path}"
    end

    private
    def hl
      @hl ||= HighLine.new
    end

    [:red,:green,:yellow].each do |col|
      define_method(col) do |str|
        puts hl.color(str, col)
      end
    end
  end
end
