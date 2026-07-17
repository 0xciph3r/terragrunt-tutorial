variable "environment" {
  description = "The environment for which the database is being configured (e.g., dev, staging, prod)."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the database will be deployed."
  type        = string
}

variable "data_subnet_ids" {
  description = "The IDs of the subnets where the database will be deployed."
  type        = list(string)

  validation {
    condition     = length(var.data_subnet_ids) >= 2
    error_message = "At least two subnet IDs must be provided in data_subnet_ids."
  }
}

variable "app_security_group_id" {
  description = "A security group string that is allowed to access the database."
  type        = string
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
}

variable "db_username" {
  description = "The username for the database."
  type        = string
}

variable "db_password" {
  description = "The password for the database."
  sensitive = true
  type = string
}

variable "instance_class" {
    description = "The instance class for the database (e.g., db.t3.micro)."
    type        = string
}

variable "allocated_storage" {
    description = "The allocated storage in gigabytes for the database."
    type        = number
}
