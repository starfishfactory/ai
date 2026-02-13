---
description: TAM/SAM/SOM market sizing estimation
allowed-tools: WebSearch, WebFetch, Read, Write, Task
argument-hint: <market/industry>
---
# Market Sizing: $ARGUMENTS

## Request
Estimate TAM/SAM/SOM market size for **$ARGUMENTS**.

## Analysis Items
| Category | Definition | Calculation |
|----------|-----------|-------------|
| **TAM** | Total market | Industry size x ratio |
| **SAM** | Addressable market | TAM x serviceable ratio |
| **SOM** | Obtainable market | SAM x expected share |

## Output Format
```
# $ARGUMENTS Market Size

## Market Definition
- Scope:
- Region:
- Base year:

## TAM/SAM/SOM
| Category | Size | CAGR | Basis |
|----------|------|------|-------|
| TAM | $ | % | |
| SAM | $ | % | |
| SOM (3yr) | $ | % | |

## Growth Drivers
1.
2.

## Risks
1.
2.

## Sources
-
```

**Use at least one of Top-Down or Bottom-Up methods. Sources required.**
