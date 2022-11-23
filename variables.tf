variable "capstone_developer_ip" {
  type = string
  default = "10.240.0.240"
}

variable "PUBLIC_KEY_PATH" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "PRIV_KEY_PATH" {
  type = string
  default = "~/.ssh/id_rsa"
}
