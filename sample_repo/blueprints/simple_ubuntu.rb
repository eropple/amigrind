description 'an empty Ubuntu build with no provisioners'

source :ami do
  family :ubuntu
  version '14.04'

  ids \
    'ap-northeast-1': 'ami-7eddd510',
    'ap-southeast-1': 'ami-4ad81329',
    'ap-southeast-2': 'ami-5e72523d',
    'eu-central-1':   'ami-d19e79be',
    'eu-west-1':      'ami-b0c379c3',
    'sa-east-1':      'ami-d86ae7b4',
    'us-east-1':      'ami-c80b0aa2',
    'us-west-1':      'ami-fb394b9b',
    'us-west-2':      'ami-21b85141',
    'cn-north-1':     'ami-3378b15e',
    'us-gov-west-1':  'ami-d6bbd9f5'
end

build_channel :prerelease

aws do
  instance_type 't2.micro'
  ssh_username 'ubuntu'

  associate_public_ip_address true
end

provisioner :drop_time, RemoteShell do
  run_as_root!

  command <<-CMD
    echo "`date`" > /BUILD_TIME
    echo "built by Amigrind v#{Amigrind::VERSION}" > /AMIGRIND
  CMD
end
