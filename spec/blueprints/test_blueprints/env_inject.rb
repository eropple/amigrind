aws do
  ssh_username properties[:ssh_username]
end

provisioner :foo, LocalShell do
  command properties[:cmd_test]
end