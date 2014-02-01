require 'spec_helper'
require 'ec2ssh/migrator'

describe Ec2ssh::Migrator do
  subject(:migrator) { described_class.new '/dotfile' }

  before do
    File.open('/dotfile', 'w') {|f| f.write dotfile_str }
  end

  context 'from version 2' do
    let(:dotfile_str) { <<-END }
---
path: /path/to/ssh/config
aws_keys:
  default:
    access_key_id: ACCESS_KEY1
    secret_access_key: SECRET1
regions:
- ap-northeast-1
    END

    its(:check_version) { should eq('2') }
  end
end
