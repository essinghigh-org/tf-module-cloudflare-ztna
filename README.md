# tf-module-cloudflare-ztna

Terraform module for Cloudflare Zero Trust: currently manages a single `cloudflare_zero_trust_tunnel_cloudflared` tunnel, with room for access applications and policies.

## Usage

```hcl
module "tunnel" {
  source = "github.com/essinghigh-org/tf-module-cloudflare-ztna"

  account_id  = var.account_id
  tunnel_name = "home"
}
```

Uses `config_src = "cloudflare"` (remote config). Dashboard edits become drift.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
