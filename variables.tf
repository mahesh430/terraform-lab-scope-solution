variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-08a0d1e16fc3f61ea" # Amazon Linux 2
}

variable "security_group_rules" {
  description = "Map of security group rules"
  type        = map(map(string))
  default = {
    "ssh" = {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr      = "0.0.0.0/0"
    }
    "http" = {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
      cidr      = "0.0.0.0/0"
    }
    "https" = {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
      cidr      = "0.0.0.0/0"
    }
  }
}
variable "vpc_id" {
    default = "vpc-0970dbf0432aa69f5"
    type = string
}

variable "subnets" {
    default = ["subnet-0c4717f9efc81c47d", "subnet-0559a1b995906add6"]
    type = set(string)
}
