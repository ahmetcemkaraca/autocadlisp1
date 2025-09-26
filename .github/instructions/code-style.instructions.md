---
applyTo: "src/revit-plugin/**/*.cs,src/mcp-server/**/*.py,src/ai-models/**/*.cs,**/*.ts,**/*.tsx,**/*.js,**/*.jsx"
description: Code Style Standards — consistent formatting, structure, and best practices across all technologies.
---
As Code Style Developer:
- Apply consistent formatting rules across C#, Python, TypeScript, and JavaScript
- Follow technology-specific best practices while maintaining cross-language consistency
- Implement proper code organization, commenting, and documentation standards
- Ensure code readability and maintainability for AI-generated code
- Establish patterns for async/await, error handling, and dependency injection

## C# Code Style Standards



## General Code Organization Principles

### File Structure Standards
```
src/
├── core/                       # Shared core functionality
│   ├── interfaces/            # Interface definitions
│   ├── models/               # Data models and DTOs
│   ├── exceptions/           # Custom exception classes
│   └── constants/            # Application constants
├── services/                  # Business logic services
│   ├── ai/                   # AI-related services
│   ├── validation/           # Validation services
│   └── revit/               # Revit API services
├── infrastructure/           # Infrastructure concerns
│   ├── data/                # Data access layer
│   ├── external/            # External service clients
│   └── logging/             # Logging configuration
└── presentation/             # UI and API controllers
    ├── api/                 # REST API controllers
    ├── websockets/          # WebSocket handlers
    └── ui/                  # User interface components
```

### Comment and Documentation Standards
```csharp
/// <summary>
/// Generates an architectural layout using AI models with comprehensive validation.
/// This method handles the complete workflow from prompt processing to result validation.
/// </summary>
/// <param name="request">The layout generation request containing user requirements</param>
/// <param name="correlationId">Unique identifier for tracking this operation across services</param>
/// <param name="cancellationToken">Token to cancel the operation if needed</param>
/// <returns>
/// A <see cref="LayoutResult"/> containing the generated layout, validation results,
/// and metadata about the AI processing.
/// </returns>
/// <exception cref="ValidationException">
/// Thrown when input validation fails or AI output is invalid
/// </exception>
/// <exception cref="AIServiceException">
/// Thrown when the AI service fails after all retry attempts
/// </exception>
/// <example>
/// <code>
/// var request = new LayoutGenerationRequest
/// {
///     UserPrompt = "Create a 2-bedroom apartment",
///     TotalAreaM2 = 80,
///     BuildingType = "residential"
/// };
/// 
/// var result = await service.GenerateLayoutAsync(request, correlationId);
/// if (result.RequiresHumanReview)
/// {
///     // Handle human review workflow
/// }
/// </code>
/// </example>
public async Task<LayoutResult> GenerateLayoutAsync(
    LayoutGenerationRequest request,
    string correlationId,
    CancellationToken cancellationToken = default)
{
    // Method implementation
}
```

Always prioritize readability, maintain consistent formatting, include comprehensive error handling, and document complex logic with clear comments.
