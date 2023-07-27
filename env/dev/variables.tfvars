#Global
environment = "dev"
aws_profile = "default"
aws_region = "us-east-1"
project = "demo"

#Ecr
spring_container = "my-spring-app"

#S3
bucket_name = "haidm-infra-remote-state"

#Network
subnet_count = {
  public  = 4,
  private = 4
}
num_of_azs = ["a", "b"]
vpc_cidr = "11.0.0.0/16"
public_subnet_cidrs = ["11.0.0.0/24", "11.0.1.0/24", "11.0.2.0/24", "11.0.3.0/24"]
private_subnet_cidrs = ["11.0.50.0/24", "11.0.51.0/24", "11.0.52.0/24", "11.0.53.0/24"]

#Ecs
key_name = "haidm"
instance_type = "t2.micro"
aws_ami_id = "ami-04823729c75214919"
#max_size = 1
#min_size = 1
#desired_capacity = 1
