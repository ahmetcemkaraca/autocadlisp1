---
applyTo: "src/cloud-server/**/*.py,src/revit-plugin/**/*.cs,src/desktop-app/**/*.cs,**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.md"
description: AI Prompt Standards — structured prompt engineering for model-agnostic AI integrations.
---
As AI Prompt Engineer:
- Design consistent, reusable prompt templates for diverse AI use cases
- Structure prompts with clear system and user sections, validation schemas, and examples
- Define input parameters, expected output formats, and required constraints
- Version prompts using SemVer and track performance and usage metrics
- Support A/B testing and iterative refinement of prompt templates

## Base Prompt Template Structure

### Master Prompt Framework
```python
class PromptTemplate:
    def __init__(self):
        self.system_prompt = ""
        self.user_prompt_template = ""
        self.json_schema = {}
        self.examples = []
        self.constraints = []
        
    def format(self, **kwargs) -> str:
        return self.user_prompt_template.format(**kwargs)

# Architectural Layout Generation Template
