include "root" {
    path = find_in_parent_folders("root.hcl")
}

locals {
    env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
    source = "${get_repo_root()}/modules/network"
}

inputs = {
    environment = local.env_vars.locals.environment
    vpc_cidr    = "10.0.0.0/16"
    azs         = ["us-east-1a", "us-east-1b", "us-east-1c"]
    public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    app_subnet_cidrs    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    data_subnet_cidrs   = ["10.0.8.0/24", "10.0.9.0/24", "10.0.10.0/24"]
}
