resource "cloudflare_zero_trust_tunnel_cloudflared_route" "this" {
  for_each = var.routes

  account_id         = var.account_id
  tunnel_id          = cloudflare_zero_trust_tunnel_cloudflared.this.id
  network            = each.key
  comment            = each.value.comment
  virtual_network_id = each.value.virtual_network_id
}
