output "id" {
  description = "Tunnel ID"
  value       = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

output "name" {
  description = "Tunnel name"
  value       = cloudflare_zero_trust_tunnel_cloudflared.this.name
}
