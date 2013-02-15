require 'thor'
require 'highline'
require 'ec2ssh/hosts'
require 'ec2ssh/ssh_config'
require 'ec2ssh/dotfile'

module Ec2ssh
  class CLI < Thor
    path_option = [:path, {:banner => "/path/to/ssh_config", :default=>"#{ENV['HOME']}/.ssh/config"}]
    class_option :dotfile, :banner => '$HOME/.ec2ssh', :default => "#{ENV['HOME']}/.ec2ssh"

    desc "init", "Add ec2ssh mark to ssh_config"
    method_option *path_option
    def init
      config = SshConfig.new(options.path)
      if config.mark_exist?
        red "Marker already exists on #{options.path}"
        return
      end
      config.append_mark!
      green "Added mark to #{options.path}"
      Dotfile.new.save(options.dotfile)
      yellow "Please check and edit #{options.dotfile} before run `ec2ssh update`"
    end

    desc "update", "Update ec2 hosts list in ssh_config"
    method_option *path_option
    def update
      config = SshConfig.new(options.path)
      unless config.mark_exist?
        red "Marker not found on #{options.path}"
        red "Execute '#{$0} init --path=#{options.path}' first!"
        return
      end
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

    desc "remove", "Remove ec2ssh mark from ssh_config"
    method_option *path_option
    def remove
      config = SshConfig.new(options.path)
      unless config.mark_exist?
        red "Marker not found on #{options.path}"
        return
      end
      config.replace! ""
      green "Removed mark from #{options.path}"
    end

    no_tasks do
      def hl
        @hl ||= HighLine.new
      end

      def hosts
        @hosts ||= Hosts.new(dotfile).all
      end

      def dotfile
        @dotfile ||= Dotfile.load(options.dotfile)
      end

      [:red,:green,:yellow].each do |col|
        define_method(col) do |str|
          puts hl.color(str, col)
        end
      end
    end
  end
end
