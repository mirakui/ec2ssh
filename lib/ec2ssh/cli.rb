require 'thor'
require 'highline'
require 'ec2ssh/ssh_config'
require 'ec2ssh/dotfile'
require 'ec2ssh/exceptions'

module Ec2ssh
  class CLI < Thor
    class_option :path, banner: "/path/to/ssh_config"
    class_option :dotfile, banner: '$HOME/.ec2ssh', default: "#{ENV['HOME']}/.ec2ssh"
    class_option :verbose, banner: 'enable debug log', default: false

    desc 'init', 'Add ec2ssh mark to ssh_config'
    def init
      command = make_command :init
      command.run
    rescue MarkAlreadyExists
      red "Marker already exists in #{command.ssh_config_path}"
    end

    desc 'update', 'Update ec2 hosts list in ssh_config'
    method_option :aws_key, banner: 'aws key name', default: 'default'
    def update
      set_aws_logging
      command = make_command :update
      command.run
      green "Updated #{command.ssh_config_path}"
    rescue AwsKeyNotFound
      red "Set aws keys at #{command.dotfile_path}"
    rescue MarkNotFound
      red "Marker not found in #{command.ssh_config_path}"
      red "Execute '#{$0} init --path=/path/to/ssh_config' first!"
    end

    desc 'remove', 'Remove ec2ssh mark from ssh_config'
    def remove
      command = make_command :remove
      command.run
      green "Removed mark from #{command.ssh_config_path}"
    rescue MarkNotFound
      red "Marker not found in #{command.ssh_config_path}"
    end

    desc 'migrate', 'Migrate dotfile from old versions'
    def migrate
      command = make_command :migrate
      command.run
    end

    no_tasks do
      def make_command(cmd)
        require "ec2ssh/command/#{cmd}"
        cls = eval "Ec2ssh::Command::#{cmd.capitalize}"
        cls.new(self)
      end

      def set_aws_logging
        if options.verbose
          require 'logger'
          require 'aws-sdk'
          logger = ::Logger.new($stdout)
          logger.level = ::Logger::DEBUG
          ::AWS.config logger: logger
        end
      end

      def hl
        @hl ||= ::HighLine.new
      end

      [:red,:green,:yellow].each do |col|
        define_method(col) do |str|
          puts hl.color(str, col)
        end
      end
    end
  end
end
