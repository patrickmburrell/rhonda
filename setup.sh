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
            # Check if credential helper is already configured
            if ! git config --global --get credential.helper | grep -q "manager"; then
                git config --global credential.helper manager
                print_success "Git Credential Manager configured"
            else
                print_success "Git Credential Manager already configured"
            fi
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

setup_path() {
    print_header "Setting Up Rhonda Commands"
    
    local target_dir="/usr/local/bin"
    
    # Create symlinks for easy access
    if [[ -w "${target_dir}" ]] || sudo -n true 2>/dev/null; then
        echo "Creating command shortcuts..."
        echo ""
        
        # Remove old symlinks if they exist
        sudo rm -f "${target_dir}/rhonda-repos" 2>/dev/null
        sudo rm -f "${target_dir}/rhonda-report" 2>/dev/null
        
        # Create new symlinks
        sudo ln -sf "${BIN_DIR}/rhonda-repos.sh" "${target_dir}/rhonda-repos"
        sudo ln -sf "${BIN_DIR}/rhonda-report.sh" "${target_dir}/rhonda-report"
        
        print_success "Rhonda commands installed"
        echo ""
        echo "You can now run from anywhere:"
        echo "  rhonda-repos   - Manage repositories"
        echo "  rhonda-report  - Generate reports"
        echo ""
    else
        print_info "Could not install global commands (needs sudo)"
        echo "You can still run from the rhonda directory:"
        echo "  cd ~/rhonda"
        echo "  ./bin/rhonda-repos.sh"
        echo "  ./bin/rhonda-report.sh"
        echo ""
    fi
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
    
    echo "🎵 Rhonda is ready to help you generate repository reports! 🎵"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Manage repositories:"
    echo "   rhonda-repos"
    echo ""
    echo "2. Generate reports:"
    echo "   rhonda-report"
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
    setup_path
    check_gh_auth
    print_usage
}

main "$@"
