#Define AWS Region
variable "aws_region" {
  description = "Infrastructure region"
  type        = string
  default     = "eu-central-1"
}
# Common

variable "cluster_name" {
  description = "the nameof ecs cluster"
  default     = "lambda-layers-test"
}

variable "app_name" {
  description = "val"
  default     = "lambda-layers-test"
}

variable "app_environment" {
  description = "val"
  default     = "aws"
}

variable "common_tags" {
  type = map(any)
  default = {
    Project   = "lambda-layers-test"
    ManagedBy = "Terraform"
  }
}

# VPC configuration

variable "cidr" {
  default = "10.23.8.0/22"
}
variable "availability_zones" {
  type        = list(string)
  description = "the name of availability zones to use subnets"
  default     = ["eu-central-1a", "eu-central-1b"]
}
variable "public_subnets" {
  type        = list(string)
  description = "the CIDR blocks to create public subnets"
  default     = ["10.23.8.0/24", "10.23.9.0/24"]
}
variable "private_subnets" {
  type        = list(string)
  description = "the CIDR blocks to create private subnets"
  default     = ["10.23.10.0/24", "10.23.11.0/24"]
}
