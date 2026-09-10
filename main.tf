resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id = var.account_id
  name       = var.tunnel_name
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "this" {
  lifecycle {
    precondition {
      condition     = var.expected_tunnel_id == null || cloudflare_zero_trust_tunnel_cloudflared.this.id == var.expected_tunnel_id
      error_message = "The tunnel resolves to a different ID than expected; the config would target the wrong tunnel."
    }
  }

  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id
  source     = "cloudflare"
  config     = { ingress = local.ingress }
}
