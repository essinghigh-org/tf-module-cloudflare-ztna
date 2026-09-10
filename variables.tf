variable "account_id" {
  description = "Cloudflare account ID that owns the tunnel"
  type        = string
}

variable "tunnel_name" {
  description = "Name of the cloudflared tunnel"
  type        = string
  default     = "home"
}
