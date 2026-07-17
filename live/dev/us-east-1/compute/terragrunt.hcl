include {
    path = find_in_parent_folders("root.hcl")
}

locals {
    env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
    source = "${get_repo_root()}/modules/compute"
}

dependency "network" {
    config_path = "../network"

    mock_outputs = {
        vpc_id = "vpc-12345678"
        vpc_cidr = "10.0.0.0/16"
        public_subnet_ids = ["subnet-12345678", "subnet-23456789", "subnet-34567890"]
        app_subnet_ids = ["subnet-12345678", "subnet-23456789", "subnet-34567890"]
        data_subnet_ids = ["subnet-45678901", "subnet-56789012", "subnet-67890123"]
    }

    mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
    environment = local.env_vars.locals.environment
    vpc_id    = dependency.network.outputs.vpc_id
    subnet_id = dependency.network.outputs.app_subnet_ids[0]
    instance_type = "t3.micro"
    ami_id = "ami-0c55b159cbfafe1f0" 
    allowed_ssh_cidr = "105.113.96.224/32"
    vpc_cidr = dependency.network.outputs.vpc_cidr
    public_subnet_ids = dependency.network.outputs.public_subnet_ids
    enable_https = false
    acm_certificate_arn = ""

}

