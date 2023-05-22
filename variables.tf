variable "projectPrefix" {
  type        = string
  description = "development-carshare | staging-carshare | production-carshare"
  default     = ""
}

variable "resource_server_identifier" {
  type    = string
  default = "resource server identifier"
}

variable "client_callback_urls" {
  type        = list(string)
  description = "client callback urls"
  default     = ["http://localhost:3000"]
}

variable "client_logout_urls" {
  type        = list(string)
  description = "client callback urls"
  default     = ["http://localhost:3000"]
}


variable "google" {
  type = object({
    client_id     = string
    client_secret = string
  })
  description = "Google Client ID"
}


variable "facebook" {
  type = object({
    app_id     = string
    app_secret = string
  })
  description = "Facebook Client ID"
}

variable "apple" {
  type = object({
    client_id = string
    team_id   = string
    key_id    = string
    # private_key = string
  })
  description = "Apple Client ID"
}
