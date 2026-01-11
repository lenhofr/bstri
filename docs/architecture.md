# Architecture (draft)

## Static site (Phase 1)
- Route53 hosts `barsportstri.com`.
- ACM certificate in **us-east-1** (required for CloudFront).
- CloudFront distribution serves the site.
- S3 bucket stores static assets; access via CloudFront **Origin Access Control (OAC)**.

## Dynamic app (Phases 2+)
### Suggested components
- **Auth**: Cognito User Pool
  - `admin` group for privileged UI/actions
- **API**:
  - Option A: **AppSync (GraphQL)** for queries/mutations + subscriptions (realtime)
  - Option B: **API Gateway (REST) + WebSocket API** for realtime
- **Compute**: Lambda
- **Data**: DynamoDB
  - Tables (tentative): `Events`, `Participants`, `EventParticipants`, `Games`, `Scores`

## Open questions
- One concurrent event at a time, or multiple?
- Individual-only, or teams too?
- Do we need an audit trail of score edits?
