source :ami do
  family :ubuntu
  version '14.04'

  ids \
    "us-east-1" => "ami-aabbccdd",
    "us-west-2" => "ami-11223344"

  id "us-west-1", "ami-22334455"
end
