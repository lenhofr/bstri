## 1. Data model
- [x] 1.1 Add `commentary?: string | null` to `ScoringDocumentV1` in `web/lib/scoring-model.ts`
- [x] 1.2 Initialize `commentary: null` in `createEmptyScoringDocumentV1`

## 2. Admin UI
- [x] 2.1 Add commentary textarea to admin scoring page that reads/writes `doc.commentary`
- [x] 2.2 Normalize empty string to `null` before saving

## 3. Public scoring page
- [x] 3.1 Add Commentary section at the bottom of `published-client.tsx`, rendered only when `doc.commentary` is non-empty
