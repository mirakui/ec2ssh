require 'spec_helper'
require 'ec2ssh/ec2_instances'

describe Ec2ssh::Ec2Instances do
  describe '#instances' do
    let(:profile) {
      "default"
    }

    let(:region) {
      "ap-northeast-1"
    }

    let(:mock) do
      described_class.new(profiles=profile, regions=[region]).tap do |e|
        allow(e).to receive(:ec2s) { ec2s }
        allow(e).to receive(:regions) { [region] }
      end
    end

    let(:ec2s) {
      {
        "#{profile}" => {
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
          double('instance', n: 1, tags: { key: 'Name', value: 'srvB' }),
          double('instance', n: 2, tags: { key: 'Name', value: 'srvA' }),
          double('instance', n: 3, tags: { key: 'Name', value: 'srvC' })
        ]
      }

      it do
        result = mock.instances(profile)
        expect(result.map {|ins| ins.n}).to match_array([2, 1, 3])
      end
    end

    context 'with names including empty one' do
      let(:mock_instances) {
        [
          double('instance', n: 1, tags: { key: 'Name', value: 'srvA'}),
          double('instance', n: 2, tags: {}),
          double('instance', n: 3, tags: { key: 'Name', value: 'srvC' })
        ]
      }

      it do
        result = mock.instances(profile)
        expect(result.map {|ins| ins.n}).to match_array([2, 1, 3])
      end
    end

  end
end
