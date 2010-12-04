require 'thor'
require 'right_aws'

module Ec2ssh
  class CLI < Thor
    path_option = [:path, {:banner => "/path/to/ssh_config", :default=>"#{ENV['HOME']}/.ssh/config"}]

    desc "init", "add ec2ssh marker to ssh_config"
    method_option *path_option
    def init
      config = Config.new(options.path)
      if config.marker_exist?
        puts "Marker already exists on #{options.path}"
        return
      end
      config.append_marker!
      puts "Added marker to #{options.path}"
    end

    desc "update", ""
    method_option *path_option
    def update
      config = Config.new(options.path)
      unless config.marker_exist?
        puts "Marker not found on #{options.path}"
        puts "Execute '#{$0} init --path=#{options.path}' first!"
        return
      end
      hosts = Hosts.new.all
      config.replace! config.wrap(hosts.map{|h|<<-END}.join)
Host #{h[:host]}
  HostName #{h[:dns_name]}
      END
      puts "Updated #{hosts.size} hosts to #{options.path}"
    end

    desc "remove", ""
    method_option *path_option
    def remove
      config = Config.new(options.path)
      unless config.marker_exist?
        puts "Marker not found on #{options.path}"
        return
      end
      config.replace! ""
      puts "Removed marker from #{options.path}"
    end
  end
end
