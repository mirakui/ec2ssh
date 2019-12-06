require 'spec_helper'
require 'ec2ssh/ec2_instances'

describe 'aws-sdk compatibility' do
  let(:region) { 'us-west-1' }
  let(:root_device) { '/dev/xvda' }

  let!(:ec2_instances) do
    VCR.use_cassette('ec2-instances') do
      Ec2ssh::Ec2Instances.new(
        {'foo' => {'us-west-1' => Aws::Credentials.new('access_key_id', 'secret_access_key')}},
        [{ name: 'instance-state-name', values: ['running'] }]
      ).instances('foo')
    end
  end

  let(:ins) { ec2_instances.first }

  it { expect(ec2_instances.count).to be == 1 }

  it { expect(ins.tag('Name')).to match /.+/ }
  it { expect(ins.tag('Role')).to match /.+/ }
  it { expect(ins.tags).to match_array([have_attributes(key: 'Name', value: /.+/), have_attributes(key: 'Role', value: /.+/)]) }
  it { expect(ins.ami_launch_index).to be == 0 }
  it { expect(ins.architecture).to be == 'x86_64' }
  it do
    expect(ins.block_device_mappings).to match [
      have_attributes(
      device_name: root_device,
      ebs: have_attributes(
        volume_id: /\Avol-\w+\z/,
        status: 'attached',
        attach_time: an_instance_of(Time),
        delete_on_termination: true
      )
    )]
  end
  # it { expect(ins.capacity_reservation_id).to be_nil}
  # it { expect(ins.capacity_reservation_specification).to be_nil }
  it { expect(ins.classic_address).to be_a(Aws::EC2::ClassicAddress) }
  it { expect(ins.client).to be_a(Aws::EC2::Client) }
  it { expect(ins.client_token).to match /\A\w{18}\z/ }
  # it { expect(ins.cpu_options).to be_nil }
  it { expect(ins.ebs_optimized).to be_falsy }
  it { expect(ins.elastic_gpu_associations).to be_nil }
  # it { expect(ins.elastic_inference_accelerator_associations).to be_nil }
  it { expect(ins.ena_support).to be_falsy }
  # it { expect(ins.hibernation_options).to be_nil}
  it { expect(ins.hypervisor).to be == 'xen' }
  it { expect(ins.iam_instance_profile).to have_attributes(arn: /\Aarn:aws:iam::\d+:instance-profile\/[\w\-]+\z/, id: /\A\w{21}\z/) }
  it { expect(ins.id).to match /\Ai-\w+\z/ }
  it { expect(ins.image).to be_a(Aws::EC2::Image) }
  it { expect(ins.image_id).to match /\Aami-\w+\z/ }
  it { expect(ins.instance_id).to match /\Ai-\w+\z/ }
  it { expect(ins.instance_lifecycle).to be_nil }
  it { expect(ins.instance_type).to match /\A[trmci][1248]\.\w+\z/ }
  it { expect(ins.kernel_id).to be_nil }
  it { expect(ins.key_name).to match /\A.+\.pem\z/ }
  it { expect(ins.key_pair).to be_a(Aws::EC2::KeyPairInfo) }
  it { expect(ins.launch_time).to be_a(Time) }
  # it { expect(ins.licenses).to all have_attributes(license_configuration_arn: '') }
  it { expect(ins.monitoring).to have_attributes(state: 'disabled') }
  it { expect(ins.network_interfaces).to all match(an_instance_of(Aws::EC2::NetworkInterface)) }
  it { expect(ins.placement).to have_attributes(availability_zone: /\A#{region}[a-c]\z/, group_name: '', tenancy: 'default') }
  it { expect(ins.placement_group).to be_a(Aws::EC2::PlacementGroup) }
  it { expect(ins.platform).to be_nil }
  it { expect(ins.private_dns_name).to match /\Aip-[\w\-]+\.#{region}\.compute\.internal\z/ }
  it { expect(ins.private_ip_address).to match /\A[\d\.]+\z/ }
  it { expect(ins.product_codes).to be == [] }
  it { expect(ins.public_dns_name).to match /\Aec2-[\w\-]+\.#{region}\.compute\.amazonaws\.com\z/ }
  it { expect(ins.public_ip_address).to match /\A[\d\.]+\z/ }
  it { expect(ins.ramdisk_id).to be_nil }
  it { expect(ins.root_device_name).to eq root_device }
  it { expect(ins.root_device_type).to be == 'ebs' }
  it do
    expect(ins.security_groups).to all have_attributes(
      group_id: /\Asg-\w+\z/,
      group_name: /\A.+\z/
    )
  end
  it { expect(ins.source_dest_check).to be true }
  it { expect(ins.spot_instance_request_id).to be_nil }
  it { expect(ins.sriov_net_support).to be_nil }
  it { expect(ins.state).to have_attributes(code: 16, name: 'running') }
  it { expect(ins.state_reason).to be_nil }
  it { expect(ins.state_transition_reason).to be == '' }
  it { expect(ins.subnet).to be_a(Aws::EC2::Subnet) }
  it { expect(ins.subnet_id).to match /\Asubnet-\w+\z/ }
  it { expect(ins.virtualization_type).to be == 'hvm' }
  it { expect(ins.vpc).to be_a(Aws::EC2::Vpc) }
  it { expect(ins.vpc_id).to match /\Avpc-\w+\z/ }
end
