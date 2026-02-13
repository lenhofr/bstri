# Production migration notes (from `bstridev` → `bstri`)

Goal: make this repo (`/Users/robl/dev/static/bstri`) the source of truth for **https://barsportstri.com/**, reusing as much as possible from the working dev stack in `/Users/robl/dev/static/bstridev`.

## Quick comparison (what exists today)

### `bstridev` (dev)
- Terraform app stack **includes**:
  - Static site: S3 (private) + CloudFront (OAC) + CloudFront Function rewrite + optional Route53 records
  - **Admin auth**: Cognito User Pool + Hosted UI domain + client
  - **Scoring backend**: DynamoDB + Lambda + API Gateway HTTP API + JWT authorizer (Cognito)
- GitHub Actions deploy pipeline:
  - Builds the scoring lambda bundle (`infra/lambda/scoring`) during Terraform plan/apply
  - Builds Next.js static export, but **injects Terraform outputs** as `NEXT_PUBLIC_*` at build time:
    - `NEXT_PUBLIC_SCORING_API_BASE_URL`
    - `NEXT_PUBLIC_COGNITO_HOSTED_UI_DOMAIN`
    - `NEXT_PUBLIC_COGNITO_USER_POOL_CLIENT_ID`
    - `NEXT_PUBLIC_COGNITO_USER_POOL_ID`

### `bstri` (this repo / prod)
- Terraform app stack currently **only** provisions the static site (S3 + CloudFront + optional Route53 + deploy role).
- This repo also has:
  - `infra/terraform/bootstrap-state/` (create TF state bucket + lock table)
  - `infra/terraform/static-site/` (older/draft static-site module)
- GitHub Actions deploy pipeline currently:
  - Builds Next.js
  - Reads only `bucket_name`, `cloudfront_distribution_id`, and `github_actions_role_arn`
  - **Does not** set any `NEXT_PUBLIC_*` values from Terraform outputs

## What we can reuse (recommended)

### 1) GitHub Actions OIDC + Terraform roles
- Reuse the **existing GitHub Actions OIDC provider** (`token.actions.githubusercontent.com`) in the AWS account.
- Create / keep a **Terraform apply role** for this repo via `infra/terraform/github-actions-oidc`.
- Create / keep a **deploy role** (least privilege) that can:
  - `aws s3 sync` to the site bucket
  - invalidate the CloudFront distribution

Notes:
- Dev’s `github-actions-oidc` module supports *multiple* repos (`github_repositories` list). Prod’s version scopes to a single `github_owner/github_repo`.
- Either approach works; the key is that the trust policy must allow this repo’s workflow subject (`repo:<owner>/<repo>:*`).

### 2) Static site stack (S3 + CloudFront + ACM + Route53)
- The static site pieces in `bstridev/infra/terraform/app` are already what we want for prod.
- This repo’s `infra/terraform/app` is already very close to dev’s static-site implementation (including CloudFront Function rewrite + optional www→apex redirect).

### 3) Cognito admin user pool (auth)
Two viable options:
1. **Create a new prod user pool** (recommended): keeps dev/prod separation, and avoids mixing callback URLs/domains.
2. **Reuse the existing dev user pool**: faster, but couples environments and complicates callback URLs / domain cutover.

Recommendation: create a new prod pool by using a distinct `project_name` (e.g. `bstri-prod`) so Terraform resource names don’t collide.

### 4) Scoring backend (DynamoDB + Lambda + API Gateway)
- The entire scoring backend in `bstridev/infra/terraform/app` can be copied into this repo.
- The deploy pipeline should then export `NEXT_PUBLIC_SCORING_API_BASE_URL` from Terraform so the static site talks to the correct API.

## What to copy from `bstridev` into `bstri`

### A) Terraform: scoring + auth resources
Copy/merge from:
- `bstridev/infra/terraform/app/main.tf` (Cognito + DynamoDB + Lambda + API Gateway)
- `bstridev/infra/terraform/app/outputs.tf` (additional outputs)
- `bstridev/infra/terraform/app/variables.tf` (admin OAuth callback/logout URL vars)

