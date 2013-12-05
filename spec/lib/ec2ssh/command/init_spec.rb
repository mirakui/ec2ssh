require 'ec2ssh/command/init'

describe Ec2ssh::Command::Init do
  describe '#run' do
    let(:command) do
      described_class.new(cli).tap do |cmd|
        allow(cmd).to receive(:ssh_config_path).and_return('/path/to/ssh/config')
        allow(cmd).to receive(:dotfile_path).and_return('/path/to/dotfile')
      end
    end
    let(:cli) { double(:cli) }

    context 'when the marker already exists' do
      before do
        allow(command).to receive(:ssh_config) do
          double(:ssh_config, mark_exist?: true)
        end
      end

      it do
        expect(cli).to receive(:red).with('Marker already exists on /path/to/ssh/config')
        expect(cli).to receive(:yellow).with('Please check and edit /path/to/dotfile before run `ec2ssh update`')
        command.run
      end
    end
  end
end
