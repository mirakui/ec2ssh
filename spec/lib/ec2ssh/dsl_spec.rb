require 'spec_helper'
require 'ec2ssh/dsl'

describe Ec2ssh::Dsl do
  context 'with profiles' do
    let(:dsl_str) do
<<-END
profiles 'default', 'myprofile'
regions 'ap-northeast-1', 'us-east-1'
host_line 'host lines'
reject {|instance| instance }
path 'path'
END
    end

    subject(:result) { Ec2ssh::Dsl::Parser.parse dsl_str }

    its(:profiles) { should == ['default', 'myprofile'] }
    its(:aws_keys) { should be_nil }
    its(:regions) { should == ['ap-northeast-1', 'us-east-1'] }
    its(:host_line) { should == 'host lines' }
    it { expect(result.reject.call(123)).to eq(123) }
    its(:path) { should == 'path' }
  end

  context 'with aws_keys' do
    let(:dsl_str) do
<<-END
aws_keys(
  key1: { access_key_id: 'ACCESS_KEY1', secret_access_key: 'SECRET1' },
  key2: { access_key_id: 'ACCESS_KEY2', secret_access_key: 'SECRET2' }
)
regions 'ap-northeast-1', 'us-east-1'
host_line 'host lines'
reject {|instance| instance }
path 'path'
END
    end

    subject(:result) { Ec2ssh::Dsl::Parser.parse dsl_str }

    its(:profiles) { should be_nil }
    its(:aws_keys) do
      should == {
        key1: { access_key_id: 'ACCESS_KEY1', secret_access_key: 'SECRET1' },
        key2: { access_key_id: 'ACCESS_KEY2', secret_access_key: 'SECRET2' }
      }
    end
    its(:regions) { should == ['ap-northeast-1', 'us-east-1'] }
    its(:host_line) { should == 'host lines' }
    it { expect(result.reject.call(123)).to eq(123) }
    its(:path) { should == 'path' }
  end

  context 'with profiles and aws_keys both' do
    let(:dsl_str) do
<<-END
aws_keys(
  key1: { access_key_id: 'ACCESS_KEY1', secret_access_key: 'SECRET1' },
  key2: { access_key_id: 'ACCESS_KEY2', secret_access_key: 'SECRET2' }
)
profiles 'default', 'myprofile'
regions 'ap-northeast-1', 'us-east-1'
host_line 'host lines'
reject {|instance| instance }
path 'path'
END
    end

    it do
      expect { Ec2ssh::Dsl::Parser.parse dsl_str }.to raise_error Ec2ssh::DotfileValidationError
    end
  end
end
