variable "environment" {
  description = "The environment for the compute resources (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "The ID of the VPC where the compute resources will be deployed."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC."
  type        = string
}

variable "instance_type" {
  description = "The type of instance to launch (e.g., t2.micro, m5.large)."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The ID of the AMI to use for the instance."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "The CIDR block that is allowed to access the instance via SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be a valid CIDR block."
  }
}

variable "subnet_id" {
  description = "The ID of the subnet where the instance will be launched."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the VPC."
  type        = list(string)
}

variable "enable_https" {
  description = "Enable HTTPS listener with ACM certificate and HTTP->HTTPS redirect"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for the HTTPS listener"
  type        = string
  default     = ""

  validation {
    condition     = var.enable_https ? length(trimspace(var.acm_certificate_arn)) > 0 : true
    error_message = "acm_certificate_arn must be set when enable_https is true."
  }
}