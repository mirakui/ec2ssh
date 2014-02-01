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
  key1:
    access_key_id: ACCESS_KEY1
    secret_access_key: SECRET1
  key2:
    access_key_id: ACCESS_KEY2
    secret_access_key: SECRET2
regions:
- ap-northeast-1
- us-east-1
    END

    it { expect(migrator.check_version).to eq('2') }
    it { expect(migrator.migrate_from_2).to eq(<<-END) }
path '/path/to/ssh/config'
aws_keys(
  key1: { access_key_id: 'ACCESS_KEY1', secret_access_key: 'SECRET1' },
  key2: { access_key_id: 'ACCESS_KEY2', secret_access_key: 'SECRET2' }
)
regions 'ap-northeast-1', 'us-east-1'
host_lines <<EOS
Host <%= tags['Name'] %>.<%= availability_zone %>
  HostName <%= dns_name || private_ip_address %>
EOS

# ---
# path: /path/to/ssh/config
# aws_keys:
#   key1:
#     access_key_id: ACCESS_KEY1
#     secret_access_key: SECRET1
#   key2:
#     access_key_id: ACCESS_KEY2
#     secret_access_key: SECRET2
# regions:
# - ap-northeast-1
# - us-east-1
    END
  end
end
