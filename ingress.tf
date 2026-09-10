# Two deployment models, one ordered list (Cloudflare evaluates ingress top to
# bottom, so list order is the rule order):
# - homelab: service derived from default_service_base (+port), origin TLS
#   settings per entry (null = omit, "" passes through, header/SNI derive
#   the hostname unless given).
# - external: hostname fronting a public origin (fixed secure shape).
locals {
  homelab_entries = [for s in var.services : s.model == "external" ? null : {
    hostname = s.hostname
    service  = coalesce(s.service, "${var.default_service_base}${s.port != null ? ":${s.port}" : ""}")
    origin_request = s.bare_origin ? {} : { for k, v in {
      ca_pool                  = s.ca_pool
      http2_origin             = s.http2_origin
      http_host_header         = coalesce(s.http_host_header, s.hostname)
      no_tls_verify            = s.no_tls_verify
      origin_server_name       = coalesce(s.origin_server_name, s.hostname)
      disable_chunked_encoding = s.disable_chunked_encoding
      no_happy_eyeballs        = s.no_happy_eyeballs
      match_sn_ito_host        = s.match_sn_ito_host
      access = s.access ? {
        aud_tag   = []
        required  = false
        team_name = var.access_team_name
      } : null
    } : k => v if v != null }
  }]

  external_entries = [for s in var.services : s.model == "external" ? {
    hostname = s.hostname
    service  = "https://${s.host}"
    origin_request = {
      ca_pool            = ""
      http2_origin       = true
      http_host_header   = s.host
      no_tls_verify      = true
      origin_server_name = s.host
    }
  } : null]

  # Preserve today's exact rule order: walk the input list once, picking the
  # built entry of either model, then the catch-all.
  entries_by_host = merge(
    { for e in local.homelab_entries : e.hostname => e if e != null },
    { for e in local.external_entries : e.hostname => e if e != null },
  )

  ingress = concat(
    [for s in var.services : local.entries_by_host[s.hostname]],
    [{ service = "http_status:200" }],
  )
}
