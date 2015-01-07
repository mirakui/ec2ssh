require 'spec_helper'
require 'ec2ssh/command/migrate'

describe Ec2ssh::Command::Migrate do
  describe '#run' do
    let(:cli) do
      double(:cli,
             options: options, yes?: nil,
             red: nil, yellow: nil, green: nil)
    end
    let(:command) do
      described_class.new cli
    end
    let(:options) do
      double(:options, dotfile: '/dotfile')
    end

    before do
      File.open('/dotfile', 'w') {|f| f.write dotfile_str }
    end

    around do |example|
      silence_stdout { example.run }
    end

    context 'version 2' do
      let(:dotfile_str) { <<-END }
---
path: /path/to/ssh/config
aws_keys:
  key1:
    access_key_id: ACCESS_KEY1
    secret_access_key: SECRET1
      END

      context 'yes' do
        before do
          expect(cli).to receive(:yes?).and_return(true)
          Timecop.freeze(Time.utc(2014, 1, 1)) do
            command.run
          end
        end

        it do
          expect(File.read('/dotfile')).to eq <<-END
path '/path/to/ssh/config'
aws_keys(
  key1: { access_key_id: 'ACCESS_KEY1', secret_access_key: 'SECRET1' }
)

# Ignore unnamed instances
reject {|instance| !instance.tags['Name'] }

# You can use methods of AWS::EC2::Instance.
# See http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/EC2/Instance.html
host_line <<EOS
Host <%= tags['Name'] %>.<%= availability_zone %>
  HostName <%= dns_name || private_ip_address %>
EOS

# ---
# path: /path/to/ssh/config
# aws_keys:
#   key1:
#     access_key_id: ACCESS_KEY1
#     secret_access_key: SECRET1
          END
        end

        it do
          expect(File.read('/dotfile.20140101000000')).to eq(dotfile_str)
        end
      end

      context 'no' do
        before do
          expect(cli).to receive(:yes?).and_return(false)
          command.run
        end

        it do
          expect(File.read('/dotfile')).to eq(dotfile_str)
        end
      end
    end

    context 'version 3' do
      let(:dotfile_str) { <<-END }
path '/path/to/ssh/config'
aws_keys(
  key1: { access_key_id: 'ACCESS_KEY1', secret_access_key: 'SECRET1' }
)

# You can use methods of AWS::EC2::Instance.
# See http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/EC2/Instance.html
host_line <<EOS
Host <%= tags['Name'] %>.<%= availability_zone %>
  HostName <%= dns_name || private_ip_address %>
EOS
      END

      before do
        command.run
      end

      it do
        expect(File.read('/dotfile')).to eq(dotfile_str)
      end
    end
  end
end
