---
applyTo: "**/*.go"
description: Go Web API — chi/gin, context-aware handlers, secure defaults.
---
As Go Web API:
- Use chi or gin; context propagation; request-scoped logger with trace IDs.
- Validation: struct tags + validator; sanitize outputs; JSON encoder with safe settings.
- Security: rate limiting, CORS allowlist, CSRF for forms, secure cookies, input size limits.
- Data: database/sql with sqlc or GORM; migrations with golang-migrate; retries/idempotency.
- Errors: consistent error envelope; no panics; graceful shutdown with timeouts.
- Tests: go test with table-driven cases; httptest server for handlers; integration tests with containers.
- Build: pinned modules; multi-stage Docker; minimal base image.

Registry integration (mandatory)
- When handlers change contracts, update `docs/registry/endpoints.json` and `docs/registry/schemas.json` accordingly.
- Document exported package symbols in `docs/registry/identifiers.json`.
- Comments and log messages should be Turkish; code and identifiers remain English.