require 'thor'
require 'highline'
require 'ec2ssh/ssh_config'
require 'ec2ssh/dotfile'
require 'ec2ssh/exceptions'

module Ec2ssh
  class CLI < Thor
    class_option :path, :banner => "/path/to/ssh_config"
    class_option :dotfile, :banner => '$HOME/.ec2ssh', :default => "#{ENV['HOME']}/.ec2ssh"

    desc "init", "Add ec2ssh mark to ssh_config"
    def init
      run_command :init
    end

    desc "update", "Update ec2 hosts list in ssh_config"
    method_option :aws_key, :banner => 'aws key name', :default => 'default'
    def update
      run_command :update
      green "Updated #{options.path}"
    rescue AwsKeyNotFound
      red "Set aws keys at #{options.dotfile}"
    rescue MarkNotFound
      red "Marker not found in #{options.path}"
      red "Execute '#{$0} init --path=/path/to/ssh_config' first!"
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
      def run_command(cmd)
        require "ec2ssh/command/#{cmd}"
        cls = eval "Ec2ssh::Command::#{cmd.capitalize}"
        cls.new(self).run
      end

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
end
