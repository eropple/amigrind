require 'spec_helper'

describe Amigrind::Environments::Environment do
  it "loads from YAML" do
    env = Amigrind::Environments::Environment \
      .load_yaml_file("#{__dir__}/test_environments/yaml_read.yaml")

    channels = env.channels
    expect(channels.size).to eq(2)
    expect(channels['prerelease'].name).to eq('prerelease')
    expect(channels['live'].name).to eq('live')

    aws = env.aws
    expect(aws.region).to eq('us-west-2')
    expect(aws.copy_regions).to eq([ 'us-east-1' ])
    expect(aws.vpc).to eq('vpc-AABBCCDD')
    expect(aws.subnets).to eq([ 'subnet-AABBCCDD' ])
    expect(aws.ssh_keypair_name).to eq('moop')

    expect(env.properties).to eq(a: 5)
  end
end
