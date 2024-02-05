variable "alias" {
  description = "alias"
  type        = string
  default     = "dquaresma"
}
variable "location" {
  description = "alias"
  type        = string
  default     = "Central US"
}

variable "dns_server_ip" {
  description = "location"
  type        = string
  default     = "10.0.0.10"
}
variable "pod_subnet_range" {
  description = "location"
  type        = list(any)
  default     = ["10.1.1.0/24"]
}
variable "node_subnet_range" {
  description = "location"
  type        = list(any)
  default     = ["10.1.0.0/24"]
}
variable "appgw_private_ip" {
  description = "location"
  type        = string
  default     = "10.0.1.12"
}

