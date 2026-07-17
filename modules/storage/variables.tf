variable "environment" {
  description = "The environment to deploy the storage"
  type = string
}

variable "bucket_name_prefix" {
  description = "The prefix for the bucket name"
  type = string
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket when deleting"
  type = bool
  default = false
}