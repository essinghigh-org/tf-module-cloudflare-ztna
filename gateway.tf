resource "cloudflare_zero_trust_gateway_policy" "this" {
  for_each = var.gateway_policies

  account_id  = var.account_id
  name        = each.value.name
  description = each.value.description
  action      = each.value.action
  filters     = each.value.filters
  traffic     = each.value.traffic
  enabled     = each.value.enabled
  precedence  = each.value.precedence

  rule_settings = each.value.rule_settings == {} ? null : each.value.rule_settings
}

resource "cloudflare_zero_trust_gateway_settings" "this" {
  count = var.gateway_settings == null ? 0 : 1

  account_id = var.account_id
  settings   = var.gateway_settings
}

resource "cloudflare_zero_trust_tunnel_cloudflared_virtual_network" "this" {
  count = var.default_virtual_network == null ? 0 : 1

  account_id         = var.account_id
  name               = var.default_virtual_network.name
  comment            = var.default_virtual_network.comment
  is_default_network = true
}
