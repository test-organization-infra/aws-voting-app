variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecr_name" {
  description = "Name of the repositories"
  type = list(string)
  default = ["vote-app", "result-app", "worker"]
}

variable "image_mutability" {
  description = "Provide image mutability"
  type = string
  default = "MUTABLE"
}

variable "encrypt_type" {
  description = "Provide type of encryption here"
  type = string
  default = "KMS"
}

variable "tags" {
  description = "The key-value maps for tagging"
  type = map(string)
  default = {}
}
