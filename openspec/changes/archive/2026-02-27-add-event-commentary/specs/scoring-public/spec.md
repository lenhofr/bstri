## ADDED Requirements

### Requirement: Commentary Display
The public scoring page SHALL display event commentary in a section at the bottom of the page.

#### Scenario: Commentary present
- **WHEN** the published document has a non-empty `commentary` string
- **THEN** a Commentary section is rendered at the bottom of the scoring page with the text

#### Scenario: No commentary
- **WHEN** `doc.commentary` is `null`, `undefined`, or an empty string
- **THEN** no Commentary section is rendered on the public page
