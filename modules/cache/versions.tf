terraform {
    required_version = ">= 1.0.0, < 2.0.0"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.40, < 5.60"
        }
    }

    backend "local" {}
}