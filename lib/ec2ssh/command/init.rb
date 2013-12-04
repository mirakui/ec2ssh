require 'ec2ssh/command'
require 'ec2ssh/ssh_config'

module Ec2ssh
  module Command
    class Init < Base

      def initialize(cli)
        super
      end

      def run
        config = SshConfig.new(ssh_config_path)
        if config.mark_exist?
          cli.red "Marker already exists on #{ssh_config_path}"
        else
          config.append_mark!
          cli.green "Added mark to #{ssh_config_path}"
        end
        #dotfile = Dotfile.update_or_create(options.dotfile, 'path' => config_path)
        cli.yellow "Please check and edit #{dotfile_path} before run `ec2ssh update`"
      end
    end
  end
end
