source :parent do
  name 'simple_ubuntu'
  channel :live
end

build_channel :prerelease

aws do
  instance_type 't2.micro'
  ssh_username 'ubuntu'

  associate_public_ip_address true
end

provisioner :something_else, RemoteShell do
  run_as_root!

  command <<-CMD
    echo "dependent_ubuntu" > /MACHINE_TYPE
  CMD
end
