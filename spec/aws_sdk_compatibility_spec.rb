require 'spec_helper'
require 'aws-sdk-v1'
require 'ec2ssh/ec2_instances'

describe 'aws-sdk compatibility' do
  let(:region) { 'us-west-1' }
  let(:root_device) { '/dev/xvda' }

  let!(:ec2_instances) do
    VCR.use_cassette('ec2-instances') do
      Ec2ssh::Ec2Instances.new(
        {'foo' => {access_key_id: '', secret_access_key: ''}},
        ['us-west-1']
      ).instances('foo')
    end
  end

  let(:ins) { ec2_instances.first }

  it { expect(ec2_instances.count).to be == 1 }

  it { expect(ins.ami_launch_index).to be == 0 }
  it { expect(ins.architecture).to be == :x86_64 }
  it { expect(ins.attachments.to_h).to match( root_device => an_instance_of(AWS::EC2::Attachment) ) }
  it { expect(ins.availability_zone).to match /\A#{region}[a-c]\z/ }
  it { expect(ins.block_device_mappings.to_h).to match( root_device => an_instance_of(AWS::EC2::Attachment) ) }
  it do
    expect(ins.block_devices.to_a).to match [{
      device_name: root_device,
      ebs: {
        volume_id: /\Avol-\w+\z/,
        status: 'attached',
        attach_time: an_instance_of(Time),
        delete_on_termination: true
      }
    }]
  end
  it { expect(ins.client_token).to match /\A\w{18}\z/ }
  it { expect(ins.dedicated_tenancy?).to be_falsy }
  it { expect(ins.dns_name).to match /\Aec2-[\d\.\-]+\.#{region}\.compute\.amazonaws\.com\z/ }
  it { expect(ins.ebs_optimized).to be_falsy }
  it do
    expect(ins.group_set.to_a).to all match(
      group_id: /\Asg-\w+\z/,
      group_name: /\A.+\z/,
    )
  end
  it { expect(ins.groups.to_a).to all match(AWS::EC2::SecurityGroup) }
  it { expect(ins.hypervisor).to be == :xen }
  it { expect(ins.iam_instance_profile_arn).to match /\Aarn:aws:iam::\d+:instance-profile\/[\w\-]+\z/ }
  it { expect(ins.iam_instance_profile_id).to match /\A\w{21}\z/ }
  it { expect(ins.id).to match /\Ai-\w+\z/ }
  it { expect(ins.image).to be_a(AWS::EC2::Image) }
  it { expect(ins.image_id).to match /\Aami-\w+\z/ }
  it { expect(ins.instance_id).to match /\Ai-\w+\z/ }
  it { expect(ins.instance_lifecycle).to be_nil }
  it { expect(ins.instance_type).to match /\A[trmci][1248]\.\w+\z/ }
  it { expect(ins.ip_address).to match /\A[\d\.]+\z/ }
  it { expect(ins.kernel_id).to be_nil }
  it { expect(ins.key_name).to match /\A.+\.pem\z/ }
  it { expect(ins.key_pair).to be_a(AWS::EC2::KeyPair) }
  it { expect(ins.launch_time).to be_a(Time) }
  it { expect(ins.monitoring).to be == :disabled }
  it { expect(ins.monitoring_enabled?).to be_falsy }
  it { expect(ins.network_interfaces.to_a).to all match(an_instance_of(AWS::EC2::NetworkInterface)) }
  # it { expect(ins.owner_id).to match /\A\d{12}\z/ }
  it { expect(ins.placement.to_h).to match( availability_zone: /\A#{region}[a-c]\z/, group_name: nil, tenancy: 'default' ) }
  it { expect(ins.platform).to be_nil }
  it { expect(ins.private_dns_name).to match /\Aip-[\w\-]+\.#{region}\.compute\.internal\z/ }
  it { expect(ins.private_ip_address).to match /\A[\d\.]+\z/ }
  it { expect(ins.product_codes).to be == [] }
  it { expect(ins.public_dns_name).to match /\Aec2-[\w\-]+\.#{region}\.compute\.amazonaws\.com\z/ }
  it { expect(ins.public_ip_address).to match /\A[\d\.]+\z/ }
  it { expect(ins.ramdisk_id).to be_nil }
  it { expect(ins.requester_id).to be_nil }
  # it { expect(ins.reservation_id).to match /\Ar-\w+\z/ }
  it { expect(ins.root_device_name).to eq root_device }
  it { expect(ins.root_device_type).to be == :ebs }
  it { expect(ins.security_groups.to_a).to all match(an_instance_of(AWS::EC2::SecurityGroup)) }
  it { expect(ins.spot_instance?).to be_falsy }
  it { expect(ins.state_transition_reason).to be_nil }
  it { expect(ins.status).to be == :running }
  it { expect(ins.status_code).to be == 16 }
  it { expect(ins.subnet).to be_a(AWS::EC2::Subnet) }
  it { expect(ins.subnet_id).to match /\Asubnet-\w+\z/ }
  it { expect(ins.virtualization_type).to be == :hvm }
  it { expect(ins.vpc).to be_a(AWS::EC2::VPC) }
  it { expect(ins.vpc?).to be_truthy }
  it { expect(ins.vpc_id).to match /\Avpc-\w+\z/ }
end
