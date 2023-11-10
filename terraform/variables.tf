variable "desired_capacity" {
  type    = number
  default = 0
}

variable "sns_topic_arn" {
  type = string
}

variable "sns_topic_region" {
  type = string
}
