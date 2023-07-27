resource "aws_instance" "ec2_instance" {
  ami           = var.aws_ami_id
  count         = 1
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_ids[count.index]
  instance_type = var.instance_type
  key_name      = var.key_name
}