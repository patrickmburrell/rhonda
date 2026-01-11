# Rhonda

**"Help me, Rhonda!"** - Your friendly repository report generator.

A simple, robust shell-based tool for generating GitHub repository activity reports. Designed for non-technical Delivery Leads to track project progress and generate client-ready status reports.

## Overview

Rhonda provides weekly (or custom timeframe) summaries of GitHub repository activity including:
- Commit frequency and contributor activity
- Pull request status (opened, merged, pending)
- Types of changes (features, bugs, refactoring, etc.)
- Lines of code changed
- Branch activity (active vs. stale)

Reports are generated in Markdown format, suitable for pasting into Slack, Teams, or client communications.

## Architecture

### Directory Structure

```
~/rhonda/
├── Brewfile                 # Homebrew dependencies
├── setup.sh                 # One-time setup script
├── bin/
│   ├── rhonda-repos.sh     # Repository management
│   └── rhonda-report.sh    # Report generation
├── repos/                  # Cloned repositories
├── reports/                # Generated reports
└── config/                 # Future: configuration files
```

### Dependencies

Managed via Homebrew (see `Brewfile`):
- `gh` - GitHub CLI for authentication and API access
- `git` - Version control operations
- `jq` - JSON parsing for gh API responses

### Scripts

#### setup.sh
One-time installation and configuration:
- Validates Homebrew installation
- Installs dependencies via `brew bundle`
- Creates directory structure
- Authenticates with GitHub via `gh auth login`
- Provides usage instructions

#### bin/rhonda-repos.sh
Interactive menu-driven repository management:
- List tracked repositories with status
- Add new repository (clone from GitHub)
- Remove repository (delete local copy)
- Update all repositories (git fetch)

#### bin/rhonda-report.sh
Comprehensive report generation:
- Interactive repository selection
- Date range selection (7/14/30 days or custom)
- Auto-updates repository data
- Analyzes 5 key metrics
- Generates Markdown report
- Provides copy/open instructions

## Key Metrics Implementation

### 1. Commit Frequency and Authors
Uses `git log` with custom format to extract:
- Author name, email, message, date
- Groups by author with commit counts
- Aggregates by day for activity patterns

### 2. Pull Request Activity
Uses `gh pr list` with JSON output to track:
- PRs opened in period
- PRs merged in period
- PRs closed without merge
- Currently pending PRs

Filters by date using ISO 8601 timestamps and `jq`.

### 3. Types of Changes
Parses commit messages for conventional commit patterns:
- `feat:` or `feature:` → Features
- `fix:` or `bugfix:` → Bug Fixes
- `refactor:` → Refactoring
- `docs:` or `doc:` → Documentation
- Everything else → Other

### 4. Lines of Code Changed
Uses `git log --shortstat` to aggregate:
- Files changed
- Lines added (insertions)
- Lines removed (deletions)
- Net change (growth/reduction)

### 5. Branch Activity
Uses `git for-each-ref` on remote branches to identify:
- Active branches (commits in reporting period)
- Stale branches (no commits in period)
- Last commit date for each branch

## Report Format

Generated reports follow this structure:
1. **Header**: Repository name, period, timestamp
2. **Summary**: High-level metrics
3. **Commit Activity**: By author and by day
4. **Pull Request Status**: Merged, pending, closed
5. **Types of Changes**: Categorized breakdown with percentages
6. **Code Changes**: Files and LOC metrics
7. **Branch Activity**: Active and stale branches
8. **Key Highlights**: Auto-generated notable items

Reports are saved as: `{repo-name}_{start-date}_to_{end-date}.md`

## Authentication

Uses GitHub CLI (`gh`) OAuth flow:
- One-time browser-based authentication
- Handles both HTTPS and SSH repository access
- Stores credentials securely via system keychain
- Works with both git operations and GitHub API calls

No separate Git Credential Manager needed.

## Design Principles

### Simplicity
- Menu-driven interfaces (no command-line arguments to remember)
- Clear prompts and feedback
- Sensible defaults (7-day reports)

### Robustness
- Bash error handling: `set -euo pipefail`
- Dependency checks before operations
- Graceful handling of empty results
- Clear error messages

### Non-Technical User Focus
- Plain language prompts
- No git/CLI knowledge required
- Copy-paste friendly output
- Comprehensive user guide

### Read-Only Operations
- Never commits changes
- Never creates branches
- Never pushes code
- Only fetches and reads

## Installation on New Machine

1. Copy the entire `rhonda` directory to `~/rhonda`
2. Open Terminal and run:
   ```bash
   cd ~/rhonda
   ./setup.sh
   ```
3. Follow the prompts to install dependencies and authenticate

## Maintenance

### Updating Dependencies
```bash
cd ~/rhonda
brew bundle
```

### Cleaning Old Reports
Reports accumulate in `reports/` directory. Clean periodically:
```bash
rm ~/rhonda/reports/*_2024-*.md
```

### Re-authenticating
If authentication expires:
```bash
gh auth login
```

## Future Enhancements (Phase 4)

Potential features for future development:
- **Config file support**: Store repository list in `config/repos.conf`
- **Batch reporting**: Generate reports for all tracked repos at once
- **Diff reports**: Compare current period vs. previous period
- **Export formats**: HTML or PDF output options
- **Automated scheduling**: Use cron/launchd for weekly automatic reports
- **Notification**: Email or Slack integration for report delivery

## Troubleshooting

### Scripts Not Executable
```bash
chmod +x ~/rhonda/setup.sh
chmod +x ~/rhonda/bin/*.sh
```

### Dependencies Missing
```bash
cd ~/rhonda
brew bundle --force
```

### Authentication Issues
```bash
gh auth status          # Check status
gh auth logout          # Logout
gh auth login           # Login again
```

### Repository Won't Clone
- Verify user has read access on GitHub
- Check if URL is correct (copy from GitHub)
- Ensure authentication is working: `gh auth status`

### Empty Reports
- Repository might have no activity in period
- Try longer period (14 or 30 days)
- Verify repository was updated: run repo-manager option 4

## Technical Notes

### macOS Date Command Compatibility
The scripts handle both BSD (macOS) and GNU date commands:
```bash
date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d
```

### Bash Arrays and Loops
Uses bash arrays for repository selection menus, with careful quoting:
```bash
repos=()
repos+=("${repo_name}")
SELECTED_REPO="${repos[$((choice-1))]}"
```

### Heredoc for Report Generation
Uses bash heredocs for clean report formatting:
```bash
cat > "${report_file}" << EOF
# Report Content
${VARIABLE}
EOF
```

### Error Handling
Consistent error handling pattern:
```bash
if ! command; then
    print_error "Message"
    exit 1
fi
```

## License

Internal tool - no formal license.

## Credits

**Rhonda** - Named after "Help Me, Rhonda" by the Beach Boys, because everyone needs help with repository reports!

Created for PMB Delivery Leads to streamline project status reporting.

Built with: bash, git, gh (GitHub CLI), jq
