# Bar Sports Triathlon (BSTri)

Modern rebuild of https://barsportstri.com using an AWS-native stack, starting with a clean static site deploy, then adding dynamic web-app features (historical datastore, realtime scoring, admin).

## Phases
1. **Static rebuild + deploy**: modern frontend + S3 (private) + CloudFront + ACM + Route53.
2. **Historical data**: model + import past results into a datastore (likely DynamoDB), render pages dynamically.
3. **Realtime scoring**: live updates for active events (subscriptions/websockets), public “scoreboard” view.
4. **Admin**: authenticated admin UI (Cognito) for creating events, entering scores, and managing participants.

## Target AWS architecture (high-level)
- **Frontend**: Static assets on S3, served via CloudFront (OAC), HTTPS via ACM, DNS via Route53.
- **API**: API Gateway + Lambda (or AppSync) for CRUD and scoring.
- **Data**: DynamoDB (events, participants, games, scores) + optional S3 for uploads.
- **Auth**: Cognito User Pool (+ groups/roles for admin).
- **Realtime**: AppSync subscriptions *or* API Gateway WebSocket API.
- **Ops**: CloudWatch logs/metrics/alarms.

## Repo layout
- `docs/` — architecture + decisions + data model notes
- `infra/` — infrastructure as code (CDK/Terraform) (to be added)

## Next decisions
- Frontend framework (Next.js vs Remix vs SvelteKit) and styling approach.
- Realtime approach (AppSync vs WebSocket API).
- Data model for historical + live scoring.
