require 'spec_helper'
require 'ec2ssh/dsl'

describe Ec2ssh::Dsl do
  let(:dsl) do
    described_class.new.tap do |_dsl|
      _dsl.aws_keys(
        { access_key_id: 'ACCESS_KEY1', secret_access_key: 'SECRET1' },
        { access_key_id: 'ACCESS_KEY2', secret_access_key: 'SECRET2' }
      )
      _dsl.regions 'ap-northeast-1', 'us-east-1'
      _dsl.host_lines 'host lines'
      _dsl.reject {|instance| instance }
      _dsl.path 'path'
    end
  end

  subject(:result) { dsl.result }

  its(:aws_keys) do
    should == [
      { access_key_id: 'ACCESS_KEY1', secret_access_key: 'SECRET1' },
      { access_key_id: 'ACCESS_KEY2', secret_access_key: 'SECRET2' }
    ]
  end
  its(:regions) { should == ['ap-northeast-1', 'us-east-1'] }
  its(:host_lines) { should == 'host lines' }
  it { expect(result.reject.call(123)).to eq(123) }
  its(:path) { should == 'path' }
end
