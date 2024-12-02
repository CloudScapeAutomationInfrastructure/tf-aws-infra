# AWS Infrastructure with Terraform

This repository contains Terraform configurations to set up AWS infrastructure.

## Instructions

- Ensure Terraform is installed.
- Run `terraform init` to initialize.
- Run `terraform apply` to create the infrastructure.


Command to Import the Certificate
Run the following command to import the certificate into ACM:

aws acm import-certificate \
    --certificate fileb://demo.awsclouddomainname.me.crt \
    --private-key fileb://demo.awsclouddomainname.me.key \
    --certificate-chain fileb://demo.awsclouddomainname.me.ca-bundle \
    --region us-east-2