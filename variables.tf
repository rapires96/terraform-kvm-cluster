
variable "hostname" {
  default = "terraform-vm"
  description = "domain name in libvirt, not hostname"
}

variable "domain" {
  default = "example.com"
}

variable "ip_type" {
  default = "static"
}

variable "memoryMB" {
  default = 1024*2
}

variable "cpu" {
  default = 1
} 

variable "token" {
  default = 12345
}
