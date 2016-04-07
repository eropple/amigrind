require 'spec_helper'

describe Amigrind::Blueprints::Evaluator do
  it 'should load an empty evaluator and do nothing' do
    bp = Amigrind::Blueprints::Evaluator.evaluate("#{__dir__}/test_blueprints/empty.rb")

    expect(bp.source).to be_nil
    expect(bp.aws.class).to be(Amigrind::Blueprints::AWSConfig)
    expect(bp.provisioners).to eq([])
  end

  it 'should inject environment parameters' do
    env = Amigrind::Environments::Environment.new
    env.name = 'test'
    env.properties[:ssh_username] = 'dork'
    env.properties[:cmd_test] = 'floop'

    bp = Amigrind::Blueprints::Evaluator.evaluate("#{__dir__}/test_blueprints/env_inject.rb", env)
    expect(bp.aws.ssh_username).to eq(env.properties[:ssh_username])
    expect(bp.provisioners.first.inline).to eq([ 'floop' ])
  end

  it 'should handle description calls' do
    bp = Amigrind::Blueprints::Evaluator.evaluate("#{__dir__}/test_blueprints/description.rb")

    expect(bp.description).to eq('test description')
  end

  it 'should handle build_channel calls' do
    bp = Amigrind::Blueprints::Evaluator.evaluate("#{__dir__}/test_blueprints/build_channel.rb")

    expect(bp.build_channel).to eq(:bob)
  end

  it 'should handle "source :ami" blocks' do
    bp = Amigrind::Blueprints::Evaluator.evaluate("#{__dir__}/test_blueprints/source_ami.rb")

    expect(bp.source.class).to be(Amigrind::Blueprints::BaseAMISource)
    expect(bp.source.family).to eq(:ubuntu)
    expect(bp.source.version).to eq('14.04')
    expect(bp.source.ids).to eq(
      "us-east-1" => "ami-aabbccdd",
      "us-west-2" => "ami-11223344",
      "us-west-1" => "ami-22334455"
    )
  end

  it 'should handle "source :parent" calls' do
    bp1 = Amigrind::Blueprints::Evaluator.evaluate("#{__dir__}/test_blueprints/source_parent.rb")

    expect(bp1.source.name).to eq('web_base')
    expect(bp1.source.channel).to eq(:live)
  end

  it 'should handle AWS blocks' do
    bp = Amigrind::Blueprints::Evaluator.evaluate("#{__dir__}/test_blueprints/aws_full.rb")

    expect(bp.aws.instance_type).to eq('t2.micro')
    expect(bp.aws.ssh_username).to eq('ubuntu')

    expect(bp.aws.ebs_optimized).to eq(true)
    expect(bp.aws.enhanced_networking).to eq(true)
    expect(bp.aws.iam_instance_profile).to eq('foobar')

    expect(bp.aws.copy_regions).to eq([ 'us-east-1', 'us-west-2' ])

    expect(bp.aws.ssh_keypair_name).to eq('keypair_name')
    expect(bp.aws.ssh_private_ip).to eq(false)
    expect(bp.aws.user_data).to eq('boop')

    expect(bp.aws.security_group_ids).to eq([ 'sg-aabbccdd' ])

    expect(bp.aws.run_tags).to eq('k1' => 'v1')
    expect(bp.aws.run_volume_tags).to eq('kv1' => 'vv1')

    expect(bp.aws.custom[:scalar]).to eq(5)
    expect(bp.aws.custom[:arr]).to eq([1, 2, 3])
    expect(bp.aws.custom[:hsh]).to eq(:a => 5, 10 => 15)
  end

  it 'should handle provisioner blocks' do
    bp = Amigrind::Blueprints::Evaluator.evaluate("#{__dir__}/test_blueprints/provisioner.rb")

    expect(bp.provisioners.size).to eq(1)

    prov = bp.provisioners[0]
    expect(prov.name).to eq('simple_test')
    expect(prov.weight).to eq(100)
    expect(prov.inline).to eq([ "ls -la; whoami; ps" ])
  end
end
