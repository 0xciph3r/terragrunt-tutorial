# Terragrunt Tutorial

Hands-on infrastructure learning repo for Terragrunt, Terraform/OpenTofu, and AWS SRE-focused patterns.

## Structure

- `modules/` reusable infrastructure modules (`network`, `compute`, `cache`, `database`, `storage`)
- `live/` environment instantiations and Terragrunt composition (`dev/us-east-1`)
- `.github/workflows/terragrunt-plan.yaml` CI workflow for Terragrunt plan validation on pull requests

## Run locally

From the region stack root:

```bash
cd live/dev/us-east-1
terragrunt run --all plan --non-interactive
```
