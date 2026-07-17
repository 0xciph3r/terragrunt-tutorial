variable "environment" {
  description = "The environment for which the cache is being configured (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "The ID of the VPC where the cache will be deployed."
  type        = string
}

variable "data_subnet_ids" {
  description = "The IDs of the subnets where the cache will be deployed."
  type        = list(string)

  validation {
    condition     = length(var.data_subnet_ids) >= 2
    error_message = "At least two subnet IDs must be provided in data_subnet_ids."
  }
}

variable "allowed_app_security_group_id" {
  description = "A list of security group strings that are allowed to access the cache."
  type        = string
}

variable "engine_version" {
  description = "The cache engine version to use (e.g., 6.x for redis)."
  type        = string
}

variable "node_type" {
  description = "The instance type for the cache nodes (e.g., cache.t3.micro)."
  type        = string
}