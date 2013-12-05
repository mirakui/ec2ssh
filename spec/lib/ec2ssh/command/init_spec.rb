require 'ec2ssh/command/init'

describe Ec2ssh::Command::Init do
  describe '#run' do
    let(:command) do
      described_class.new(cli).tap do |cmd|
        allow(cmd).to receive(:ssh_config_path).and_return('/path/to/ssh/config')
        allow(cmd).to receive(:dotfile_path).and_return('/path/to/dotfile')
      end
    end
    let(:cli) do
      double(:cli, red: nil, yellow: nil, green: nil)
    end
    let(:ssh_config) do
      double(:ssh_config, mark_exist?: nil, append_mark!: nil)
    end

    before do
      expect(ssh_config).to receive(:mark_exist?).and_return(mark_exist)
      allow(command).to receive(:ssh_config).and_return(ssh_config)
      command.run
    end

    context 'when the marker already exists' do
      let(:mark_exist) { true }

      it do
        expect(cli).to have_received(:red).with('Marker already exists on /path/to/ssh/config')
      end

      it do
        expect(cli).to have_received(:yellow).with('Please check and edit /path/to/dotfile before run `ec2ssh update`')
      end

      it do
        expect(ssh_config).to_not have_received(:append_mark!)
      end

      #it do
      #  expect(Ec2ssh::Dotfile).to have_received(:update_or_create).once
      #end
    end

    context 'when the marker does not exists' do
      let(:mark_exist) { false }

      it do
        expect(cli).to have_received(:green).with('Added mark to /path/to/ssh/config')
      end

      it do
        expect(ssh_config).to have_received(:append_mark!).once
      end
    end
  end
end