Target in this repo:
- `bstri/infra/terraform/app/*` (same folder)

Implementation notes:
- Keep the static-site parts already present in `bstri/infra/terraform/app/main.tf`.
- Add the Cognito + scoring backend blocks (and the related outputs/variables).
- Ensure the Cognito callback/logout URL logic includes:
  - CloudFront domain
  - `barsportstri.com` and `www.barsportstri.com`

### B) Lambda source
Copy:
- `bstridev/infra/lambda/scoring/**`

Into:
- `bstri/infra/lambda/scoring/**`

Because:
- Dev Terraform zips `infra/lambda/scoring/dist/index.js`.
- Dev GitHub Actions runs `npm ci && npm run build` in that lambda folder before Terraform plan/apply.

### C) GitHub Actions workflows
Update this repo’s workflows to match dev behavior:

1) `.github/workflows/terraform-plan.yml`
- Add `infra/lambda/scoring/**` to the paths filter
- Add the lambda build step before `terraform init/plan`

2) `.github/workflows/terraform.yml`
- Add the lambda build step before `terraform init/apply`

3) `.github/workflows/deploy.yml`
- After `terraform init`, read and export these outputs to `GITHUB_ENV`:
  - `NEXT_PUBLIC_SCORING_API_BASE_URL`
  - `NEXT_PUBLIC_COGNITO_HOSTED_UI_DOMAIN`
  - `NEXT_PUBLIC_COGNITO_USER_POOL_CLIENT_ID`
  - `NEXT_PUBLIC_COGNITO_USER_POOL_ID`

## Production environment values (domain + routing)

### Recommended rollout to avoid breaking the live Azure site
1. **Provision AWS stack without touching apex Route53**
   - Set `custom_domain_name = null` initially OR
   - Use a safe subdomain like `next.barsportstri.com` first.
2. Verify CloudFront is serving the site.
3. Only then switch Route53 for `barsportstri.com` and `www.barsportstri.com` to the new CloudFront distribution.

### Terraform variables for prod
In `bstri/infra/terraform/app/terraform.tfvars` (prod):
- `custom_domain_name = "barsportstri.com"`
- `alternate_domain_names = ["www.barsportstri.com"]`
- `redirect_www_to_apex = true` (if desired)
- `route53_zone_id = <your hosted zone id>`
- `create_route53_record = false` initially; flip to `true` at cutover.

## Terraform state separation (important)

### What we discovered
- The shared state key `s3://tf-state-common-217354297026-us-east-1/bstri/terraform.tfstate` is **not production**.
- It currently manages the **dev** stack for `barsportsdev.com`, including:
  - S3 bucket `bstri-site-0db96edf`
  - CloudFront distribution `E2EW74R4PEG3E2` (`dwxhom2tw1qkl.cloudfront.net`)
  - Cognito user pool + Hosted UI domain
  - Scoring API Gateway base URL

If we want **dev** and **prod** stacks to coexist safely:
- Use **separate state** and distinct `project_name` prefixes.

### New production state (implemented)
We created a dedicated prod Terraform state bucket + lock table:
- S3: `tf-state-bstri-prod-217354297026-us-east-1`
- DynamoDB lock table: `bstri-prod-tf-lock`
- Prod backend key (this repo `infra/terraform/app`): `bstri/prod/terraform.tfstate`

This ensures Terraform changes in the prod repo cannot mutate the dev stack.

### Production static-site stack (created; not cut over yet)
We successfully applied `infra/terraform/app` using the new prod backend and created a **new** S3+CloudFront stack with no custom domain attached yet:
- S3 origin bucket: `bstri-prod-site-ee7ae1dc`
- CloudFront distribution: `E2HP232K8YAWDZ`
- CloudFront domain for testing: `dwsioad8fm3sr.cloudfront.net`
- Deploy role ARN (used by GitHub Actions deploy workflow): `arn:aws:iam::217354297026:role/bstri-prod-github-actions-deploy`

