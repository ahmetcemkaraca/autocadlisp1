---
applyTo: "**/*.md,**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.py,**/*.cs"
description: Genel AI Entegrasyon Standartları — model, platform ve domain bağımsız, sürdürülebilir, test edilebilir entegrasyon kuralları.
---

# General AI Integration Standards

## Purpose
All AI integrations must be model, platform, and domain agnostic, sustainable, testable, and reusable. Integration rules should be easily portable and parameterizable for use in other projects.

## Core Principles
- Integrations must be simple, clear, and reusable.
- Each integration must document its purpose, expected input/output format, and example flows.
- Must be independent of model (OpenAI, Gemini, Claude, etc.) and use case.
- Prefer machine-validated formats such as JSON, YAML, or Markdown.
- Integrations must be testable and versioned.
- Each integration must have at least one test case and validation schema.
- Human review requirements must be clearly indicated (e.g., requiresHumanReview).
- Domain/technology-specific details must be provided as parameters, not hardcoded.
- Must support multi-layer validation processes.

## Integration Design Template
```yaml
integration:
  description: "Short description."
  input_parameters:
    - name: "param1"
      type: "string"
      required: true
      description: "Description."
  output_format: "JSON/YAML/Markdown etc."
  constraints:
    - "Output format must strictly be ..."
    - "All fields must be filled."
  examples:
    - input: {...}
      output: {...}
  requires_human_review: true/false
  version: "1.0.0"
```

## Testing and Validation
- Each integration must have automated tests and a validation schema.
- Output must be validated against the schema and errors reported.
- Integrations should be continuously improved via A/B testing and version management.

## Versioning
- Increment version on every change (SemVer: MAJOR.MINOR.PATCH).
- Document version history and changes.

## Human Review
- Human review is mandatory for critical decisions or low confidence scores.
- Mark with requiresHumanReview field.

## Security and Transparency
- All AI outputs must be logged and traceable.
- Integrations must be reviewed for security and privacy risks.

## Model and Platform Independence
- Integrations must be model and platform agnostic, parameterized, and portable.
- Model/technology-specific optimizations should be documented separately.

## Example
