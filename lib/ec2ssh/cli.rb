require 'thor'
require 'highline'
require 'ec2ssh/hosts'
require 'ec2ssh/ssh_config'
require 'ec2ssh/dotfile'

module Ec2ssh
  class CLI < Thor
    class_option :path, :banner => "/path/to/ssh_config"
    class_option :dotfile, :banner => '$HOME/.ec2ssh', :default => "#{ENV['HOME']}/.ec2ssh"

    desc "init", "Add ec2ssh mark to ssh_config"
    def init
      config = SshConfig.new(config_path)
      if config.mark_exist?
        red "Marker already exists on #{config_path}"
      else
        config.append_mark!
        green "Added mark to #{config_path}"
      end
      dotfile = Dotfile.update_or_create(options.dotfile, 'path' => options.path)
      yellow "Please check and edit #{options.dotfile} before run `ec2ssh update`"
    end

    desc "update", "Update ec2 hosts list in ssh_config"
    method_option :aws_key, :banner => 'aws key name', :default => 'default'
    def update
      config = SshConfig.new(config_path)
      unless config.mark_exist?
        red "Marker not found on #{config_path}"
        red "Execute '#{$0} init --path=/path/to/ssh_config' first!"
        return
      end
      config_str = config.wrap(hosts.map{|h|<<-END}.join)
Host #{h[:host]}
  HostName #{h[:dns_name]}
      END
      config.replace! config_str
      yellow config_str
      green "Updated #{hosts.size} hosts on #{config_path}"
    rescue AwsEnvNotDefined, AwsKeyNotFound
      red "Set aws keys at #{options.dotfile}"
    end

    desc "remove", "Remove ec2ssh mark from ssh_config"
    def remove
      config = SshConfig.new(config_path)
      unless config.mark_exist?
        red "Marker not found on #{config_path}"
        return
      end
      config.replace! ""
      green "Removed mark from #{config_path}"
    end

    no_tasks do
      def hl
        @hl ||= HighLine.new
      end

      def hosts
        @hosts ||= Hosts.new(dotfile, options.aws_key).all
      end

      def dotfile
        @dotfile ||= begin
          if File.exist?(options.dotfile)
            Dotfile.load(options.dotfile)
          else
            Dotfile.new
          end
        end
      end

      def config_path
        options.path || dotfile['path'] || "#{$ENV['HOME']}/.ssh/config"
      end

      [:red,:green,:yellow].each do |col|
        define_method(col) do |str|
          puts hl.color(str, col)
        end
      end
    end
  end
end
