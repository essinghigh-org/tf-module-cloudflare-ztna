variable "account_id" {
  description = "Cloudflare account ID that owns the tunnel"
  type        = string
}

variable "tunnel_name" {
  description = "Name of the cloudflared tunnel"
  type        = string
  default     = "home"
}

variable "routes" {
  description = "Private CIDR routes served by this tunnel (network => settings)"
  type = map(object({
    comment            = optional(string)
    virtual_network_id = optional(string)
  }))
  default = {}
}
