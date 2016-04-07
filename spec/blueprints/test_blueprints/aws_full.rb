aws do
  instance_type 't2.micro'
  ssh_username 'ubuntu'

  # Maps to "ami_regions" in Packer, because "ami_regions" is a bad name.
  copy_regions [ 'us-east-1', 'us-west-2' ]

  ebs_optimized true
  enhanced_networking true
  iam_instance_profile 'foobar'

  ssh_keypair_name 'keypair_name'
  ssh_private_ip false
  user_data 'boop'

  run_tag 'k1', 'v1'
  run_volume_tag 'kv1', 'vv1'

  vpc 'vpc-12341234'
  subnet 'subnet-abcdabcd'
  subnet 'subnet-12341234'
  security_group 'sg-aabbccdd'

  custom :scalar, 5
  custom :arr, [ 1, 2, 3 ]
  custom :hsh, { :a => 5, 10 => 15 }
end
