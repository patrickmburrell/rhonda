#!/usr/bin/env bash
set -euo pipefail

#========================================================================================================
# Rhonda Repos - Repository Manager
# Interactive menu-driven tool for managing tracked GitHub repositories
#========================================================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOS_DIR="${SCRIPT_DIR}/repos"

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

list_repos() {
    print_header "Tracked Repositories"
    
    if [[ ! -d "${REPOS_DIR}" ]] || [[ -z "$(ls -A "${REPOS_DIR}" 2>/dev/null)" ]]; then
        echo "No repositories tracked yet."
        echo ""
        return
    fi
    
    echo "Local repositories in ${REPOS_DIR}:"
    echo ""
    
    for repo_path in "${REPOS_DIR}"/*; do
        if [[ -d "${repo_path}/.git" ]]; then
            local repo_name=$(basename "${repo_path}")
            local remote_url=$(cd "${repo_path}" && git remote get-url origin 2>/dev/null || echo "N/A")
            local last_fetch=$(cd "${repo_path}" && git log -1 FETCH_HEAD --format="%ar" 2>/dev/null || echo "never")
            local branch=$(cd "${repo_path}" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
            
            echo "  📁 ${repo_name}"
            echo "     URL: ${remote_url}"
            echo "     Branch: ${branch}"
            echo "     Last fetched: ${last_fetch}"
            echo ""
        fi
    done
}

#--------------------------------------------------------------------------------------------------------

add_repo() {
    print_header "Add New Repository"
    
    echo "Enter the GitHub repository URL (HTTPS or SSH):"
    echo "Examples:"
    echo "  https://github.com/owner/repo.git"
    echo "  git@github.com:owner/repo.git"
    echo ""
    read -p "URL: " repo_url
    
    if [[ -z "${repo_url}" ]]; then
        print_error "No URL provided"
        return 1
    fi
    
    local repo_name
    repo_name=$(basename "${repo_url}" .git)
    local target_path="${REPOS_DIR}/${repo_name}"
    
    if [[ -d "${target_path}" ]]; then
        print_error "Repository '${repo_name}' already exists at ${target_path}"
        return 1
    fi
    
    echo ""
    echo "Cloning ${repo_name}..."
    
    if git clone "${repo_url}" "${target_path}"; then
        print_success "Repository cloned to ${target_path}"
        
        cd "${target_path}"
        git fetch --all
        print_success "Fetched all branches"
    else
        print_error "Failed to clone repository"
        return 1
    fi
}

#--------------------------------------------------------------------------------------------------------

remove_repo() {
    print_header "Remove Repository"
    
    if [[ ! -d "${REPOS_DIR}" ]] || [[ -z "$(ls -A "${REPOS_DIR}" 2>/dev/null)" ]]; then
        echo "No repositories to remove."
        echo ""
        return
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
        echo "No valid repositories found."
        echo ""
        return
    fi
    
    echo ""
    read -p "Enter number to remove (or 'c' to cancel): " choice
    
    if [[ "${choice}" == "c" ]] || [[ "${choice}" == "C" ]]; then
        print_info "Cancelled"
        return
    fi
    
    if [[ ! "${choice}" =~ ^[0-9]+$ ]] || [[ ${choice} -lt 1 ]] || [[ ${choice} -gt ${#repos[@]} ]]; then
        print_error "Invalid choice"
        return 1
    fi
    
    local selected_repo="${repos[$((choice-1))]}"
    local repo_path="${REPOS_DIR}/${selected_repo}"
    
    echo ""
    echo "⚠️  This will permanently delete: ${repo_path}"
    read -p "Are you sure? (type 'yes' to confirm): " confirm
    
    if [[ "${confirm}" != "yes" ]]; then
        print_info "Cancelled"
        return
    fi
    
    rm -rf "${repo_path}"
    print_success "Removed ${selected_repo}"
}

#--------------------------------------------------------------------------------------------------------

update_repos() {
    print_header "Update All Repositories"
    
    if [[ ! -d "${REPOS_DIR}" ]] || [[ -z "$(ls -A "${REPOS_DIR}" 2>/dev/null)" ]]; then
        echo "No repositories to update."
        echo ""
        return
    fi
    
    local updated=0
    local failed=0
    
    for repo_path in "${REPOS_DIR}"/*; do
        if [[ -d "${repo_path}/.git" ]]; then
            local repo_name=$(basename "${repo_path}")
            echo "Updating ${repo_name}..."
            
            if (cd "${repo_path}" && git fetch --all --prune); then
                print_success "${repo_name} updated"
                ((updated++))
            else
                print_error "Failed to update ${repo_name}"
                ((failed++))
            fi
        fi
    done
    
    echo ""
    echo "Summary: ${updated} updated, ${failed} failed"
    echo ""
}

#--------------------------------------------------------------------------------------------------------

show_menu() {
    print_header "Rhonda Repos - Repository Manager"
    
    echo "1) List tracked repositories"
    echo "2) Add new repository"
    echo "3) Remove repository"
    echo "4) Update all repositories (fetch)"
    echo "5) Exit"
    echo ""
    read -p "Choose an option: " choice
    
    case ${choice} in
        1)
            list_repos
            ;;
        2)
            add_repo
            ;;
        3)
            remove_repo
            ;;
        4)
            update_repos
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
}

#========================================================================================================

main() {
    check_dependencies
    
    while true; do
        show_menu
        echo ""
        read -p "Press Enter to continue..."
    done
}

main "$@"
