require 'spec_helper'
require 'ec2ssh/dsl'
require 'ec2ssh/builder'

describe Ec2ssh::Builder do
  describe '#build_host_lines' do
    let(:container) do
      Ec2ssh::Dsl::Container.new.tap do |c|
        c.aws_keys = {
          'key1' => { 'us-west-1' => Aws::Credentials.new('KEY1', 'SEC1') },
          'key2' => { 'us-west-1' => Aws::Credentials.new('KEY2', 'SEC2') }
        }
        c.host_line = "Host <%= tag('Name') %>"
      end
    end

    let(:builder) do
      Ec2ssh::Builder.new(container).tap do |bldr|
        allow(bldr).to receive(:ec2s) { ec2s }
      end
    end

    let(:ec2s) do
      double('ec2s', aws_keys: container.aws_keys).tap do |dbl|
        allow(dbl).to receive(:instances) {|name| instances[name] }
      end
    end

    let(:instances) do
      {
        'key1' => [
          double('instance').tap {|m| allow(m).to receive(:tag).with('Name').and_return('srv1') },
          double('instance').tap {|m| allow(m).to receive(:tag).with('Name').and_return('srv2') }
        ],
        'key2' => [
          double('instance').tap {|m| allow(m).to receive(:tag).with('Name').and_return('srv3') },
          double('instance').tap {|m| allow(m).to receive(:tag).with('Name').and_return('srv4') }
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
        container.reject = lambda {|ins| ins.tag('Name') == 'srv1' }
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
% if tag('Name')
  <%- if tag('Name') == 'srv3' -%>
Host <%= tag('Name') %>
  HostName <%= tag('Name') %>
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
