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
      double(:cli, red: true, yellow: true, green: true)
    end

    context 'when the marker already exists' do
      before do
        allow(command).to receive(:ssh_config) do
          double(:ssh_config, mark_exist?: true)
        end
        command.run
      end

      it do
        expect(cli).to have_received(:red).with('Marker already exists on /path/to/ssh/config')
      end

      it do
        expect(cli).to have_received(:yellow).with('Please check and edit /path/to/dotfile before run `ec2ssh update`')
      end

      #it do
      #  expect(Ec2ssh::Dotfile).to have_received(:update_or_create).once
      #end
    end
  end
end
