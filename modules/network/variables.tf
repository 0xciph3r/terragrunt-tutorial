variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "azs" {
  description = "A list of availability zones for the VPC"
  type        = list(string)

  validation {
    condition     = length(var.azs) == 3
    error_message = "Exactly three availability zones must be specified."
  }
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 3 && length(var.public_subnet_cidrs) == length(distinct(var.public_subnet_cidrs))
    error_message = "Exactly three unique public subnet CIDR blocks must be specified."
  }

  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All public subnet CIDR blocks must be valid."
  }
}
variable "app_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets"
  type        = list(string)

  validation {
    condition     = length(var.app_subnet_cidrs) == 3 && length(var.app_subnet_cidrs) == length(distinct(var.app_subnet_cidrs))
    error_message = "Exactly three unique private subnet CIDR blocks must be specified."
  }
  validation {
    condition     = alltrue([for cidr in var.app_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All private subnet CIDR blocks must be valid."
  }
}

variable "data_subnet_cidrs" {
  description = "A list of CIDR blocks for the database subnets"
  type        = list(string)

  validation {
    condition     = length(var.data_subnet_cidrs) == 3 && length(var.data_subnet_cidrs) == length(distinct(var.data_subnet_cidrs))
    error_message = "Exactly three unique database subnet CIDR blocks must be specified."
  }
  validation {
    condition     = alltrue([for cidr in var.data_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All database subnet CIDR blocks must be valid."
  }
}