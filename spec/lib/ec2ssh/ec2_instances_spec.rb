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

    let(:container) do
      Ec2ssh::Dsl::Container.new.tap do |c|
        c.regions = [region]
      end
    end

    let(:mock) do
      described_class.new(profiles='', container).tap do |e|
        allow(e).to receive(:ec2s) { ec2s }
        allow(e).to receive(:regions) { [region] }
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
          double('instance', n: 1, tags: {'Name' => 'srvB' }),
          double('instance', n: 2, tags: {'Name' => 'srvA' }),
          double('instance', n: 3, tags: {'Name' => 'srvC' })
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
          double('instance', n: 1, tags: {'Name' => 'srvA'}),
          double('instance', n: 2, tags: {}),
          double('instance', n: 3, tags: {'Name' => 'srvC' })
        ]
      }

      it do
        result = mock.instances(key_name)
        expect(result.map {|ins| ins.n}).to match_array([2, 1, 3])
      end
    end

  end
end
