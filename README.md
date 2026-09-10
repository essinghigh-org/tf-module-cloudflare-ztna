# tf-module-cloudflare-ztna

Terraform module for Cloudflare Zero Trust around one cloudflared tunnel: tunnel identity and ingress, private CIDR routes, Gateway policies and settings, and the default virtual network.

## Tunnel services

Two deployment models in one ordered list (list order is the ingress order):

```hcl
module "tunnel" {
  source = "github.com/essinghigh-org/tf-module-cloudflare-ztna"

  account_id         = var.account_id
  tunnel_name        = "home"
  expected_tunnel_id = "3719d3f4-d477-457c-8ab9-6eaae28eadf9"
  access_team_name   = "1411314"

  services = [
    { hostname = "app.example.com" },
    { hostname = "plex.example.com", port = 32400, http_host_header = "", origin_server_name = "" },
    { hostname = "ssh.example.com", service = "ssh://192.168.1.69", access = true },
    { hostname = "ext.example.com", model = "external", host = "origin.example.com" },
  ]

  routes = {
    "192.168.0.0/23" = {}
  }

  gateway_policies = {
    default_forward = {
      name        = "default-forward"
      action      = "override"
      filters     = ["dns"]
      traffic     = "dns.fqdn == \"example.com\""
      precedence  = 11000
      rule_settings = { override_ips = ["192.168.1.69"] }
    }
  }
}
```

Homelab entries derive service from `default_service_base` (+port) and origin
TLS settings from the hostname; null omits, explicit values (including `""`)
pass through. Uses `config_src = "cloudflare"` (remote config).

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
