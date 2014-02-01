require 'spec_helper'
require 'ec2ssh/cli'
require 'ec2ssh/command/init'

describe Ec2ssh::CLI do
  subject(:cli) { Ec2ssh::CLI.new }

  around do |example|
    silence_stdout { example.run }
  end

  describe '#init' do
    it do
      expect(cli).to receive(:run_command).with(:init)
      cli.init
    end
  end

  describe '#update' do
    it do
      expect(cli).to receive(:run_command).with(:update)
      cli.update
    end
  end
end
