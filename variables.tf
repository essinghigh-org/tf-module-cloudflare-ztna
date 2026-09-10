variable "account_id" {
  description = "Cloudflare account ID that owns the tunnel"
  type        = string
}

variable "tunnel_name" {
  description = "Name of the cloudflared tunnel"
  type        = string
  default     = "home"
}

variable "expected_tunnel_id" {
  description = "Guard: fail if the tunnel resolves to a different ID (protects the config import)"
  type        = string
  default     = null
}

variable "default_service_base" {
  description = "scheme://host prefix for homelab services (port appended per service)"
  type        = string
  default     = "https://192.168.1.69"
}

variable "access_team_name" {
  description = "Zero Trust team name for service access blocks (required when any service sets access = true)"
  type        = string
  default     = null
}

# Two deployment models in one ordered list (Cloudflare evaluates ingress top
# to bottom, so list order is the rule order):
# - homelab (default): service derived from default_service_base (+port).
# - external: hostname fronting a public origin (host required, fixed shape).
# Null means "omit" (except header/SNI, which derive the hostname); explicit
# values (including "") pass through verbatim.
variable "services" {
  description = "Tunnel services in ingress order (homelab or external model)"
  type = list(object({
    hostname                 = string
    model                    = optional(string, "homelab")
    host                     = optional(string)
    port                     = optional(number)
    service                  = optional(string)
    bare_origin              = optional(bool, false)
    no_tls_verify            = optional(bool, true)
    http2_origin             = optional(bool, true)
    http_host_header         = optional(string)
    origin_server_name       = optional(string)
    ca_pool                  = optional(string)
    access                   = optional(bool, false)
    match_sn_ito_host        = optional(bool)
    disable_chunked_encoding = optional(bool)
    no_happy_eyeballs        = optional(bool)
  }))
  default = []

  validation {
    condition     = alltrue([for s in var.services : contains(["homelab", "external"], s.model)])
    error_message = "service model must be homelab or external."
  }

  validation {
    condition     = alltrue([for s in var.services : s.model != "external" || s.host != null])
    error_message = "external services require host."
  }

  validation {
    condition     = alltrue([for s in var.services : !(s.access && var.access_team_name == null)])
    error_message = "access = true requires access_team_name."
  }
}

variable "routes" {
  description = "Private CIDR routes served by this tunnel (network => settings)"
  type = map(object({
    comment            = optional(string)
    virtual_network_id = optional(string)
  }))
  default = {}
}

variable "gateway_policies" {
  description = "Zero Trust Gateway policies by key (precedence governs evaluation order)"
  type = map(object({
    name          = string
    action        = string
    filters       = list(string)
    traffic       = string
    enabled       = optional(bool, true)
    precedence    = optional(number)
    description   = optional(string, "")
    rule_settings = optional(any, {})
  }))
  default = {}
}

variable "gateway_settings" {
  description = "Account gateway settings (null leaves them unmanaged)"
  type = object({
    antivirus = optional(object({
      enabled_download_phase = optional(bool, false)
      enabled_upload_phase   = optional(bool, false)
      fail_closed            = optional(bool, false)
    }), {})
    tls_decrypt = optional(object({
      enabled = optional(bool, false)
    }), {})
    activity_log = optional(object({
      enabled = optional(bool, false)
    }), {})
    block_page = optional(object({
      enabled          = optional(bool, true)
      mode             = optional(string, "")
      footer_text      = optional(string, "")
      header_text      = optional(string, "")
      mailto_address   = optional(string, "")
      mailto_subject   = optional(string, "")
      logo_path        = optional(string, "")
      background_color = optional(string, "")
      name             = optional(string, "")
      suppress_footer  = optional(bool, false)
      target_uri       = optional(string, "")
      include_context  = optional(bool, false)
    }), {})
    fips = optional(object({
      tls = optional(bool, false)
    }), {})
  })
  default = null
}

variable "default_virtual_network" {
  description = "Adopt the account default virtual network (null leaves it unmanaged)"
  type = object({
    name    = string
    comment = optional(string, "")
  })
  default = null
}
