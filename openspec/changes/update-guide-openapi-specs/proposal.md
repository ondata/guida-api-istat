# Change: Update Guide with Official OpenAPI Specifications

## Why

Current guide lacks reference to official OpenAPI v3 specs published by Italian Digital Team. Specs provide:

- Formal API v2.0.0 documentation
- Complete parameter descriptions
- Official endpoint examples
- SEP (Single Exit Point) details
- Response format specifications

Adding OpenAPI reference improves guide completeness and aligns with official ISTAT documentation.

## What Changes

- Add OpenAPI specification section to README.md
- Document new v2 endpoint: `https://esploradati.istat.it/SDMXWS/rest`
- Include link to official OpenAPI YAML
- Add examples from OpenAPI spec (format parameter, new query params)
- Update endpoint references throughout guide
- Add availableconstraint endpoint documentation

## Impact

- Affected specs: api-documentation
- Affected code: README.md, examples, scripts
- Users gain access to official API specs
- Guide reflects current ISTAT API v2.0.0
