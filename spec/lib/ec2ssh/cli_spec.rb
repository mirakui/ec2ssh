require 'spec_helper'
require 'ec2ssh/cli'
require 'ec2ssh/command/init'

describe Ec2ssh::CLI do
  subject(:cli) { Ec2ssh::CLI.new }

  describe '#init' do
    it do
      expect(cli).to receive(:run_command).with(:init)
      cli.init
    end
  end
end
