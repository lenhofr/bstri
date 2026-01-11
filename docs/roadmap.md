# Roadmap

## Phase 1 — Static deploy
- Pick frontend stack
- Rebuild pages: Home, Past Results, Rules, Payouts
- Improve typography/contrast + mobile responsiveness
- Deploy: S3 + CloudFront + Route53 + ACM via IaC

## Phase 2 — Historical data
- Define schema for historical results
- Import to DynamoDB
- Render Past Results dynamically + filters/search

## Phase 3 — Live scoring
- Event model (games, rounds, scoring rules)
- Realtime transport (AppSync subscriptions or WebSocket API)
- Public scoreboard view

## Phase 4 — Admin
- Cognito auth + admin-only routes
- Create/edit event, participants, enter scores
- Optional audit trail
