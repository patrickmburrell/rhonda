# Rhonda - Deployment Guide

## Step 1: Push to GitHub

### Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `rhonda`
3. Description: "Help me, Rhonda! Your friendly repository report generator for tracking GitHub project activity."
4. Choose: **Private** (recommended) or Public
5. Do NOT initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

### Push Local Repository

GitHub will show you commands. Use these:

```bash
cd ~/Projects/pmb/rhonda
git remote add origin git@github.com:YOUR_USERNAME/rhonda.git
git branch -M main
git push -u origin main
```

**Or if using HTTPS:**

```bash
cd ~/Projects/pmb/rhonda
git remote add origin https://github.com/YOUR_USERNAME/rhonda.git
git branch -M main
git push -u origin main
```

---

## Step 2: Deploy to Your Wife's MacBook

### Option A: Clone from GitHub (Recommended)

On her MacBook:

```bash
cd ~
git clone git@github.com:YOUR_USERNAME/rhonda.git
# Or: git clone https://github.com/YOUR_USERNAME/rhonda.git

cd rhonda
./setup.sh
```

**Advantages:**
- Clean installation
- Easy to update later with `git pull`
- No need to transfer files manually

### Option B: Manual Transfer (Alternative)

If she doesn't have git configured or you prefer manual transfer:

1. **On your machine:**
   ```bash
   cd ~/Projects/pmb
   tar -czf rhonda.tar.gz rhonda/
   # Transfer rhonda.tar.gz via AirDrop/USB
   ```

2. **On her MacBook:**
   ```bash
   cd ~
   tar -xzf ~/Downloads/rhonda.tar.gz
   cd rhonda
   ./setup.sh
   ```

---

## Step 3: Initial Setup (Her MacBook)

Run the setup script:

```bash
cd ~/rhonda
./setup.sh
```

This will:
1. Install dependencies (gh, git, jq)
2. Authenticate with GitHub
3. Create necessary directories
4. Show usage instructions

---

## Step 4: Add First Repository

```bash
cd ~/rhonda
./bin/rhonda-repos.sh
```

Choose option 2, paste a GitHub repository URL

---

## Step 5: Generate First Report

```bash
cd ~/rhonda
./bin/rhonda-report.sh
```

Select repository, time period, and generate!

---

## Future Updates

### For You (Maintainer)

When you make changes:

```bash
cd ~/Projects/pmb/rhonda
git add -A
git commit -m "description of changes

Co-Authored-By: Warp <agent@warp.dev>"
git push
```

### For Her (User)

To get updates:

```bash
cd ~/rhonda
git pull
```

**Note:** If she's cloned from GitHub. If manually transferred, you'll need to send her new tar.gz files.

---

## Repository Settings

### Recommended GitHub Settings

- **Private**: Yes (contains scripts she'll use)
- **Issues**: Disabled (internal tool)
- **Wiki**: Disabled (we have docs)
- **Projects**: Disabled
- **Discussions**: Disabled

### Access

If you want to give her direct access to the repository:
1. Go to repository Settings → Collaborators
2. Add her GitHub username
3. She can then `git pull` for updates

---

## Troubleshooting Deployment

### "Permission denied (publickey)"

You have several options:

**Option 1: Use HTTPS with Git Credential Manager (Easiest)**

Clone using HTTPS instead:
```bash
git clone https://github.com/YOUR_USERNAME/rhonda.git
```

Git Credential Manager (GCM) will handle authentication via browser.

To install GCM on her MacBook:
```bash
brew install git-credential-manager
git config --global credential.helper manager
```

**Option 2: Set up SSH keys**

```bash
ssh-keygen -t ed25519 -C "her-email@example.com"
cat ~/.ssh/id_ed25519.pub
# Add this key to GitHub: Settings → SSH and GPG keys
```

Then clone with SSH:
```bash
git clone git@github.com:YOUR_USERNAME/rhonda.git
```

### "gh: command not found" after setup

```bash
cd ~/rhonda
brew bundle
```

### Files Not Executable

```bash
chmod +x ~/rhonda/setup.sh
chmod +x ~/rhonda/bin/*.sh
```

---

## Quick Reference

### Clone and Install (Her MacBook)
```bash
cd ~
git clone https://github.com/YOUR_USERNAME/rhonda.git
cd rhonda
./setup.sh
```

### Daily Usage
```bash
cd ~/rhonda
./bin/rhonda-report.sh  # Generate report
./bin/rhonda-repos.sh   # Manage repos
```

### Get Updates
```bash
cd ~/rhonda
git pull
```

---

## Security Notes

- The repository will NOT contain any:
  - Cloned repositories (in .gitignore)
  - Generated reports (in .gitignore)
  - GitHub credentials (handled by gh CLI)
  - Configuration files (in .gitignore)

- Safe to make public, but recommend private for cleaner access control

---

## Success!

Once deployed, your wife will have Rhonda running on her MacBook and can:
- Generate weekly reports in under 1 minute
- Track 2-4 repositories
- Copy/paste reports to Slack/Teams
- Update with `git pull` when you make improvements

🎵 Help me, Rhonda! 🎵
