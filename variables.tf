variable "environment" {
  default = "dev"
}

variable "region" {
  default = "us-east-2"
  description = "AWS Instance Region"
}

variable "ami_instance" {
  description = "ami id"
}

variable "instance_type" {
  description = "instance type"
}

variable "vpc_cidr" {
  description = "VPC cidr block"
}