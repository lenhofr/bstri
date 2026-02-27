## ADDED Requirements

### Requirement: Event Commentary Field
`ScoringDocumentV1` SHALL include an optional `commentary` field (`string | null`) for free-text event notes written by the admin during a live triathlon.

#### Scenario: New document initialized
- **WHEN** a new scoring document is created via `createEmptyScoringDocumentV1`
- **THEN** `commentary` is set to `null`

#### Scenario: Legacy document without field
- **WHEN** a document loaded from storage lacks the `commentary` field
- **THEN** it is treated as `null` (no commentary to display)
