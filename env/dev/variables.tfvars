#Global
environment = "dev"
aws_profile = "default"
aws_region = "us-east-1"
project = "demo"

#Ecr
ecr_names = ["spring-app", "node-js"]
image_mutability = "MUTABLE" #"IMMUTABLE"
encryption_type = "KMS"
container_port_mapping = {
  spring-app : 9090,
  node-js : 80,
}

#Alb
deregistration_delay = 300
health_check_path = "/haidm"
target_type = "ip" # instance lambda
path_mapping = {
  spring-app : "/spring/*",
  node-js : "/node/*",
}

#S3
bucket_name = "haidm-infra-remote-state"

#Network
subnet_count = {
  public  = 2,
  private = 2
}
num_of_azs = ["a", "b"]
vpc_cidr = "11.0.0.0/16"
public_subnet_cidrs = ["11.0.0.0/24", "11.0.1.0/24", "11.0.2.0/24", "11.0.3.0/24"]
private_subnet_cidrs = ["11.0.50.0/24", "11.0.51.0/24", "11.0.52.0/24", "11.0.53.0/24"]

#Ec2
key_name = "haidm"
instance_type = "t3a.nano"
aws_ami_id = "ami-0f5bf24b7bc6002ff"
volume_type = "gp3"
cluster_names = ["app"]
#max_size = 1
#min_size = 1
#desired_capacity = 1
