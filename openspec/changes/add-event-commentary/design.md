# Design: Event Commentary

## Context
`ScoringDocumentV1` is stored in DynamoDB and fetched by both admin and public clients. Adding a field must be backward-compatible with existing stored documents that predate this change.

## Goals / Non-Goals
- **Goals**: Minimal backward-compatible field addition; simple textarea editing in admin; simple read-only display on public page
- **Non-Goals**: Markdown/rich-text rendering, per-entry timestamps, per-entry authorship, character limits, moderation

## Decisions

- **`commentary?: string | null` (optional, nullable) on `ScoringDocumentV1`**
  - Absence and `null` are treated identically — both mean "no commentary"
  - `createEmptyScoringDocumentV1` initializes to `null`
  - No schema version bump required — additive optional field is backward-compatible

- **Commentary is part of the main scoring document, not a separate resource**
  - Written and saved via the existing `apiPutDraft` flow
  - Included in the published snapshot via the existing `apiPublish` flow
  - No new API endpoints needed

- **Empty string is normalized to `null` on save**
  - Prevents a blank Commentary section appearing on the public page after the admin clears the textarea

## Risks / Trade-offs
- Single free-text blob with no per-entry history — if the admin overwrites text, previous content is lost. Acceptable for this use case (small private event, single admin).
