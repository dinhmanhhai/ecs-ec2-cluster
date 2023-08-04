#Global
environment = "dev"
aws_region  = "us-east-1"
project     = "demo"

#Service-ecs
assign_public_ip_for_tasks = false

#Task definition
networkMode              = "bridge"
requires_compatibilities = ["EC2"] #["FARGATE"]
task_cpu                 = 2048
task_memory              = 2048

#Ecr
ecr_names        = ["spring-app", "node-js"]
image_mutability = "MUTABLE" #"IMMUTABLE"
encryption_type  = "KMS"
container_port_mapping = {
  spring-app : 9090,
  node-js : 80,
}
cluster_settings = {
  name  = "containerInsights"
  value = "disabled"
}

#Alb
deregistration_delay = 300
health_check_path    = {
  spring-app : "/spring/haidm"
  node-js : "/node"
}
target_type          = "ip" # instance lambda
path_mapping = {
  spring-app : "/spring/*",
  node-js : "/node/*",
}

#S3
bucket_name = "haidm-infra-remote-state"

#Network
create_nat = false
subnet_count = {
  public  = 2,
  private = 2
}
num_of_azs           = ["a", "b"]
vpc_cidr             = "11.0.0.0/16"
public_subnet_cidrs  = ["11.0.0.0/24", "11.0.1.0/24", "11.0.2.0/24", "11.0.3.0/24"]
private_subnet_cidrs = ["11.0.50.0/24", "11.0.51.0/24", "11.0.52.0/24", "11.0.53.0/24"]

#Ec2
key_name      = "haidm"
instance_type = "t3a.small"
aws_ami_id    = "ami-0f5bf24b7bc6002ff"
volume_type   = "gp3"
cluster_names = ["app"]
#max_size = 1
#min_size = 1
#desired_capacity = 1

#Code build
branch_match = {
  dev: "dev",
  stg: "stg",
  prod: "master"
}
insecure_ssl = false
badge_enabled = false
build_timeout = "5"
cache_bucket_name = "all-cache-and-log"
env_vars= {
  spring-app: [
    {
      name: "REPOSITORY_URI",
      value: "400516100932.dkr.ecr.us-east-1.amazonaws.com/spring-app"
      type: "PLAINTEXT"
    },
    {
      name: "DOMAIN",
      value: "400516100932.dkr.ecr.us-east-1.amazonaws.com"
      type: "PLAINTEXT"
    }
  ],
  node-js: [
    {
      name: "REPOSITORY_URI",
      value: "400516100932.dkr.ecr.us-east-1.amazonaws.com/node-js"
      type: "PLAINTEXT"
    },
    {
      name: "DOMAIN",
      value: "400516100932.dkr.ecr.us-east-1.amazonaws.com"
      type: "PLAINTEXT"
    }
  ]
}
artifacts_type = "NO_ARTIFACTS"
privileged_mode = true

# Code pipeline
stage_deploy_configure = {
  spring-app : {
    ClusterName : "demo-dev-app-cluster"
    FileName : "imagedefinitions.json"
    ServiceName: "demo-dev-spring-app"
  }
  node-js : {
    ClusterName : "demo-dev-app-cluster"
    FileName : "imagedefinitions.json"
    ServiceName: "demo-dev-node-js"
  }
}