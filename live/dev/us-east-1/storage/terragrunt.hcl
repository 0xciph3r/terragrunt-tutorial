include "root" {
    path = find_in_parent_folders("root.hcl")
}

locals {
    env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
    source = "${get_repo_root()}/modules/storage"
}

inputs = {
    environment       = local.env_vars.locals.environment
    bucket_name_prefix = "myapp"
    force_destroy      = false
}