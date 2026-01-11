# Rhonda - User Guide

**"Help me, Rhonda!"** - Your friendly repository report generator.

Welcome! Rhonda helps you generate weekly activity reports for your GitHub projects. This guide will walk you through everything you need to know.

## What Rhonda Does

Rhonda creates easy-to-read summaries of what's happening in your GitHub repositories:
- Who's been making changes and how much
- What pull requests have been merged or opened
- How many lines of code were added or removed
- Which features, bugs, or other work was completed
- Which branches are active vs. stale

The reports are in Markdown format, which means you can easily copy and paste them into Slack, Teams, or client status reports.

---

## Initial Setup (One Time Only)

### Step 1: Open Terminal

Find and open the **Terminal** app on your Mac (it's in Applications > Utilities).

### Step 2: Navigate to the Tool

Type this command and press Enter:

```bash
cd ~/rhonda
```

### Step 3: Run Setup

Type this command and press Enter:

```bash
./setup.sh
```

The setup script will:
1. Check if you have Homebrew installed (you should)
2. Ask if you want to install the required tools (say yes)
3. Create the necessary folders
4. Help you authenticate with GitHub

### Step 4: GitHub Authentication

When prompted, authenticate with GitHub:
- The tool will open your web browser
- Log in to GitHub if you're not already
- Authorize the GitHub CLI tool
- Follow the prompts back in Terminal

**That's it!** Setup is complete. You only need to do this once.

---

## Daily Usage

### Adding Your First Repository

Before you can generate reports, you need to add at least one repository to track.

1. Open Terminal and navigate to Rhonda:
   ```bash
   cd ~/rhonda
   ```

2. Run the repository manager:
   ```bash
   ./bin/rhonda-repos.sh
   ```

3. Choose option **2** (Add new repository)

4. Enter the GitHub URL for your project. You can find this on the GitHub website:
   - Go to your repository on GitHub
   - Click the green "Code" button
   - Copy the HTTPS URL (it looks like: `https://github.com/company/project.git`)
   - Paste it into Terminal

5. Press Enter and wait while the repository is downloaded

6. Choose option **5** to exit when done

**Repeat this process** for each project you want to track (usually 2-4 projects).

---

### Generating a Weekly Report

This is what you'll do most often - probably every Monday morning or before client meetings.

1. Open Terminal and navigate to Rhonda:
   ```bash
   cd ~/rhonda
   ```

2. Run the report generator:
   ```bash
   ./bin/rhonda-report.sh
   ```

3. **Select repository**: Type the number for the project you want to report on

4. **Select time period**: 
   - Press 1 for last 7 days (default)
   - Press 2 for last 14 days
   - Press 3 for last 30 days
   - Press 4 to enter a custom start date

5. Wait while the report is generated (usually 5-10 seconds)

6. The tool will tell you where the report was saved

---

### Using Your Report

Once the report is generated, you have several options:

#### Option 1: Copy to Clipboard (Easiest)
```bash
cat "path/to/report.md" | pbcopy
```
(The tool will show you the exact command to use)

Then paste into Slack, Teams, or email.

#### Option 2: Open in an Editor
```bash
open "path/to/report.md"
```

This opens the report in your default text editor (probably TextEdit). From there you can:
- Read through it
- Copy sections you need
- Save it elsewhere

#### Option 3: View in Terminal
```bash
cat "path/to/report.md"
```

This displays the report right in Terminal.

---

## Understanding Your Reports

Each report contains several sections:

### Summary
Quick overview with the most important numbers:
- Total commits (changes) made
- Number of people who contributed
- Pull request activity
- Net lines changed (code growth or reduction)

### Commit Activity
Shows **who** did the work and **when** it happened:
- Breakdown by team member
- Daily activity pattern (which days were busiest)

### Pull Request Status
Shows the status of code reviews:
- What was merged (completed)
- What's still pending review
- What was closed without merging

### Types of Changes
Categorizes the work into:
- Features (new functionality)
- Bug fixes
- Refactoring (code improvements)
- Documentation
- Other

*Note: This works best if your developers use conventional commit messages like "feat:" or "fix:"*

### Code Changes
Raw numbers about code modifications:
- Files changed
- Lines added
- Lines removed
- Net change (growth or shrinkage)

### Branch Activity
Shows which branches are being worked on vs. which are stale (inactive).

### Key Highlights
Auto-generated bullet points calling out the most notable items, perfect for quick verbal updates.

---

## Tips for Better Reports

### For Your Team
Ask your developers to:
- Use clear commit messages
- Follow conventional commit format when possible (feat:, fix:, etc.)
- Open pull requests for code reviews
- Close stale branches when done

### For You
- Generate reports on the same day each week (e.g., every Monday)
- Keep old reports for comparison (they're stored in the `reports/` folder)
- Update repositories before generating reports (the tool does this automatically)

---

## Common Tasks

### Viewing All Tracked Repositories

```bash
cd ~/rhonda
./bin/rhonda-repos.sh
```

Choose option **1** to see all repositories and their status.

### Removing a Repository

If you no longer need to track a project:

```bash
cd ~/rhonda
./bin/rhonda-repos.sh
```

Choose option **3** and select the repository to remove.

### Updating Repositories

Before generating reports, it's good to make sure you have the latest data:

```bash
cd ~/rhonda
./bin/rhonda-repos.sh
```

Choose option **4** to update all repositories. (The report generator also does this automatically.)

---

## Troubleshooting

### "GitHub CLI is not authenticated"

Run this command:
```bash
gh auth login
```

Follow the prompts to authenticate with GitHub.

### "No repositories found"

You need to add repositories first. See the "Adding Your First Repository" section above.

### "Permission denied"

The scripts might not be executable. Run:
```bash
chmod +x ~/rhonda/setup.sh
chmod +x ~/rhonda/bin/*.sh
```

### "Command not found: gh" or "Command not found: jq"

The dependencies aren't installed. Run the setup script again:
```bash
cd ~/rhonda
./setup.sh
```

### Repository Won't Clone

- Make sure you have access to the repository on GitHub
- Try authenticating again: `gh auth login`
- Verify the URL is correct (copy it from GitHub)

### Report Looks Wrong or Empty

- The repository might not have activity in the selected time period
- Try a longer time period (14 or 30 days)
- Make sure the repository was updated recently (option 4 in repo-manager)

---

## Getting Help

### For Technical Issues
Contact the person who set this tool up for you. Show them:
- The exact command you ran
- The error message (if any)
- This user guide

### For Report Interpretation
If you're not sure what something in the report means:
- Compare it to previous reports from the same project
- Ask your developers about specific items (they'll see familiar commit messages)
- Focus on the Summary and Key Highlights sections first

---

## Quick Reference

### Generate a report (most common):
```bash
cd ~/rhonda
./bin/rhonda-report.sh
```

### Manage repositories:
```bash
cd ~/rhonda
./bin/rhonda-repos.sh
```

### Copy report to clipboard:
```bash
cat ~/rhonda/reports/FILENAME.md | pbcopy
```

### View all reports:
```bash
ls -lh ~/rhonda/reports/
```

---

## What's Next?

Once you're comfortable with the basics:
- Try generating reports for different time periods to see trends
- Compare reports week-over-week to spot changes in velocity
- Share key highlights in standup meetings or client calls
- Use the "Types of Changes" section to discuss priorities with your team

Happy reporting! 📊
