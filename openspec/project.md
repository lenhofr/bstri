# Project Context

## Purpose
Bar Sports Triathlon (BSTri) — a modern AWS-native rebuild of [barsportstri.com](https://barsportstri.com).
The site manages and displays results for a recreational triathlon competition where participants compete
across three bar sports: bowling, pool, and darts. Features include a public-facing static site with
past results and rules, a real-time public scoreboard, and an authenticated admin UI for entering scores.

## Tech Stack
- **Language**: TypeScript (strict)
- **Frontend**: Next.js 14, React 18, static export (`output: 'export'`)
- **PWA**: next-pwa (service worker, offline support, cache update prompt)
- **Fonts**: Google Fonts — Inter (body), Permanent Marker (headings)
- **Styling**: Custom CSS with CSS variables (no CSS framework)
- **Testing**: Node.js built-in test runner + `tsx` (`node --import tsx --test`)
- **IaC**: Terraform
- **Cloud — Hosting**: S3 (private bucket) + CloudFront (OAC)
- **Cloud — Auth**: AWS Cognito (hosted UI, PKCE OAuth2, hand-rolled — no SDK)
- **Cloud — API**: API Gateway REST + Lambda
- **Cloud — Data**: DynamoDB
- **Cloud — DNS/TLS**: Route53, ACM (cert in us-east-1 for CloudFront)

## Project Conventions

### Code Style
- TypeScript throughout; avoid `any`
- Named exports for components and library functions
- Function components only (no class components)
- Async/await over promise chains
- No linter config committed yet — follow the style already in the file being edited
- Custom CSS with CSS variables; no utility-class framework (no Tailwind)

### Architecture Patterns
```
web/                        Next.js App Router application
  app/                      Routes (Next.js App Router)
    _components/            Shared UI components used across routes
    admin/scoring/          Admin scoring UI (auth-gated, Cognito PKCE)
    scoring/                Public scoreboard
    past-results/           Historical results viewer
    rules/, payouts/, contact/, offline/   Static content pages
  lib/                      Domain logic, API clients, auth utilities
    scoring-model.ts        Core TypeScript types + ScoringDocumentV1 schema
    scoring-rules.ts        Points calculation (place → points)
    scoring-api.ts          REST API client functions (typed fetch wrappers)
    cognito-auth.ts         Hand-rolled Cognito PKCE OAuth2 (no Amplify/SDK)
    runtime-config.ts       NEXT_PUBLIC_* env var access
    active-triathlon.ts     Active event helpers
    pool-schedule.ts        Pool bracket/schedule generation
    triathlon-docs.ts       Helpers for reading scoring docs
  content/                  Static text content (e.g. past results data)
  tests/                    Test files (Node built-in runner)
  public/                   Static assets, PWA manifest, icons
  next.config.mjs           Next config + next-pwa runtime caching rules

infra/terraform/
  static-site/              S3 + CloudFront + OAC setup
  app/                      Cognito, Lambda, API Gateway, DynamoDB
  bootstrap-state/          Remote state backend bootstrap
  github-actions-oidc/      OIDC role for CI deployments

docs/                       Architecture notes, roadmap, deploy guides
openspec/                   Change proposals and project spec (this file)
```

**Key constraints from `output: 'export'`:**
- No server-side rendering, no API routes, no ISR, no dynamic routes with `fallback`
- All pages must be fully statically renderable at build time
- `images: { unoptimized: true }` required for Next.js Image component

**PWA caching strategy:**
- Scoring pages/API → NetworkFirst (5–10 s timeout)
- Content pages → StaleWhileRevalidate
- Static assets / `_next/static/` → CacheFirst (30 days)
- Google Fonts → CacheFirst for webfonts, StaleWhileRevalidate for stylesheets
- Service worker disabled in development

**Auth pattern (Cognito PKCE, no SDK):**
- Tokens stored in `localStorage` under key `bstri:auth:tokens`
- PKCE state in `sessionStorage`
- `getAccessToken()` checks expiry with 30 s buffer
- Admin redirect URI always resolves to `/admin/scoring`
- Only allows `returnTo` paths under `/admin/scoring` (prevents open redirect)

**Runtime config** is read from `NEXT_PUBLIC_*` env vars at build time:
- `NEXT_PUBLIC_SCORING_API_BASE_URL`
- `NEXT_PUBLIC_COGNITO_HOSTED_UI_DOMAIN`
- `NEXT_PUBLIC_COGNITO_USER_POOL_CLIENT_ID`
- `NEXT_PUBLIC_COGNITO_USER_POOL_ID`

### Testing Strategy
- Framework: Node.js built-in test runner, no Jest/Vitest
- Run: `cd web && node --import tsx --test tests/*.test.ts` (or `npm test`)
- Tests live in `web/tests/`; file naming: `<subject>.test.ts`
- Focus on pure logic (scoring rules, schedule generation, doc parsing)
- No component/browser tests currently

### Git Workflow
- Single `main` branch; feature work done in short-lived branches
- PR into `main` for all changes
- Conventional commit prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`
- CI via GitHub Actions with OIDC for AWS deployments

## Domain Context

**The triathlon** is a recreational competition across three bar sports:

| Sub-event | Games |
|-----------|-------|
| Bowling   | Game 1, Game 2, Game 3 |
| Pool      | 8 Ball, 9 Ball, Run |
| Darts     | Cricket, 401 Double Out, 301 Double In/Out |

**Scoring** is place-based per game:
- 1st → 3 pts, 2nd → 2 pts, 3rd → 1 pt
- Optional 4th → 0.5 pts, 5th → 0.25 pts
- Totals are aggregated: per-game → per-sub-event → triathlon total

**`ScoringDocumentV1`** is the central data type stored in DynamoDB:
- `eventId` + `year` identify the event
- `status`: `'draft'` (admin-only) | `'published'` (public)
- `participants`: array of `{ personId: string, displayName: string }`
- `subEvents`: fixed tuple of 3 sub-events, each with 3 games
- `poolMatches`: results of each pool match (round, players, tables, 8-ball/9-ball winners)
- `totals`: pre-computed points by person, by sub-event, and overall
- `finalizedGames`: tracks which individual games are locked
- `eventMeta`: competitor order, pool tables, generated pool schedule

**Admin flow**: create event → enter scores game-by-game (draft) → publish → public scoreboard updates.

**Tie-breaks** are supported: `BOWLING_ROLL_OFF`, `DARTS_BULL_SHOOTOUT`, `POOL_RUN_REPEAT`, `OTHER`.

## Important Constraints
- Static export only — avoid any Next.js feature that requires a Node.js server at runtime
- ACM certificate for CloudFront **must** be provisioned in `us-east-1`, regardless of other resource regions
- Admin routes (`/admin/scoring`) are client-side auth-gated; CloudFront does not enforce auth
- No Amplify or Cognito SDK — auth is hand-rolled PKCE to avoid bundle size and dependency churn
- next-pwa's `register: false` means the service worker is manually registered (see `PwaUpdatePrompt`)

## External Dependencies
- **AWS S3**: static asset storage (private bucket, access via CloudFront OAC)
- **AWS CloudFront**: CDN distribution, serves the static site
- **AWS Cognito**: user pool + hosted UI for admin authentication
- **AWS API Gateway (REST)**: scoring API endpoints
- **AWS Lambda**: scoring API compute
- **AWS DynamoDB**: scoring document storage
- **AWS Route53**: DNS (apex domain, no changes until cutover from legacy site)
- **AWS ACM**: TLS certificate (us-east-1)
- **Google Fonts**: Inter (body text), Permanent Marker (headings)
