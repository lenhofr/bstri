variable "region" {
  type    = string
  default = "us-west-2"
}

variable "project" {
  type    = string
  default = "bstri"
}

variable "tags" {
  type    = map(string)
  default = {}
}
