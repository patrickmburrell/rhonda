#!/usr/bin/env bash
set -euo pipefail

#========================================================================================================
# Rhonda - Setup Script
# "Help me, Rhonda!" - Your friendly repository report generator
# One-time setup for installing dependencies and configuring the tool
#========================================================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="${SCRIPT_DIR}/repos"
REPORTS_DIR="${SCRIPT_DIR}/reports"
CONFIG_DIR="${SCRIPT_DIR}/config"
BIN_DIR="${SCRIPT_DIR}/bin"

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

check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed"
        echo "Please install Homebrew first: https://brew.sh"
        exit 1
    fi
    print_success "Homebrew is installed"
}

#--------------------------------------------------------------------------------------------------------

install_dependencies() {
    print_header "Installing Dependencies"
    
    if [[ ! -f "${SCRIPT_DIR}/Brewfile" ]]; then
        print_error "Brewfile not found at ${SCRIPT_DIR}/Brewfile"
        exit 1
    fi
    
    echo "This will install: gh, git, jq, and git-credential-manager via Homebrew"
    echo ""
    read -p "Continue with installation? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "${SCRIPT_DIR}"
        brew bundle
        print_success "Dependencies installed"
        
        # Configure Git Credential Manager
        if command -v git-credential-manager &> /dev/null; then
            git config --global credential.helper manager
            print_success "Git Credential Manager configured"
        fi
    else
        print_info "Skipping dependency installation"
    fi
}

#--------------------------------------------------------------------------------------------------------

create_directories() {
    print_header "Creating Directories"
    
    mkdir -p "${REPOS_DIR}" "${REPORTS_DIR}" "${CONFIG_DIR}" "${BIN_DIR}"
    
    print_success "Created ${REPOS_DIR}"
    print_success "Created ${REPORTS_DIR}"
    print_success "Created ${CONFIG_DIR}"
    print_success "Created ${BIN_DIR}"
}

#--------------------------------------------------------------------------------------------------------

check_gh_auth() {
    print_header "Checking GitHub Authentication"
    
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed"
        echo "Run this script again to install dependencies"
        exit 1
    fi
    
    if gh auth status &> /dev/null; then
        print_success "GitHub CLI is authenticated"
        gh auth status
    else
        print_info "GitHub CLI is not authenticated"
        echo ""
        echo "You need to authenticate with GitHub to use this tool."
        echo "This will open a browser for authentication."
        echo ""
        read -p "Authenticate now? (y/n) " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh auth login
            print_success "GitHub authentication complete"
        else
            print_info "Skipping authentication (you can run 'gh auth login' later)"
        fi
    fi
}

#--------------------------------------------------------------------------------------------------------

print_usage() {
    print_header "Setup Complete!"
    
    echo "Rhonda is ready to help you generate repository reports!"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Manage repositories:"
    echo "   ${BIN_DIR}/rhonda-repos.sh"
    echo ""
    echo "2. Generate reports:"
    echo "   ${BIN_DIR}/rhonda-report.sh"
    echo ""
    echo "For detailed instructions, see:"
    echo "   ${SCRIPT_DIR}/USER-GUIDE.md"
    echo ""
    
    if ! gh auth status &> /dev/null; then
        echo "⚠️  Remember to authenticate with GitHub:"
        echo "   gh auth login"
        echo ""
    fi
}

#========================================================================================================

main() {
    print_header "Rhonda Setup"
    
    check_homebrew
    install_dependencies
    create_directories
    check_gh_auth
    print_usage
}

main "$@"
