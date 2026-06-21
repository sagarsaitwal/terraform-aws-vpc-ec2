# AWS VPC and EC2 with Terraform

This repository is a reusable Terraform starter project for creating a small AWS environment. The code is split into separate files and modules so that it is easy to read, change, and troubleshoot, even if this is your first Terraform project.

By default, the template creates a VPC across two Availability Zones and launches one EC2 instance in the first public subnet. Values such as the AWS Region, AMI, instance type, subnet ranges, and allowed IP addresses are controlled through `terraform.tfvars`.

> This is a learning and starter template. Before using it for production, review your security, availability, logging, backup, and cost requirements.

## What this project creates

The VPC module creates:

- One VPC with DNS support and DNS hostnames enabled
- Two public subnets by default
- Two private subnets by default
- One Internet Gateway
- Public and private route tables
- An optional NAT Gateway for outbound access from private subnets

The EC2 module creates:

- One EC2 instance in the first public subnet
- One security group for SSH and HTTP
- An encrypted GP3 root EBS volume
- A public IPv4 address, enabled by default
- IMDSv2 enforcement for instance metadata

The EC2 instance is public to make the example easy to test. In production, application servers are commonly placed in private subnets and reached through a load balancer, VPN, AWS Systems Manager, or a controlled bastion host.

## Project structure

```text
.
|-- main.tf                       Connects the VPC and EC2 modules
|-- providers.tf                  Configures the AWS provider and default tags
|-- versions.tf                   Defines Terraform and provider versions
|-- variables.tf                  Declares project-level input variables
|-- outputs.tf                    Displays useful values after deployment
|-- terraform.tfvars.example      Example values to copy and customize
|-- modules/
|   |-- vpc/
|   |   |-- main.tf               VPC, subnets, gateways, and routes
|   |   |-- variables.tf          VPC module inputs
|   |   `-- outputs.tf            VPC module outputs
|   `-- ec2/
|       |-- main.tf               EC2 instance and security group
|       |-- variables.tf          EC2 module inputs
|       `-- outputs.tf            EC2 module outputs
`-- README.md
```

The root `main.tf` passes your values into both modules. The VPC module returns the VPC and subnet IDs, and the EC2 module uses those outputs automatically. You do not need to copy resource IDs between modules.

## Prerequisites

Before running this project, you need:

1. An AWS account with permission to create VPC, EC2, EBS, security group, Elastic IP, and NAT Gateway resources.
2. Terraform 1.5 or later installed and available in your terminal.
3. AWS credentials configured on your computer.
4. An existing EC2 key pair if you want to connect through SSH.
5. A valid AMI ID for the AWS Region you plan to use.

Check your tools and AWS identity:

```powershell
terraform version
aws --version
aws sts get-caller-identity
```

The last command shows the AWS account and identity Terraform will use. Do not continue if it fails or shows the wrong account.

### Using this repository without an AWS account

You can still study, customize, and publish this project without AWS credentials. After installing Terraform, `terraform init`, `terraform fmt -recursive`, and `terraform validate` can be used to check the project locally. Do not run `terraform plan` or `terraform apply` until you have permission to use an AWS account.

This template has not been deployed to a live AWS environment. That limitation is documented intentionally so readers can distinguish code review and local validation from a real infrastructure test.

## Configure the project

Open PowerShell in the project folder:

```powershell
Set-Location "D:\Terraform Project"
```

