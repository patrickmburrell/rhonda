#!/usr/bin/env bash
set -euo pipefail

#========================================================================================================
# Rhonda Report - Repository Activity Report Generator
# "Help me, Rhonda!" - Generate comprehensive activity reports for GitHub repositories
#========================================================================================================

# Resolve symlink to get actual script location
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")/.." && pwd)"
REPOS_DIR="${SCRIPT_DIR}/repos"
REPORTS_DIR="${SCRIPT_DIR}/reports"

#--------------------------------------------------------------------------------------------------------

print_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
    echo ""
}

#--------------------------------------------------------------------------------------------------------

print_success() {
    echo "✓ $1"
}

#--------------------------------------------------------------------------------------------------------

print_error() {
    echo "✗ ERROR: $1" >&2
}

#--------------------------------------------------------------------------------------------------------

print_info() {
    echo "ℹ $1"
}

#--------------------------------------------------------------------------------------------------------

check_dependencies() {
    local missing=()
    
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if ! command -v gh &> /dev/null; then
        missing+=("gh")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing[*]}"
        echo "Run setup.sh to install dependencies"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI is not authenticated"
        echo "Run: gh auth login"
        exit 1
    fi
}

#--------------------------------------------------------------------------------------------------------

select_repository() {
    print_header "Select Repository"
    
    if [[ ! -d "${REPOS_DIR}" ]] || [[ -z "$(ls -A "${REPOS_DIR}" 2>/dev/null)" ]]; then
        print_error "No repositories found. Use repo-manager.sh to add repositories first."
        exit 1
    fi
    
    echo "Available repositories:"
    echo ""
    
    local repos=()
    local index=1
    
    for repo_path in "${REPOS_DIR}"/*; do
        if [[ -d "${repo_path}/.git" ]]; then
            local repo_name=$(basename "${repo_path}")
            repos+=("${repo_name}")
            echo "  ${index}) ${repo_name}"
            ((index++))
        fi
    done
    
    if [[ ${#repos[@]} -eq 0 ]]; then
        print_error "No valid repositories found"
        exit 1
    fi
    
    echo ""
    read -p "Choose repository number: " choice
    
    if [[ ! "${choice}" =~ ^[0-9]+$ ]] || [[ ${choice} -lt 1 ]] || [[ ${choice} -gt ${#repos[@]} ]]; then
        print_error "Invalid choice"
        exit 1
    fi
    
    SELECTED_REPO="${repos[$((choice-1))]}"
    REPO_PATH="${REPOS_DIR}/${SELECTED_REPO}"
}

#--------------------------------------------------------------------------------------------------------

select_date_range() {
    print_header "Select Date Range"
    
    echo "Choose reporting period:"
    echo ""
    echo "1) Last 7 days (default)"
    echo "2) Last 14 days"
    echo "3) Last 30 days"
    echo "4) Custom date range"
    echo ""
    read -p "Choose option [1]: " period_choice
    
    period_choice=${period_choice:-1}
    
    case ${period_choice} in
        1)
            DAYS_AGO=7
            SINCE_DATE=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d)
            ;;
        2)
            DAYS_AGO=14
            SINCE_DATE=$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)
            ;;
        3)
            DAYS_AGO=30
            SINCE_DATE=$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)
            ;;
        4)
            echo ""
            read -p "Enter start date (YYYY-MM-DD): " SINCE_DATE
            if [[ ! "${SINCE_DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                print_error "Invalid date format"
                exit 1
            fi
            DAYS_AGO="custom"
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac
    
    END_DATE=$(date +%Y-%m-%d)
}

#--------------------------------------------------------------------------------------------------------

update_repository() {
    print_info "Updating repository data..."
    cd "${REPO_PATH}"
    git fetch --all --prune &> /dev/null
    print_success "Repository updated"
}

#--------------------------------------------------------------------------------------------------------

analyze_commits() {
    cd "${REPO_PATH}"
    
    local commit_data
    commit_data=$(git log --all --since="${SINCE_DATE}" --format="%an|%ae|%s|%ad|%H" --date=format:%Y-%m-%d 2>/dev/null || echo "")
    
    TOTAL_COMMITS=$(echo "${commit_data}" | grep -c '.' || echo "0")
    
    if [[ ${TOTAL_COMMITS} -eq 0 ]]; then
        COMMIT_BY_AUTHOR=""
        COMMIT_BY_DAY=""
        ACTIVE_CONTRIBUTORS=0
        return
    fi
    
    COMMIT_BY_AUTHOR=$(echo "${commit_data}" | awk -F'|' '{print $1}' | sort | uniq -c | sort -rn)
    ACTIVE_CONTRIBUTORS=$(echo "${COMMIT_BY_AUTHOR}" | wc -l | tr -d ' ')
    
    COMMIT_BY_DAY=$(echo "${commit_data}" | awk -F'|' '{print $4}' | sort | uniq -c | sort -k2)
    
    COMMIT_MESSAGES=$(echo "${commit_data}" | awk -F'|' '{print $3}')
}

#--------------------------------------------------------------------------------------------------------

analyze_change_types() {
    if [[ -z "${COMMIT_MESSAGES}" ]]; then
        FEATURES=0
        BUGFIXES=0
        REFACTORING=0
        DOCUMENTATION=0
        OTHER=0
        return
    fi
    
    FEATURES=$(echo "${COMMIT_MESSAGES}" | grep -ciE '^(feat|feature):' || echo "0")
    BUGFIXES=$(echo "${COMMIT_MESSAGES}" | grep -ciE '^(fix|bugfix):' || echo "0")
    REFACTORING=$(echo "${COMMIT_MESSAGES}" | grep -ciE '^(refactor|refactoring):' || echo "0")
    DOCUMENTATION=$(echo "${COMMIT_MESSAGES}" | grep -ciE '^(docs|doc):' || echo "0")
    
    local categorized=$((FEATURES + BUGFIXES + REFACTORING + DOCUMENTATION))
    OTHER=$((TOTAL_COMMITS - categorized))
    
    if [[ ${OTHER} -lt 0 ]]; then
        OTHER=0
    fi
}

#--------------------------------------------------------------------------------------------------------

analyze_code_changes() {
    cd "${REPO_PATH}"
    
    local stats
    stats=$(git log --all --since="${SINCE_DATE}" --shortstat --format="" 2>/dev/null || echo "")
    
    if [[ -z "${stats}" ]]; then
        FILES_CHANGED=0
        LINES_ADDED=0
        LINES_REMOVED=0
        NET_CHANGE=0
        return
    fi
    
    FILES_CHANGED=$(echo "${stats}" | awk '{s+=$1} END {print s+0}')
    LINES_ADDED=$(echo "${stats}" | awk '{for(i=1;i<=NF;i++){if($i=="insertions(+)"){s+=$(i-1)}}} END {print s+0}')
    LINES_REMOVED=$(echo "${stats}" | awk '{for(i=1;i<=NF;i++){if($i=="deletions(-)"){s+=$(i-1)}}} END {print s+0}')
    NET_CHANGE=$((LINES_ADDED - LINES_REMOVED))
}

#--------------------------------------------------------------------------------------------------------

analyze_pull_requests() {
    cd "${REPO_PATH}"
    
    local since_iso="${SINCE_DATE}T00:00:00Z"
    
    local pr_data
    pr_data=$(gh pr list --repo "$(git remote get-url origin)" --state all --limit 200 --json number,title,state,createdAt,closedAt,mergedAt,author 2>/dev/null || echo "[]")
    
    PR_OPENED=$(echo "${pr_data}" | jq --arg since "${since_iso}" '[.[] | select(.createdAt >= $since)] | length' 2>/dev/null || echo "0")
    PR_MERGED=$(echo "${pr_data}" | jq --arg since "${since_iso}" '[.[] | select(.mergedAt != null and .mergedAt >= $since)] | length' 2>/dev/null || echo "0")
    PR_CLOSED=$(echo "${pr_data}" | jq --arg since "${since_iso}" '[.[] | select(.closedAt != null and .mergedAt == null and .closedAt >= $since)] | length' 2>/dev/null || echo "0")
    PR_PENDING=$(echo "${pr_data}" | jq '[.[] | select(.state == "OPEN")] | length' 2>/dev/null || echo "0")
    
    PR_MERGED_LIST=$(echo "${pr_data}" | jq -r --arg since "${since_iso}" '.[] | select(.mergedAt != null and .mergedAt >= $since) | "- #\(.number): \(.title) - merged by @\(.author.login) on \(.mergedAt[:10])"' 2>/dev/null || echo "")
    
    PR_PENDING_LIST=$(echo "${pr_data}" | jq -r --arg since "${since_iso}" '.[] | select(.state == "OPEN" and .createdAt >= $since) | "- #\(.number): \(.title) - opened by @\(.author.login) on \(.createdAt[:10])"' 2>/dev/null || echo "")
    
    PR_CLOSED_LIST=$(echo "${pr_data}" | jq -r --arg since "${since_iso}" '.[] | select(.closedAt != null and .mergedAt == null and .closedAt >= $since) | "- #\(.number): \(.title) - closed on \(.closedAt[:10])"' 2>/dev/null || echo "")
}

#--------------------------------------------------------------------------------------------------------

analyze_branches() {
    cd "${REPO_PATH}"
    
    local branch_data
    branch_data=$(git for-each-ref --sort=-committerdate refs/remotes/origin/ --format="%(refname:short)|%(committerdate:short)" 2>/dev/null || echo "")
    
    ACTIVE_BRANCHES=""
    STALE_BRANCHES=""
    
    while IFS='|' read -r branch date; do
        if [[ -z "${branch}" ]]; then
            continue
        fi
        
        branch=$(echo "${branch}" | sed 's|^origin/||')
        
        if [[ "${date}" > "${SINCE_DATE}" ]] || [[ "${date}" == "${SINCE_DATE}" ]]; then
            ACTIVE_BRANCHES="${ACTIVE_BRANCHES}- ${branch} (last commit: ${date})\n"
        else
            STALE_BRANCHES="${STALE_BRANCHES}- ${branch} (last commit: ${date})\n"
        fi
    done <<< "${branch_data}"
}

#--------------------------------------------------------------------------------------------------------

generate_report() {
    local report_file="${REPORTS_DIR}/${SELECTED_REPO}_${SINCE_DATE}_to_${END_DATE}.md"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    cat > "${report_file}" << EOF
# Repository Activity Report

**Repository:** ${SELECTED_REPO}
**Period:** ${SINCE_DATE} to ${END_DATE}
**Generated:** ${timestamp}

---

## Summary

- Total Commits: ${TOTAL_COMMITS}
- Active Contributors: ${ACTIVE_CONTRIBUTORS}
- Pull Requests: ${PR_OPENED} opened, ${PR_MERGED} merged, ${PR_PENDING} pending
- Net Lines Changed: +${LINES_ADDED} / -${LINES_REMOVED}

---

## Commit Activity

### By Author

EOF

    if [[ -n "${COMMIT_BY_AUTHOR}" ]]; then
        while read -r count author; do
            echo "- ${author}: ${count} commits" >> "${report_file}"
        done <<< "${COMMIT_BY_AUTHOR}"
    else
        echo "No commit activity in this period." >> "${report_file}"
    fi

    cat >> "${report_file}" << EOF

### By Day

EOF

    if [[ -n "${COMMIT_BY_DAY}" ]]; then
        while read -r count date; do
            local day_name=$(date -j -f "%Y-%m-%d" "${date}" "+%A" 2>/dev/null || date -d "${date}" "+%A" 2>/dev/null || echo "")
            if [[ -n "${day_name}" ]]; then
                echo "- ${date} (${day_name}): ${count} commits" >> "${report_file}"
            else
                echo "- ${date}: ${count} commits" >> "${report_file}"
            fi
        done <<< "${COMMIT_BY_DAY}"
    else
        echo "No commit activity in this period." >> "${report_file}"
    fi

    cat >> "${report_file}" << EOF

---

## Pull Request Status

### Merged This Period (${PR_MERGED})

EOF

    if [[ -n "${PR_MERGED_LIST}" ]]; then
        echo "${PR_MERGED_LIST}" >> "${report_file}"
    else
        echo "No pull requests merged in this period." >> "${report_file}"
    fi

    cat >> "${report_file}" << EOF

### Opened and Pending (${PR_PENDING})

EOF

    if [[ -n "${PR_PENDING_LIST}" ]]; then
        echo "${PR_PENDING_LIST}" >> "${report_file}"
    else
        echo "No pending pull requests opened in this period." >> "${report_file}"
    fi

    cat >> "${report_file}" << EOF

### Closed Without Merge (${PR_CLOSED})

EOF

    if [[ -n "${PR_CLOSED_LIST}" ]]; then
        echo "${PR_CLOSED_LIST}" >> "${report_file}"
    else
        echo "No pull requests closed without merge in this period." >> "${report_file}"
    fi

    cat >> "${report_file}" << EOF

---

## Types of Changes

EOF

    if [[ ${TOTAL_COMMITS} -gt 0 ]]; then
        local feat_pct=$((FEATURES * 100 / TOTAL_COMMITS))
        local fix_pct=$((BUGFIXES * 100 / TOTAL_COMMITS))
        local refactor_pct=$((REFACTORING * 100 / TOTAL_COMMITS))
        local docs_pct=$((DOCUMENTATION * 100 / TOTAL_COMMITS))
        local other_pct=$((OTHER * 100 / TOTAL_COMMITS))
        
        cat >> "${report_file}" << EOFINNER
- Features: ${FEATURES} commits (${feat_pct}%)
- Bug Fixes: ${BUGFIXES} commits (${fix_pct}%)
- Refactoring: ${REFACTORING} commits (${refactor_pct}%)
- Documentation: ${DOCUMENTATION} commits (${docs_pct}%)
- Other: ${OTHER} commits (${other_pct}%)
EOFINNER
    else
        echo "No commits to analyze." >> "${report_file}"
    fi

    cat >> "${report_file}" << EOF

---

## Code Changes

- Files Changed: ${FILES_CHANGED}
- Lines Added: +${LINES_ADDED}
- Lines Removed: -${LINES_REMOVED}
- Net Change: ${NET_CHANGE:+}${NET_CHANGE}

---

## Branch Activity

### Active Branches (updated in period)

EOF

    if [[ -n "${ACTIVE_BRANCHES}" ]]; then
        echo -e "${ACTIVE_BRANCHES}" | sed '$d' >> "${report_file}"
    else
        echo "No branches updated in this period." >> "${report_file}"
    fi

    cat >> "${report_file}" << EOF

### Stale Branches (no activity in period)

EOF

    if [[ -n "${STALE_BRANCHES}" ]]; then
        echo -e "${STALE_BRANCHES}" | sed '$d' | head -n 10 >> "${report_file}"
        local stale_count=$(echo -e "${STALE_BRANCHES}" | grep -c '.' || echo "0")
        if [[ ${stale_count} -gt 10 ]]; then
            echo "... and $((stale_count - 10)) more stale branches" >> "${report_file}"
        fi
    else
        echo "All branches have recent activity." >> "${report_file}"
    fi

    cat >> "${report_file}" << EOF

---

## Key Highlights

EOF

    if [[ ${TOTAL_COMMITS} -gt 0 ]]; then
        local busiest_day=$(echo "${COMMIT_BY_DAY}" | sort -k1 -rn | head -n1 | awk '{print $2}')
        local busiest_count=$(echo "${COMMIT_BY_DAY}" | sort -k1 -rn | head -n1 | awk '{print $1}')
        local top_contributor=$(echo "${COMMIT_BY_AUTHOR}" | head -n1 | awk '{$1=""; print substr($0,2)}')
        local top_count=$(echo "${COMMIT_BY_AUTHOR}" | head -n1 | awk '{print $1}')
        
        echo "- Most active day: ${busiest_day} (${busiest_count} commits)" >> "${report_file}"
        echo "- Most active contributor: ${top_contributor} (${top_count} commits)" >> "${report_file}"
    fi
    
    if [[ ${PR_MERGED} -gt 0 ]]; then
        echo "- Pull requests merged: ${PR_MERGED}" >> "${report_file}"
    fi
    
    if [[ ${NET_CHANGE} -gt 0 ]]; then
        echo "- Net code growth: +${NET_CHANGE} lines" >> "${report_file}"
    elif [[ ${NET_CHANGE} -lt 0 ]]; then
        echo "- Net code reduction: ${NET_CHANGE} lines" >> "${report_file}"
    fi

    echo "" >> "${report_file}"
    
    REPORT_FILE="${report_file}"
}

#--------------------------------------------------------------------------------------------------------

display_report_summary() {
    print_header "Report Generated"
    
    local report_name=$(basename "${REPORT_FILE}")
    
    print_success "Report saved: ${report_name}"
    echo ""
    echo "Quick Summary:"
    echo "  Commits: ${TOTAL_COMMITS}"
    echo "  Contributors: ${ACTIVE_CONTRIBUTORS}"
    echo "  PRs Merged: ${PR_MERGED}"
    echo "  Net Lines: ${NET_CHANGE:+}${NET_CHANGE}"
    echo ""
    echo "Next steps:"
    echo "  Copy to clipboard → cat \"${REPORT_FILE}\" | pbcopy"
    echo "  Open in editor    → open \"${REPORT_FILE}\""
    echo "  View in terminal  → cat \"${REPORT_FILE}\""
    echo ""
}

#========================================================================================================

main() {
    check_dependencies
    select_repository
    select_date_range
    
    print_header "Rhonda Report Generator"
    print_info "Repository: ${SELECTED_REPO}"
    print_info "Period: ${SINCE_DATE} to ${END_DATE}"
    echo ""
    echo "🎵 Help me, Rhonda... generating your report! 🎵"
    echo ""
    
    update_repository
    
    print_info "Analyzing commits..."
    analyze_commits
    
    print_info "Analyzing change types..."
    analyze_change_types
    
    print_info "Analyzing code changes..."
    analyze_code_changes
    
    print_info "Analyzing pull requests..."
    analyze_pull_requests
    
    print_info "Analyzing branches..."
    analyze_branches
    
    print_info "Generating report..."
    generate_report
    
    display_report_summary
}

main "$@"
