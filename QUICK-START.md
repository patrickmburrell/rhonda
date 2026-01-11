# Rhonda - Quick Start

**"Help me, Rhonda!"** - Quick reference for your friendly repository report generator.

## One-Time Setup (5-10 minutes)

```bash
cd ~/rhonda
./setup.sh
```

Follow prompts to:
1. Install dependencies (gh, git, jq)
2. Authenticate with GitHub

---

## Add Your First Repository

```bash
cd ~/rhonda
./bin/rhonda-repos.sh
```

Choose option **2** → Paste GitHub URL → Wait for clone

---

## Generate Your First Report

```bash
cd ~/rhonda
./bin/rhonda-report.sh
```

1. Choose repository number
2. Choose time period (press Enter for 7 days)
3. Wait 5-10 seconds
4. Report is saved and path is displayed

---

## Copy Report to Clipboard

```bash
cat ~/rhonda/reports/FILENAME.md | pbcopy
```

Then paste into Slack, Teams, or email.

---

## Weekly Routine

Every Monday (or before client meetings):

```bash
cd ~/rhonda
./bin/rhonda-report.sh
```

That's it! Select repo → Select period → Copy → Paste

---

## Common Commands

### Generate Report
```bash
cd ~/rhonda && ./bin/rhonda-report.sh
```

### Manage Repositories
```bash
cd ~/rhonda && ./bin/rhonda-repos.sh
```

### View All Reports
```bash
ls -lh ~/rhonda/reports/
```

### Open Report in Editor
```bash
open ~/rhonda/reports/FILENAME.md
```

---

## Need More Help?

- **For usage**: Read `USER-GUIDE.md`
- **For technical details**: Read `README.md`
- **For installation**: Read `INSTALL.md`

---

## Troubleshooting

### "GitHub CLI is not authenticated"
```bash
gh auth login
```

### "No repositories found"
```bash
cd ~/rhonda
./bin/rhonda-repos.sh
# Choose option 2 to add repository
```

### Scripts won't run
```bash
chmod +x ~/rhonda/setup.sh
chmod +x ~/rhonda/bin/*.sh
```

---

## That's All You Need!

Rhonda is designed to be simple. Two commands to remember:
1. `./bin/rhonda-repos.sh` - manage repositories
2. `./bin/rhonda-report.sh` - generate reports

Everything else is explained in the prompts.
