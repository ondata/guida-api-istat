# Custom Instructions for GitHub Copilot

## General Requirements

- Prioritize clear, readable, and maintainable code
- Provide explanatory comments for complex operations
- Follow standard best practices for each language
- Include error handling where appropriate
- Use descriptive variable and function names
- Match the language of comments and documentation to the existing project context (if files are written in Italian, continue with Italian; if in English, continue with English)

## Naming Conventions

- Use snake_case for file and variable names (e.g., check_names.sh, bucket_name)
- Use UPPERCASE for constants (e.g., MAX_RETRY_COUNT=5)
- Prefix functions with a descriptive name of their purpose (e.g., s3_list_buckets())
- Use ISO format for dates in filenames (YYYYMMDD)
- Maintain consistency in prefixes/suffixes for related files

## Dependency Management

- Document all external dependencies at the beginning of scripts
- Verify the presence of required dependencies at startup
- Provide installation instructions for missing dependencies

## Project Structure

Follow this directory structure for organizing project files:

```
/project_name/
│── /scripts/         # ETL scripts (Python, Bash, SQL, etc.)
│── /data/            # Raw and transformed data
│   ├── /raw/         # Unmodified source data
│   ├── /processed/   # Processed data
│   ├── /final/       # Data ready for use
│── /config/          # Configuration files (YAML, JSON, ENV, etc.)
│── /logs/            # ETL execution logs
│── /docs/            # Project documentation
│── /tests/           # Tests to validate transformations
│── /notebooks/       # Notebooks for analysis and debugging
│── /tmp/             # Temporary files
│── /output/          # Final results (e.g., reports, exports)
│── .gitignore        # Rules to exclude files from Git
│── .gitattributes    # Git attributes for path-specific settings
│── README.md         # Project description
│── requirements.txt  # Python dependencies (if using virtualenv)
│── Makefile          # ETL task automation
│── docker-compose.yml # If containerized environment is needed
│── .env              # Environment variables (if credentials are needed)
```

When creating new files, place them in the appropriate directory according to their purpose. Maintain this structure to ensure project organization remains consistent and intuitive.

## Git Line Ending Configuration

Always include a proper `.gitattributes` file to ensure consistent line endings across different operating systems. This prevents diff issues and ensures compatibility:

```
# Set default behavior to automatically normalize line endings
* text=auto

# Explicitly declare text files you want to always be normalized and converted
# to native line endings on checkout
*.txt text
*.md text
*.py text
*.sh text eol=lf
*.bash text eol=lf
*.json text
*.yaml text
*.yml text
*.sql text
*.csv text
*.xml text
*.html text
*.css text
*.js text

# Declare files that will always have LF line endings on checkout
# This is critical for shell scripts to work properly in Linux environments
*.sh text eol=lf
*.bash text eol=lf
Makefile text eol=lf

# Denote all files that are truly binary and should not be modified
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.pdf binary
*.zip binary
*.gz binary
*.tar binary
```

This configuration ensures that text files have consistent line endings (LF) for shell scripts and other critical files, preventing execution problems and making diffs cleaner.

## When writing Bash scripts

- Always use curly braces around variables: `${variable}` instead of `$variable`
- Use proper indentation to make code readable and maintainable
- For loops that handle text with spaces, use the proper IFS approach:

  ```bash
  while IFS= read -r line; do
    # process ${line}
  done < input_file
  ```

- Use double quotes around variables to prevent word splitting: `"${variable}"`
- Add error handling with `set -e` at the beginning of scripts to exit on error
- Use `set -u` to catch undefined variables
- Use `set -o pipefail` to exit on pipe failures
- Add meaningful comments for complex operations
- Prefer `[[` over `[` for conditional tests (more features and fewer surprises)
- Use shellcheck-compatible code
- Create functions for reusable code blocks with clear names
- Include usage examples in script headers
- Validate input parameters at the beginning of scripts
- Use command substitution with `$()` instead of backticks
- Add trap handlers for cleanup operations: `trap cleanup EXIT`
- Always include detailed requirements/dependencies at the beginning of scripts
