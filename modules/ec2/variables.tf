variable "project_name" {
  description = "Name prefix for EC2 resources."
  type        = string
}

variable "ami_id" {
  description = "AMI used to launch the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which the security group is created."
  type        = string
}

variable "subnet_id" {
  description = "Subnet in which the instance is launched."
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key-pair name."
  type        = string
  default     = null
  nullable    = true
}

variable "associate_public_ip" {
  description = "Assign a public IPv4 address to the instance."
  type        = bool
  default     = true
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs permitted to connect using SSH."
  type        = list(string)
  default     = []
}

variable "allowed_http_cidrs" {
  description = "CIDRs permitted to connect using HTTP."
  type        = list(string)
  default     = []
}

variable "root_volume_size" {
  description = "Root volume size in GiB."
  type        = number
  default     = 20
}

variable "user_data" {
  description = "Optional startup script."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Additional tags for EC2 resources."
  type        = map(string)
  default     = {}
}

