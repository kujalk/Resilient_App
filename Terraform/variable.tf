variable "project_name" {
  type = string
}

variable "dbname" {
  type = string
}
variable "image_url" {
  type = string
}

variable "VPC_CIDR" {
  type = string
}

variable "PublicSubnet_CIDR1" {
  type = string
}

variable "PublicSubnet_CIDR2" {
  type = string
}

variable "PrivateSubnet_CIDR1" {
  type = string

}

variable "PrivateSubnet_CIDR2" {
  type = string
}

variable "Public_AZ1" {
  type = string
}

variable "Public_AZ2" {
  type = string
}

variable "Private_AZ1" {
  type = string
}

variable "Private_AZ2" {
  type = string
}

variable "dbuser" {
  type = string
}

variable "dbpassword" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "engine_version" {
  type = string
}

variable "instance_size" {
  type = string
}

variable "storage_type" {
  type = string
}