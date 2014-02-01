require 'thor'
require 'highline'
require 'ec2ssh/ssh_config'
require 'ec2ssh/dotfile'

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

      def run_command(cmd)
        require "ec2ssh/command/#{cmd}"
        cls = eval "Ec2ssh::Command::#{cmd.capitalize}"
        cls.new(self).run
      end

      def config_path
        options.path || dotfile['path'] || "#{ENV['HOME']}/.ssh/config"
      end

      [:red,:green,:yellow].each do |col|
        define_method(col) do |str|
          puts hl.color(str, col)
        end
      end

      def merge_sections(config)
        section_str = hosts.map { |h| <<-END }.join
Host #{h[:host]}
  HostName #{h[:dns_name]}
        END
        config.sections[options.aws_key] ||= SshConfig::Section.new(
          options.aws_key,
          section_str
        )

        sections = config.sections.values.map do |section|
          if (
              # section is matched
              (section.name == options.aws_key) ||

              # for backward compatibility
              (config.sections.size == 1 && options.aws_key != 'default')
          )
            section.name = options.aws_key
            section.replace!(section_str)
          end

          section.to_s
        end
      end
    end
  end
end
