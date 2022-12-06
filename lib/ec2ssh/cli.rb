require 'thor'
require 'highline'
require 'ec2ssh/ssh_config'
require 'ec2ssh/exceptions'

module Ec2ssh
  class CLI < Thor
    class_option :path, banner: "/path/to/ssh_config"
    class_option :dotfile, banner: '$HOME/.ec2ssh', default: "#{ENV['HOME']}/.ec2ssh"
    class_option :verbose, banner: 'enable debug log', type: 'boolean'

    desc 'init', 'Add ec2ssh mark to ssh_config'
    def init
      command = make_command :init
      command.run
    rescue MarkAlreadyExists
      red "Marker already exists in #{command.ssh_config_path}"
    end

    desc 'update', 'Update ec2 hosts list in ssh_config'
    def update
      check_dotfile_existence
      set_aws_logging
      command = make_command :update
      command.run
      green "Updated #{command.ssh_config_path}"
    rescue AwsKeyNotFound
      red "Set aws keys at #{command.dotfile_path}"
    rescue MarkNotFound
      red "Marker not found in #{command.ssh_config_path}"
      red "Execute '#{$0} init' first!"
    end

    desc 'remove', 'Remove ec2ssh mark from ssh_config'
    def remove
      check_dotfile_existence
      command = make_command :remove
      command.run
      green "Removed mark from #{command.ssh_config_path}"
    rescue MarkNotFound
      red "Marker not found in #{command.ssh_config_path}"
    end

    desc 'shellcomp [-]', 'Initialize shell completion for bash/zsh'
    def shellcomp(_ = false)
      if args.include?("-")
        print_rc = true
      else
        print_rc = false
      end

      # print instructions for automatically enabling shell completion
      unless print_rc
        puts <<EOS
# Enable ec2ssh completion by adding
# the following to .bash_profile/.zshrc

type ec2ssh >/dev/null 2>&1 && eval "$(ec2ssh shellcomp -)"

EOS
        exit(false)
      end

      # print shell script for enabling shell completion
      zsh_comp_file = File.expand_path("../../../zsh/_ec2ssh", __FILE__)
      bash_comp_file = File.expand_path("../../../bash/ec2ssh.bash", __FILE__)
      puts <<EOS
if [ -n "${BASH_VERSION:-}" ]; then
    source #{bash_comp_file}
elif [ -n "${ZSH_VERSION:-}" ]; then
    source #{zsh_comp_file}
fi
EOS
    end

    desc 'version', 'Show version'
    def version
      require 'ec2ssh/version'
      puts "ec2ssh #{Ec2ssh::VERSION}"
    end

    no_tasks do
      def check_dotfile_existence
        unless File.exist?(options.dotfile)
          red "#{options.dotfile} doesn't exist."
          red "Try '#{$0} init' to generate it or specify the path with --dotfile option"
          abort
        end
      end

      def make_command(cmd)
        require "ec2ssh/command/#{cmd}"
        cls = eval "Ec2ssh::Command::#{cmd.capitalize}"
        cls.new(self)
      end

      def set_aws_logging
        if options.verbose
          require 'logger'
          require 'aws-sdk-core'
          logger = ::Logger.new($stdout)
          logger.level = ::Logger::DEBUG
          ::Aws.config.update logger: logger
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

    def self.exit_on_failure?
      false
    end
  end
end
