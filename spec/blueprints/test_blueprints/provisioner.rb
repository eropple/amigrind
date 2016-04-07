provisioner :simple_test, LocalShell, weight: 100 do
  command "ls -la; whoami; ps"
end
