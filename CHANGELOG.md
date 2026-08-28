## [Unreleased]

- Add duplication context to prevent cycle loops when cloning associtations. It tracks already duplicated records within a single `ditto` call and reuses them.

## [1.0.0] - 2026-08-28

- Initial release.
- `acts_as_ditto` DSL for configuring how a model duplicates.
- Configuration options: `clone_associations`, `nullify`, `reset_to_default`,
  `override`, `prefix`/`suffix`, and `transform`.
