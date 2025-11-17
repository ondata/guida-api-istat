# Implementation Tasks

## 1. Preparation

- [ ] 1.1 Save OpenAPI YAML locally in project (`docs/istat-openapi.yaml`)
- [ ] 1.2 Review current README.md structure and identify insertion points
- [ ] 1.3 Check all scripts for old endpoint URLs

## 2. README.md Updates

- [ ] 2.1 Add OpenAPI section after "Perché questa guida"
- [ ] 2.2 Document SEP (Single Exit Point) concept
- [ ] 2.3 Update base URL to `https://esploradati.istat.it/SDMXWS/rest`
- [ ] 2.4 Add link to official OpenAPI spec YAML
- [ ] 2.5 Document format parameter vs content negotiation
- [ ] 2.6 Add availableconstraint endpoint section
- [ ] 2.7 Expand query parameters section with new params:
  - startPeriod/endPeriod with SDMX period formats
  - firstNObservations/lastNObservations
  - updatedAfter
  - detail parameter values (serieskeysonly, dataonly, nodata)
  - dimensionAtObservation
  - includeHistory
- [ ] 2.8 Add structure query parameters:
  - detail (allstubs, referencestubs, referencepartial, etc.)
  - references (none, parents, children, descendants, all, concrete types)
- [ ] 2.9 Document flow parameter syntax with examples
- [ ] 2.10 Expand key parameter documentation with wildcarding
- [ ] 2.11 Add error codes section (304, 400, 406, 413, 414, 503)
- [ ] 2.12 Update note about endpoint change with v2.0.0 reference

## 3. Examples Updates

- [ ] 3.1 Add example using format parameter: `?format=jsonstructure`
- [ ] 3.2 Add example using format parameter for data: `?format=jsondata`
- [ ] 3.3 Add availableconstraint query example
- [ ] 3.4 Add detail=serieskeysonly example
- [ ] 3.5 Add time filtering examples (startPeriod/endPeriod)
- [ ] 3.6 Add SDMX period format examples (Q1, W01, S1, D001)

## 4. Script Updates

- [ ] 4.1 Update apiRestISTAT.sh endpoint references
- [ ] 4.2 Update script/aggiornamenti.sh endpoint if present
- [ ] 4.3 Update script/jiku_istat/jiku_istat.sh endpoint
- [ ] 4.4 Test scripts with new endpoint
- [ ] 4.5 Update Postman collection with new base URL

## 5. Documentation Additions

- [ ] 5.1 Create docs/ directory if not exists
- [ ] 5.2 Save OpenAPI YAML to docs/istat-openapi.yaml
- [ ] 5.3 Consider adding docs/api-parameters.md reference guide
- [ ] 5.4 Update sitografia with OpenAPI spec link

## 6. Validation

- [ ] 6.1 Test all README examples with new endpoint
- [ ] 6.2 Verify format parameter works (XML, JSON, CSV, RDF)
- [ ] 6.3 Test availableconstraint endpoint
- [ ] 6.4 Verify SDMX period formats accepted
- [ ] 6.5 Check error codes returned match documentation
- [ ] 6.6 Update LOG.md with changes
