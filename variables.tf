variable "aws_region" {
  description = "AWS region in which resources will be created."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short name used in resource names and tags."
  type        = string
  default     = "terraform-demo"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the subnets."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "One public-subnet CIDR for each availability zone."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "One private-subnet CIDR for each availability zone."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "enable_nat_gateway" {
  description = "Create one NAT gateway so private subnets can reach the internet. This incurs AWS charges."
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. AMIs are region-specific."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.ami_id))
    error_message = "ami_id must look like ami-0123456789abcdef0."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair. Use null if SSH is disabled."
  type        = string
  default     = null
  nullable    = true
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed to connect on port 22. Prefer your public IP with /32."
  type        = list(string)
  default     = []
}

variable "allowed_http_cidrs" {
  description = "CIDRs allowed to connect on port 80. Leave empty to disable HTTP ingress."
  type        = list(string)
  default     = []
}

variable "root_volume_size" {
  description = "Size of the encrypted root EBS volume in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "root_volume_size must be at least 8 GiB."
  }
}

variable "user_data" {
  description = "Optional cloud-init or shell script executed when the instance first starts."
  type        = string
  default     = null
  nullable    = true
}

variable "common_tags" {
  description = "Tags applied to all supported AWS resources."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

