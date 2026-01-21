variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the public subnet (e.g. us-east-1a)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (region-specific)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
