#!/bin/bash

# Variables
LT_NAME="gpu-node-20251209171411934000000001"
VPC_ID="vpc-028332705aad873f5"

# Pick latest LT version
LT_VERSION=$(aws ec2 describe-launch-template-versions \
  --launch-template-name $LT_NAME \
  --query "LaunchTemplateVersions[-1].VersionNumber" \
  --output text)

echo "Latest LT version: $LT_VERSION"

# Pick a public subnet
PUBLIC_SUBNET=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=MapPublicIpOnLaunch,Values=true" \
  --query "Subnets[0].SubnetId" --output text)

echo "Public Subnet: $PUBLIC_SUBNET"

# Launch EC2 instance
aws ec2 run-instances \
  --launch-template LaunchTemplateName=$LT_NAME,Version=$LT_VERSION \
  --subnet-id $PUBLIC_SUBNET \
  --associate-public-ip-address \
  --count 1 \
  --output json
