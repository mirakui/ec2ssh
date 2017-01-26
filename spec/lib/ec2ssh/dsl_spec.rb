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
    its(:regions) { should == ['ap-northeast-1', 'us-east-1'] }
    its(:host_line) { should == 'host lines' }
    it { expect(result.reject.call(123)).to eq(123) }
    its(:path) { should == 'path' }
  end
end
