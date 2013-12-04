require 'spec_helper'
require 'ec2ssh/dsl'
require 'ec2ssh/builder'

describe Ec2ssh::Builder do
  describe '#build_host_lines' do
    let(:container) do
      Ec2ssh::Dsl::Container.new.tap do |c|
        c.aws_keys = {
          key1: { access_key_id: 'KEY1', secret_access_key: 'SEC1' },
          key2: { access_key_id: 'KEY2', secret_access_key: 'SEC2' }
        }
        c.host_lines = "Host <%= tags['Name'] %>"
      end
    end

    let(:builder) do
      Ec2ssh::Builder.new(container).tap do |bldr|
        bldr.stub(:ec2s) { ec2s }
      end
    end

    let(:ec2s) do
      double('ec2s', aws_keys: container.aws_keys).tap do |dbl|
        allow(dbl).to receive(:instances) {|name| instances[name] }
      end
    end

    let(:instances) do
      {
        key1: [
          double('instance', tags: {'Name' => 'srv1'}),
          double('instance', tags: {'Name' => 'srv2'})],
        key2: [
          double('instance', tags: {'Name' => 'srv3'}),
          double('instance', tags: {'Name' => 'srv4'})]
      }
    end

    it do
      expect(builder.build_host_lines).to eq <<-END
# section: key1
Host srv1
Host srv2
# section: key2
Host srv3
Host srv4
      END
    end

    context 'with #reject' do
      before do
        container.reject = lambda {|ins| ins.tags['Name'] == 'srv1' }
      end

      it do
        expect(builder.build_host_lines).to eq <<-END
# section: key1
Host srv2
# section: key2
Host srv3
Host srv4
        END
      end
    end
  end
end
