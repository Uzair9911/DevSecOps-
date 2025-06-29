variable "log_streams" {
  type    = list(string)
  default = null
}

variable "alarm_sns_topic_name" {
}

variable "app_name" {
  type = string
}
