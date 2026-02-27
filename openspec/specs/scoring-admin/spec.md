# scoring-admin Specification

## Purpose
TBD - created by archiving change add-event-commentary. Update Purpose after archive.
## Requirements
### Requirement: Commentary Editing
The admin scoring UI SHALL provide a textarea for writing and editing free-text event commentary.

#### Scenario: Admin writes commentary
- **WHEN** the admin types text into the commentary textarea
- **THEN** `doc.commentary` is updated in local state

#### Scenario: Commentary saved with draft
- **WHEN** the admin clicks Save
- **THEN** `doc.commentary` is persisted as part of the draft document via the existing save flow

#### Scenario: Empty commentary normalized
- **WHEN** the commentary textarea is empty or cleared
- **THEN** `doc.commentary` is stored as `null`, not as an empty string

