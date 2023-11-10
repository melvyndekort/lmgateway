variable "sns_topic_arn" {
  type = string
}

variable "sns_topic_region" {
  type = string
}

variable "desired_capacity" {
  type = number
}

variable "ssm_x86" {
  type = string
}

variable "ssm_arm" {
  type = string
}
