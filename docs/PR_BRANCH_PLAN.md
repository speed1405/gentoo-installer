# Branch / PR Recovery Plan

## Current state

- `main` contains all installer commits.
- The branch history is not a clean linear sequence for PR creation.
- `gh pr create` fails because the source branch is not a real feature branch ahead of `main`.

## Decision needed

Pick one:

1. **No PR needed** — keep everything on `main`. Use tags or releases for milestones.
2. **Reviewer-facing PR** — create a clean feature branch from `main`, reset it to the base, replay installer changes, and PR back to `main`.
3. **Split repo state** — move installer scaffold to its own branch for work, leave `main` on the plan/docs baseline.

## Recommended path: option 2

### Step 1: identify base commit for the installer PR

Use: `feb8d0e Add dwm + polybar + wallpaper preset in 4.11`

This is the last commit before the big installer scaffold landed.

### Step 2: create clean feature branch

```bash
cd C:\Users\speed\gentoo-installer-work
git switch -c installer/feature feb8d0e
```

### Step 3: replay installer commits cleanly

Instead of `git cherry-pick`, recreate a single squash commit:

```bash
git reset --soft feb8d0e
git commit -m "Add guided Gentoo installer, desktop presets, usage and troubleshooting docs"
git push -u origin installer/feature
```

This compresses the messy phase commits into one reviewable commitstack.

### Step 4: create the PR

```bash
gh pr create \
  --base main \
  --head installer/feature \
  --title "Add guided Gentoo installer, desktop presets, usage and troubleshooting docs" \
  --body "Adds guided/auto/dry-run installer scaffold, preflight and disk safety, stage3/portage/kernel stages, dwm+polybar preset, usage guide, and troubleshooting docs."
```

## If squash replay is unacceptable

Use `git rebase -i feb8d0e` on `main` and create `installer/feature` from the rebuilt tip, then PR normally.
