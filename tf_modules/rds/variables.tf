variable "name" {
  type = string
}

variable "subnet_ids" {
  description = "private subnet from the vpc module"
  type        = list(string)
}

variable "db_sg_id" {
  description = "security group for the db"
  type        = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "db_username" {
  type    = string
  default = "omaradmin"
}