# Bar Sports Triathlon (BSTri)

Modern rebuild of https://barsportstri.com using an AWS-native stack.

## Chosen stack
- **Frontend**: Next.js (static-first)
- **IaC**: Terraform
- **Realtime (later)**: AppSync subscriptions

## Phases
1. **Static rebuild + deploy**: Next.js static export → S3 (private) + CloudFront (OAC). (Leave existing Route53 apex pointing at the current site until cutover.)
2. **Historical data**: import past results into a datastore (likely DynamoDB), render dynamically.
3. **Realtime scoring**: live updates for active events (AppSync subscriptions), public scoreboard.
4. **Admin**: authenticated admin UI (Cognito) for creating events, entering scores, and managing participants.

## Repo layout
- `web/` — Next.js app
- `infra/terraform/static-site/` — Terraform for S3 + CloudFront (no Route53 changes yet)
- `docs/` — architecture + roadmap

## Local dev (web)
```bash
cd web
npm install
npm run dev
```

## Build static output (web)
```bash
cd web
npm install
npm run export
# output is typically in web/out/
```

## Deploy (infra)
Phase 1 Terraform creates the bucket + distribution and outputs the CloudFront domain name for testing.
