variable "table_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity."
  default     = "PAY_PER_REQUEST"
}

variable "key_name" {
  description = "The name of your ssh-key."
  type        = string
}