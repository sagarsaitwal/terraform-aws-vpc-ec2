module "vpc" {
  source = "./modules/vpc"

  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidr
  availability_zones      = var.availability_zones
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  enable_nat_gateway      = var.enable_nat_gateway
  enable_dns_support      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true
  tags                    = var.common_tags
}

module "ec2" {
  source = "./modules/ec2"

  project_name            = var.project_name
  ami_id                  = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = module.vpc.public_subnet_ids[0]
  vpc_id                  = module.vpc.vpc_id
  key_name                = var.key_name
  associate_public_ip     = true
  allowed_ssh_cidrs       = var.allowed_ssh_cidrs
  allowed_http_cidrs      = var.allowed_http_cidrs
  root_volume_size        = var.root_volume_size
  user_data               = var.user_data
  tags                    = var.common_tags

  depends_on = [module.vpc]
}
