# Rhonda - Installation Instructions

**"Help me, Rhonda!"** - Installation guide for your friendly repository report generator.

## For You (The Installer)

### Step 1: Copy Files to Your Wife's MacBook

1. Copy the entire `rhonda` directory to her home directory:
   ```bash
   # On your machine, create an archive
   cd ~/Projects/pmb
   tar -czf rhonda.tar.gz rhonda/
   
   # Transfer rhonda.tar.gz to her MacBook (via AirDrop, USB, etc.)
   ```

2. On her MacBook, extract to home directory:
   ```bash
   cd ~
   tar -xzf ~/Downloads/rhonda.tar.gz
   ```

### Step 2: Verify File Permissions

Make sure the scripts are executable:
```bash
chmod +x ~/rhonda/setup.sh
chmod +x ~/rhonda/bin/*.sh
```

### Step 3: Run Initial Setup Together

Open Terminal on her MacBook and run:
```bash
cd ~/rhonda
./setup.sh
```

This will:
- Check for Homebrew (should already be installed)
- Install gh, git, and jq
- Create necessary directories
- Walk through GitHub authentication

### Step 4: Add First Repository

Help her add her first project repository:
```bash
cd ~/rhonda
./bin/rhonda-repos.sh
```

Choose option 2, then paste in a GitHub repository URL she manages.

### Step 5: Generate First Report

Generate a test report to verify everything works:
```bash
cd ~/rhonda
./bin/rhonda-report.sh
```

Select the repository and generate a 7-day report.

### Step 6: Show Her the User Guide

Point her to the comprehensive guide:
```bash
open ~/rhonda/USER-GUIDE.md
```

Or tell her: "Open the USER-GUIDE.md file in your rhonda folder"

---

## For Your Wife (The User)

After installation, you'll use two main commands:

### Managing Your Repositories
```bash
cd ~/rhonda
./bin/rhonda-repos.sh
```

### Generating Reports (Weekly)
```bash
cd ~/rhonda
./bin/rhonda-report.sh
```

**Everything else you need to know is in USER-GUIDE.md** - bookmark it or keep it open in a tab!

---

## Troubleshooting Installation

### If Homebrew is Not Installed

Install Homebrew first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then run setup.sh again.

### If GitHub Authentication Fails

Try manually:
```bash
gh auth login
```

Follow the browser prompts.

### If Scripts Don't Run

Make them executable:
```bash
chmod +x ~/rhonda/setup.sh
chmod +x ~/rhonda/bin/*.sh
```

---

## What Gets Installed

- **gh** (GitHub CLI) - for GitHub authentication and API access
- **git** - for reading repository data (likely already installed)
- **jq** - for parsing JSON data

All installed via Homebrew, easy to remove if needed:
```bash
brew uninstall gh jq
```

---

## Complete Removal

If you ever need to completely remove Rhonda:
```bash
rm -rf ~/rhonda
brew uninstall gh jq
gh auth logout
```
