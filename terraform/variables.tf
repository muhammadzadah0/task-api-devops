variable "app_port" {
  description = "Port for the Task API"
  type        = number
  default     = 8000
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "tasksdb"
}

variable "db_user" {
  description = "PostgreSQL user"
  type        = string
  default     = "appuser"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
