# Project Context

## Purpose

Comprehensive guide and documentation for accessing ISTAT (Italian National Statistics Institute) data via REST APIs.

Goals:

- Demystify and document SDMX REST API access to ISTAT's data warehouse
- Provide reusable scripts and recipes for data extraction/processing
- Fill gap left by ISTAT's lack of official REST API documentation
- Support data professionals, researchers, developers accessing Italian statistical datasets
- Maintain automated synchronization with ISTAT data updates

Target audience: data analysts, statisticians, developers interested in Italian statistical data.

## Tech Stack

- **Bash/Shell Scripts**: core orchestration and data fetching
- **Data Standards**: SDMX (Statistical Data and Metadata eXchange)
- **CLI Tools**:
  - jq: JSON querying/transformation
  - miller (mlr): CSV/JSON data reshaping
  - xq: XML to JSON conversion
  - curl: HTTP requests to ISTAT APIs
- **CI/CD**: GitHub Actions (scheduled data updates)
- **Data Formats**: XML, JSON, CSV

Note: This is a documentation + utilities project, not a compiled application.

## Project Conventions

### Code Style

**Bash Scripts:**

- Robust error handling: `set -e`, `set -u`, `set -o pipefail`
- Logging with timestamps: ISO 8601 dates
- Command validation: explicit checks for required tools
- Cleanup discipline: explicit temp directory management
- Path safety: `$(cd ... && pwd)` for absolute paths
- Inline comments for non-obvious operations

**Documentation:**

- Italian primary language (per domain)
- Markdown headings: no numbering (manual maintenance burden)
- Code blocks: always preceded by blank line
- Lists after colons: always preceded by blank line

### Architecture Patterns

**Data Processing Pipeline:**

```
Fetch XML → Convert to JSON → Extract/Transform (jq) → Reshape (mlr) → Output CSV/JSON
```

Example:
```bash
curl API > .xml → xq → .json → jq extract → mlr reshape → final format
```

**Naming Conventions:**

- Dataflow IDs: numeric (e.g., `41_983`)
- Structure IDs: UPPERCASE (e.g., `DCIS_INCIDMORFER_COM`)
- Codelist IDs: `CL_` prefix (e.g., `CL_FREQ`)
- Files: descriptive lowercase with underscores

**Documentation First:**

- Extensive markdown guides prioritize learning over code
- Real API examples throughout documentation
- Explanation-heavy approach to SDMX concepts

### Testing Strategy

Manual validation via:

- GitHub Actions scheduled runs (daily/weekly)
- Comparison of downloaded data with previous versions
- Postman collections for API endpoint testing

No formal unit/integration tests (documentation/utility project).

### Git Workflow

- Branch: `master` (main branch)
- Commits: concise, sacrifice grammar for brevity
- Auto-commits via GitHub Actions when data updates detected
- LOG.md: project changelog with YYYY-MM-DD headings (newest first)

## Domain Context

**SDMX (Statistical Data and Metadata eXchange):**

- International standard for exchanging statistical data/metadata
- Core concepts:
  - **Dataflow**: dataset identifier (e.g., "Road accidents by municipality")
  - **Datastructure**: schema defining dimensions, attributes, measures
  - **Codelist**: enumeration of valid values for dimensions
  - **Dimension**: classification axis (e.g., TIME_PERIOD, REF_AREA)
  - **Constraint**: rules limiting valid dimension combinations

**ISTAT Context:**

- AgencyID: `IT1`
- ~450 dataflows available (as of 2020)
- Bilingual: Italian and English labels
- Historical endpoint: `http://sdmx.istat.it/SDMXWS/rest/`
- Current endpoint: `https://esploradati.istat.it/SDMXWS` (as of 2024)

## Important Constraints

- ISTAT API: no official REST documentation (reason for this project)
- SDMX XML: verbose, requires xq conversion for practical use
- Italian language: primary documentation language (target audience)
- Data freshness: dependent on ISTAT update schedule
- CLI-only: no web UI, command line expertise required

## External Dependencies

**ISTAT APIs:**

- Metadata endpoint: `/structure/` (dataflow, datastructure, codelist, etc.)
- Data endpoint: `/data/{flowRef}/{key}?{params}`
- Base URL: `https://esploradati.istat.it/SDMXWS/rest/`

**Required CLI Tools:**

- curl (HTTP requests)
- jq (JSON processing)
- miller (CSV/JSON transformation)
- xq (XML to JSON conversion)
- git (version control)

**GitHub Actions:**

- Scheduled workflows for data synchronization
- Automated commit/push on data changes
