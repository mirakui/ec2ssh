require 'spec_helper'
require 'ec2ssh/ec2_instances'

describe Ec2ssh::Ec2Instances do
  describe '#instances' do
    let(:key_name) {
      "dummy_key_name"
    }

    let(:region) {
      "ap-northeast-1"
    }

    let(:mock) do
      described_class.new({key_name => {region => ''}}).tap do |e|
        allow(e).to receive(:ec2s) { ec2s }
      end
    end

    let(:ec2s) {
      {
        "#{key_name}" => {
          "#{region}" => instances.tap do |m|
            allow(m).to receive(:instances) { m }
          end
        }
      }
    }

    let(:instances) {
      mock_instances.tap do |m|
        allow(m).to receive(:filter) { m }
      end
    }

    context 'with non-empty names' do
      let(:mock_instances) {
        [
          double('instance', n: 1, tags: [double('tag', key: 'Name', value: 'srvB')]),
          double('instance', n: 2, tags: [double('tag', key: 'Name', value: 'srvA')]),
          double('instance', n: 3, tags: [double('tag', key: 'Name', value: 'srvC')])
        ]
      }

      it do
        result = mock.instances(key_name)
        expect(result.map {|ins| ins.n}).to match_array([2, 1, 3])
      end
    end

    context 'with names including empty one' do
      let(:mock_instances) {
        [
          double('instance', n: 1, tags: [double('tag', key: 'Name', value: 'srvA')]),
          double('instance', n: 2, tags: []),
          double('instance', n: 3, tags: [double('tag', key: 'Name', value: 'srvC')])
        ]
      }

      it do
        result = mock.instances(key_name)
        expect(result.map {|ins| ins.n}).to match_array([2, 1, 3])
      end
    end
  end

  describe Ec2ssh::Ec2Instances::InstanceWrapper do
    let(:mock_instance) {
      double('instance', n: 1, tags: [double('tag', key: 'Name', value: 'srvA')])
    }
    let(:instance) { described_class.new(mock_instance) }

    describe '#tag' do
      it { expect(instance.tag('Name')).to eq 'srvA' }
    end

    describe '#tags' do
      it { expect(instance.tags).to match_array(have_attributes(key: 'Name', value: 'srvA')) }
      it { expect(instance.tags[0]).to have_attributes(key: 'Name', value: 'srvA') }
      it { expect { instance.tags['Name'] }.to output("`tags[String]` syntax is deleted. Please upgrade your .ec2ssh syntax.\n").to_stderr.and raise_error TypeError }
    end
  end
end
