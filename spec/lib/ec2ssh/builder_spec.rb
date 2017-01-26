require 'spec_helper'
require 'ec2ssh/dsl'
require 'ec2ssh/builder'

describe Ec2ssh::Builder do
  describe '#build_host_lines' do
    let(:container) do
      Ec2ssh::Dsl::Container.new.tap do |c|
        c.host_line = "Host <%= tags.find{|t| t.key == 'Name' }.value %>"
        c.profiles = %w(key1 key2)
      end
    end

    let(:builder) do
      Ec2ssh::Builder.new(container).tap do |bldr|
        allow(bldr).to receive(:ec2s) { ec2s }
      end
    end

    let(:ec2s) do
      double('ec2s').tap do |dbl|
        allow(dbl).to receive(:instances) {|profile| instances[profile] }
      end
    end

    let(:instances) do
      {
        'key1' => [
          double('instance', tags: [double('tag', key: 'Name', value: 'srv1')]),
          double('instance', tags: [double('tag', key: 'Name', value: 'srv2')])
        ],
        'key2' => [
          double('instance', tags: [double('tag', key: 'Name', value: 'srv3')]),
          double('instance', tags: [double('tag', key: 'Name', value: 'srv4')])
        ]
      }
    end

    it do
      expect(builder.build_host_lines).to eq <<-END.rstrip
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
        container.reject = lambda {|ins| ins.tags.find{|t| t.key == 'Name' }.value == 'srv1' }
      end

      it do
        expect(builder.build_host_lines).to eq <<-END.rstrip
# section: key1
Host srv2
# section: key2
Host srv3
Host srv4
        END
      end
    end

    context 'checking erb trim_mode' do
      before do
        container.host_line = <<-END
% if tags.find{|t| t.key == 'Name' }.value
  <%- if tags.find{|t| t.key == 'Name' }.value == 'srv3' -%>
Host <%= tags.find{|t| t.key == 'Name' }.value %>
  HostName <%= tags.find{|t| t.key == 'Name' }.value %>
  <%- end -%>
% end
        END
      end

      it do
        expect(builder.build_host_lines).to eq <<-END.rstrip
# section: key1
# section: key2
Host srv3
  HostName srv3
        END
      end
    end
  end
end