Because `custom_domain_name=null` and `create_route53_record=false`, this does **not** change `barsportstri.com` routing yet; it’s safe to test in parallel.

## One-time bootstrap checklist (prod)
1. (If needed) run `infra/terraform/bootstrap-state` to create a dedicated TF state bucket/lock table.
2. Apply `infra/terraform/github-actions-oidc` from your laptop to create the GitHub Actions Terraform role.
3. Set GitHub secret in this repo:
   - `AWS_TERRAFORM_ROLE_ARN`
4. Run Terraform apply via GitHub Actions (or locally once) to create the site + backend.
5. Re-apply `infra/terraform/github-actions-oidc` with `create_deploy_role=true` once you know the bucket/distribution outputs.
6. Run Deploy workflow; verify.
7. Cut over Route53.

## Open questions / decisions
- Do we want a distinct prod `project_name` (e.g. `bstri-prod`) to avoid resource collisions with the current dev stack?
- Do we want a staging subdomain under `barsportstri.com` for rehearsal cutovers?
- Do we need to preserve any Azure-specific redirects/content, or can AWS become the single source of truth immediately at cutover?

## AWS investigation (Route53 / cutover planning)
We’re going to authenticate to the AWS account that owns the `barsportstri.com` Route53 hosted zone so we can gather concrete details for the production cutover and Terraform plan.

Why:
- Right now, the apex domain is still pointing at the Azure-hosted site; to move prod to this repo’s AWS CloudFront distribution we need to know the *exact* existing records, hosted zone ID, and whether anything is already provisioned that we should reuse/import.
- In this session, `aws sts get-caller-identity` returned `ExpiredToken`, so we can’t inspect Route53 until AWS credentials are refreshed.

What we’ll inspect after auth:
1. **Hosted zone**
   - Find the hosted zone ID for `barsportstri.com`.
2. **Current DNS records**
   - Current apex (`barsportstri.com`) and `www` records: type (A/AAAA/CNAME), targets, TTL.
   - Any existing `staging.*` / `next.*` / verification records.
3. **Existing AWS resources that might already be in use**
   - CloudFront distributions that already have aliases for `barsportstri.com` / `www.barsportstri.com`.
   - ACM certs in **us-east-1** for `barsportstri.com`.
4. **Terraform implications**
   - Whether we should simply set `route53_zone_id` and let Terraform create/overwrite records at cutover, or
   - Import existing records into state to avoid a “record already exists” conflict (depending on how the current records are created/managed).

Useful AWS CLI commands (run after auth):
```bash
aws sts get-caller-identity
aws route53 list-hosted-zones
# then:
aws route53 list-resource-record-sets --hosted-zone-id <ZONE_ID> > /tmp/rrsets.json
# quick filters:
cat /tmp/rrsets.json | grep -n "barsportstri.com" -n | head
```

Terraform import examples (only if we decide to manage existing records in TF state):
- If the record already exists and is the same name/type:
```bash
cd infra/terraform/app
terraform init
terraform import 'aws_route53_record.alias_a[0]'   '<ZONE_ID>_barsportstri.com_A'
terraform import 'aws_route53_record.alias_aaaa[0]' '<ZONE_ID>_barsportstri.com_AAAA'
# and for www, if modeled as alternates:
terraform import 'aws_route53_record.alias_a_alternates["www.barsportstri.com"]'   '<ZONE_ID>_www.barsportstri.com_A'
terraform import 'aws_route53_record.alias_aaaa_alternates["www.barsportstri.com"]' '<ZONE_ID>_www.barsportstri.com_AAAA'
```

Cutover outcome we’re aiming for:
- `barsportstri.com` + `www.barsportstri.com` become Route53 **ALIAS** A/AAAA records pointing to the new CloudFront distribution, with ACM validated in us-east-1.