Create your local variables file:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` and replace the example values. At minimum, review the following settings:

| Variable | What it controls | Example |
|---|---|---|
| `aws_region` | AWS Region for all resources | `ap-south-1` |
| `project_name` | Prefix used in names and tags | `demo-web` |
| `availability_zones` | Zones used by the subnets | `["ap-south-1a", "ap-south-1b"]` |
| `public_subnet_cidrs` | Address ranges for public subnets | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | Address ranges for private subnets | `["10.0.11.0/24", "10.0.12.0/24"]` |
| `ami_id` | Region-specific image for EC2 | `ami-0123456789abcdef0` |
| `instance_type` | Size of the EC2 instance | `t3.micro` |
| `key_name` | Existing EC2 key-pair name | `my-key-pair` |
| `allowed_ssh_cidrs` | Networks allowed to use SSH | `["203.0.113.10/32"]` |
| `allowed_http_cidrs` | Networks allowed to use HTTP | `["0.0.0.0/0"]` |
| `enable_nat_gateway` | Private-subnet outbound internet access | `false` |

Important notes:

- AMI IDs are Region-specific. An AMI from `us-east-1` will not work in `ap-south-1`.
- Provide one public and one private subnet CIDR for each Availability Zone.
- Every subnet must be inside `vpc_cidr`, and subnet ranges must not overlap.
- Replace the example SSH CIDR with your real public IP followed by `/32`.
- Never use `0.0.0.0/0` for SSH because it exposes port 22 to the entire internet.
- If SSH is unnecessary, set `key_name = null` and `allowed_ssh_cidrs = []`.
- NAT Gateway creation is disabled by default because AWS charges for it.

## Deploy the infrastructure

### 1. Initialize Terraform

This downloads the AWS provider and prepares the modules:

```powershell
terraform init
```

### 2. Format and validate

```powershell
terraform fmt -recursive
terraform validate
```

Formatting keeps the files consistent. Validation catches many configuration and syntax problems before AWS resources are changed.

### 3. Review the plan

```powershell
terraform plan -out main.tfplan
```

Read the plan carefully. Confirm the Region, CIDR ranges, instance type, and number of resources. The plan is your chance to catch an unsafe or expensive setting.

### 4. Apply the plan

```powershell
terraform apply main.tfplan
```

Terraform creates the network first and then launches the EC2 instance. When it finishes, it prints the VPC ID, subnet IDs, instance ID, security group ID, and IP addresses.

Display the outputs again with:

```powershell
terraform output
```

## Connect to the EC2 instance

Get its public IP:

```powershell
terraform output -raw ec2_public_ip
```

For Amazon Linux, a typical SSH command is:

```powershell
ssh -i "C:\path\to\your-key.pem" ec2-user@PUBLIC_IP
```

The username depends on the selected AMI. Ubuntu images commonly use `ubuntu` instead of `ec2-user`. The private key must match the key pair named in `terraform.tfvars`.

Opening port 80 does not install a web server. Use the optional `user_data` value or configure the instance after launch if you want it to serve a website.

## Change the environment

Edit `terraform.tfvars`, then run:

```powershell
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Always review the plan. Some changes may replace the EC2 instance instead of updating it in place.

## Remove the environment

Preview the resources that Terraform will delete:

```powershell
terraform plan -destroy
```

Then remove them:

```powershell
terraform destroy
```

Review the destroy plan and type `yes` only when you are sure. Check the AWS Console afterward, especially if you enabled a NAT Gateway or Elastic IP.

## State and sensitive files

Terraform records managed resources in `terraform.tfstate`. Treat state files as sensitive because they may contain infrastructure details and sensitive values.

- Do not edit Terraform state manually.
- Do not commit state files, plan files, or `terraform.tfvars` containing private values.
- Never place AWS access keys directly in Terraform code.
- For team environments, use an approved remote state backend with locking instead of sharing local state files.

## Cost considerations

This project can create billable AWS resources. The main cost areas are:

- EC2 instance runtime
- EBS volume storage
- Public IPv4 address usage
- NAT Gateway hourly usage and data processing, when enabled
- Data transfer

Destroy test environments when they are no longer needed, and review AWS pricing for your selected Region before running long-lived workloads.

## Common problems

### `terraform` is not recognized

Terraform is not installed or its directory is missing from `PATH`. Install it, restart PowerShell, and run `terraform version` again.

### `No valid credential sources found`

AWS credentials are missing or expired. Configure them using the AWS CLI, your approved login process, or an IAM role. Test the result with `aws sts get-caller-identity`.

### `InvalidAMIID.NotFound`

The AMI does not exist in the selected Region or your account cannot use it. Choose an AMI available in the same Region as `aws_region`.

### `InvalidKeyPair.NotFound`

The configured `key_name` does not match an existing key pair in the selected Region. EC2 key pairs are Region-specific.

### SSH times out

Confirm that the instance has a public IP, the security group contains your current public IP with `/32`, and the subnet uses the public route table. Your public IP may have changed since the deployment.

### Subnet validation fails

Check that every subnet belongs inside `vpc_cidr`, none of the ranges overlap, and both subnet lists contain one entry per Availability Zone.

## Useful next improvements

Once the basic deployment works, you can extend it by:

- Moving EC2 instances into private subnets
- Using AWS Systems Manager instead of SSH
- Adding an Application Load Balancer and HTTPS certificate
- Adding Auto Scaling across both Availability Zones
- Storing Terraform state remotely with locking
- Adding CloudWatch logs, alarms, and VPC Flow Logs
- Adding least-privilege IAM roles
- Running formatting and validation in a CI pipeline
