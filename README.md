# Terragrunt Tutorial (Senior Infra / SRE Track)

Production-style AWS infrastructure repo focused on Terragrunt, Terraform/OpenTofu, and SRE-grade platform engineering patterns.

## Focus

- Multi-tier network architecture (public/app/data) with AZ-aware routing
- Service modules for compute, cache, database, and storage
- Security-first defaults (encryption, private networking, controlled ingress, hardened metadata)
- Terragrunt composition for environment-level orchestration
- Custom provider lab in Go (`provider/`) for Terraform/OpenTofu internals

## Repository layout

- `modules/` reusable infrastructure modules:
  - `network`
  - `compute`
  - `cache`
  - `database`
  - `storage`
- `live/` environment instantiation via Terragrunt (`dev/us-east-1`)
- `provider/` custom DNS provider lab (CRUD, import, diagnostics, tests)
- `.github/workflows/` CI workflows (validate + optional manual plan)

## Execution

From stack root:

```bash
cd live/dev/us-east-1
terragrunt run --all validate --non-interactive
```

Manual plan (when credentials are available):

```bash
cd live/dev/us-east-1
terragrunt run --all plan --non-interactive
```
