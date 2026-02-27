# Change: Add event commentary to triathlon scoring

## Why
During a live triathlon event, notable moments happen that organizers want to capture and share — a 300 game in bowling, sinking the 8 ball on the break, a bull shootout tiebreaker. There is currently no way to record these moments and display them alongside the live scores.

## What Changes
- Add a `commentary` free-text field (`string | null`) to `ScoringDocumentV1`
- Admin UI gains a textarea for writing and editing commentary as part of the draft doc (saved via existing Save flow)
- Public scoring page renders commentary in a section at the bottom (only when non-empty)

## Impact
- Affected specs: `scoring-document`, `scoring-admin`, `scoring-public`
- Affected code:
  - `web/lib/scoring-model.ts` — new optional field on `ScoringDocumentV1` and `createEmptyScoringDocumentV1`
  - `web/app/admin/scoring/scoring-client.tsx` — commentary textarea
  - `web/app/scoring/published-client.tsx` — public commentary section
