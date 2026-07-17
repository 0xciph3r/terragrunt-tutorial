include "root" {
    path = find_in_parent_folders("root.hcl")
}

locals {
    env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
    source = "${get_repo_root()}/modules/cache"
}

dependency "network" {
    config_path = "../network"

    mock_outputs = {
        vpc_id = "vpc-12345678"
        data_subnet_ids = ["subnet-45678901", "subnet-56789012", "subnet-67890123"]
    }

    mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "compute" {
    config_path = "../compute"

    mock_outputs = {
        app_security_group_id = "sg-12345678"
    }

    mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs ={
    environment = local.env_vars.locals.environment
    vpc_id = dependency.network.outputs.vpc_id
    data_subnet_ids = dependency.network.outputs.data_subnet_ids
    allowed_app_security_group_id = dependency.compute.outputs.app_security_group_id
    engine_version = "6.x"
    node_type = "cache.t3.micro"
}