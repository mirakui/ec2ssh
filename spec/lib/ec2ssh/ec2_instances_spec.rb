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
      described_class.new(profiles=[profile], regions=[region]).tap do |e|
        allow(e).to receive(:fetch_instances).with(profile).and_return(mock_instances)
        allow(e).to receive(:regions) { [region] }
      end
    end

    context 'with non-empty names' do
      let(:mock_instances) {
        [
          double('instance', n: 1, tags: [double('tag', key: 'Name', value: 'srvB')]),
          double('instance', n: 2, tags: [double('tag', key: 'Name', value: 'srvA')]),
          double('instance', n: 3, tags: [double('tag', key: 'Name', value: 'srvC')])
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
          double('instance', n: 1, tags: [double('tag', key: 'Name', value: 'srvA')]),
          double('instance', n: 2, tags: [double('tag', key: 'Name', value: nil   )]),
          double('instance', n: 3, tags: [double('tag', key: 'Name', value: 'srvC')])
        ]
      }

      it do
        result = mock.instances(profile)
        expect(result.map {|ins| ins.n}).to match_array([2, 1, 3])
      end
    end

  end
end
