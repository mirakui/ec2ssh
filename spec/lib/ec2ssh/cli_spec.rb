require 'spec_helper'
require 'ec2ssh/cli'
require 'ec2ssh/command/init'

describe Ec2ssh::CLI do
  subject(:cli) { Ec2ssh::CLI.new }

  around do |example|
    silence_stdout { example.run }
  end

  before do
    allow(cli).to receive(:make_command) do |cmd|
      double(cmd, run: nil, ssh_config_path: nil, dotfile_path: nil)
    end
  end

  describe '#init' do
    it do
      expect { cli.init }.not_to raise_error
    end
  end

  describe '#update' do
    it do
      expect { cli.update }.not_to raise_error
    end
  end
end
