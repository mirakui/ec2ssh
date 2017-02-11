require 'spec_helper'
require 'ec2ssh/command/remove'

describe Ec2ssh::Command::Remove do
  include FakeFS::SpecHelpers

  describe '#run' do
    let(:command) do
      described_class.new(cli).tap do |cmd|
        allow(cmd).to receive(:options).and_return(options)
      end
    end
    let(:options) do
      double(:options, path: '/ssh_config', dotfile: '/dotfile', aws_key: 'default')
    end
    let(:cli) do
      double(:cli, options: options, red: nil, yellow: nil, green: nil)
    end

    let(:dotfile_str) { <<-END }
path '/dotfile'
aws_keys(
  default: { access_key_id: 'ACCESS_KEY1', secret_access_key: 'SECRET1' }
)
host_line <<EOS
Host <%= tags['Name'] %>
  HostName <%= private_ip_address %>
EOS
    END

    before do
      File.open('/ssh_config', 'w') {|f| f.write ssh_config_str }
      File.open('/dotfile', 'w') {|f| f.write dotfile_str }
    end

    context 'with unmarked ssh_config' do
      let(:ssh_config_str) { '' }

      it do
        expect { command.run }.to raise_error(Ec2ssh::MarkNotFound)
      end
    end

    context 'with marked ssh_config' do
      let(:ssh_config_str) { <<-END }
# before lines...

### EC2SSH BEGIN ###
### EC2SSH END ###

# after lines...
      END

      before do
        Timecop.freeze(Time.utc(2014,1,1)) do
          command.run
        end
      end

      it do
        expect(File.read('/ssh_config')).to eq(<<-END)
# before lines...


# after lines...
        END
      end
    end
  end
end
