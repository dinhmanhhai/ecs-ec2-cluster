#!/bin/bash
# Get input parameters
read -p "Enter aws profile name: " aws_profile
read -p "Enter environment: " environment
read -p "Enter region: " aws_region
read -p "Enter s3 terraform bucket name: " s3_bucket # "all-cache-and-log"

cd ../envs/${environment}
echo "Create s3 bucket if not exists"
# create_bucket_if_not_exists
aws --profile $aws_profile s3api get-bucket-location --region $aws_region --bucket $s3_bucket || aws --profile $aws_profile s3api create-bucket --region $aws_region --bucket $s3_bucket --create-bucket-configuration LocationConstraint=$aws_region

# Update Terraform Backend
echo "Updating terraform file..."
sed -i "s/profile.*/profile = \"$aws_profile\"/" terraform.tf

terraform init \
  -backend-config="bucket=${s3_bucket}" \
  -backend-config="region=${aws_region}" \
  -backend-config="key=${environment}/terraform.state" \
  -backend-config="profile=${aws_profile}" \
  -backend-config="shared_credentials_file=~/.aws/credentials"