# API Documentation Specification

## ADDED Requirements

### Requirement: OpenAPI Specification Reference

Guide SHALL reference official OpenAPI v3 specification for ISTAT SDMX REST API.

#### Scenario: User discovers official API specs

- **WHEN** user reads guide introduction
- **THEN** OpenAPI spec link is provided with version 2.0.0
- **AND** endpoint base URL `https://esploradati.istat.it/SDMXWS/rest` is documented

#### Scenario: User needs formal API documentation

- **WHEN** user requires parameter details
- **THEN** OpenAPI YAML URL is available: `https://raw.githubusercontent.com/teamdigitale/api-openapi-samples/master/external-apis/istat-sdmx-rest.yaml`

### Requirement: SEP (Single Exit Point) Documentation

Guide SHALL document SEP concept and characteristics.

#### Scenario: User learns about SEP

- **WHEN** user reads API overview
- **THEN** SEP definition is provided
- **AND** free access is documented
- **AND** supported formats (XML, JSON, CSV, RDF) are listed

#### Scenario: User understands content negotiation

- **WHEN** user learns format selection
- **THEN** HTTP content negotiation mechanism is explained
- **AND** format parameter alternative is documented with examples

### Requirement: Data Query Parameters

Guide SHALL document all query parameters from OpenAPI spec v2.0.0.

#### Scenario: User filters by time period

- **WHEN** user queries data endpoint
- **THEN** startPeriod parameter is documented with SDMX period format
- **AND** endPeriod parameter is documented
- **AND** examples show ISO 8601 and SDMX formats (2000-Q1, 2000-W01, etc.)

#### Scenario: User limits observation count

- **WHEN** user needs subset of data
- **THEN** firstNObservations parameter is documented
- **AND** lastNObservations parameter is documented

#### Scenario: User tracks data updates

- **WHEN** user performs incremental updates
- **THEN** updatedAfter parameter is documented (date-time format)

### Requirement: Data Availability Query

Guide SHALL document availableconstraint endpoint.

#### Scenario: User checks data availability

- **WHEN** user wants to verify data existence before download
- **THEN** `/availableconstraint/{flow}/{key}/{componentID}` endpoint is documented
- **AND** mode parameter (exact|available) is explained
- **AND** purpose of showing valid dimension values is clear

### Requirement: Detail Parameter Documentation

Guide SHALL document detail parameter values for data queries.

#### Scenario: User retrieves series keys only

- **WHEN** user wants overview without observations
- **THEN** detail=serieskeysonly option is documented
- **AND** use case (overview pages) is explained

#### Scenario: User retrieves data without attributes

- **WHEN** user wants minimal data payload
- **THEN** detail=dataonly option is documented

#### Scenario: User retrieves structure without observations

- **WHEN** user wants metadata only
- **THEN** detail=nodata option is documented

### Requirement: Structure Detail Parameter

Guide SHALL document detail parameter for metadata queries.

#### Scenario: User retrieves stub metadata

- **WHEN** user queries structures
- **THEN** allstubs, referencestubs options are documented
- **AND** referencepartial option is explained (isPartial flag)
- **AND** allcompletestubs, referencecompletestubs options are listed

### Requirement: References Parameter

Guide SHALL document references parameter for metadata queries.

#### Scenario: User retrieves referenced artefacts

- **WHEN** user queries structures
- **THEN** references parameter values are documented
- **AND** values include: none, parents, parentsandsiblings, children, descendants, all
- **AND** concrete resource types (codelist, datastructure, etc.) are listed

### Requirement: Flow Parameter Format

Guide SHALL document flow parameter syntax with examples.

#### Scenario: User constructs flow parameter

- **WHEN** user builds data query
- **THEN** simple format (115_333) is shown
- **AND** agency format (IT1,115_333) is shown
- **AND** version format (IT1,115_333,1.2) is shown
- **AND** pattern is documented: `[agencyID,]resourceID[,version]`

### Requirement: Key Parameter Format

Guide SHALL document key parameter syntax with wildcarding.

#### Scenario: User builds dimension key

- **WHEN** user filters data by dimensions
- **THEN** full key format is documented (M.DE.000000.ANR)
- **AND** wildcard operator (..) is explained
- **AND** OR operator (+) is documented (A+M for annual+monthly)
- **AND** examples from official spec are included

### Requirement: Error Responses

Guide SHALL document HTTP error codes from API.

#### Scenario: User handles API errors

- **WHEN** user receives error response
- **THEN** error codes are documented: 400 (bad syntax), 406 (not acceptable), 413 (too large), 414 (URI too long), 503 (unavailable)
- **AND** 304 (not modified) is explained for If-Modified-Since header
