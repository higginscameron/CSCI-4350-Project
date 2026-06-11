# Contributing
 
Thank you for contributing to this project! Please read the following guidelines before submitting any changes.
 
---
 
## Branching Strategy
 
### Core Branches
 
We maintain two permanent branches:
 
| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code only. Never commit directly to this branch. |
| `develop` | Active development branch. All feature branches are created from here and merged back here. |
 
### Feature Branches
 
When working on a new feature or fix, create a branch off `develop` using the following naming convention:
 
```
feature/initials-description
```
 
**Examples:**
 
```
feature/jd-player-movement
feature/ab-main-menu-ui
feature/ks-enemy-ai
feature/jd-fix-collision-bug
```
 
**Rules:**
- Always branch off `develop`, never off `main`
- Use lowercase and hyphens, no spaces or special characters
- Keep the description short but meaningful
- One feature or fix per branch
### Branch Flow
 
```
main
 └── develop
      ├── feature/jd-player-movement
      ├── feature/ab-main-menu-ui
      └── feature/ks-enemy-ai
```
 
---
 
## Pull Request (PR) Process
 
### Opening a PR
 
1. Push your feature branch to the repository
2. Open a Pull Request targeting `develop` (or `main` if deploying)
3. Fill out the PR description — include what changed and how to test it
4. Request at least **one other team member** to review
### Review Requirements
 
- **Minimum 1 approval** is required before any PR can be merged
- **You cannot merge your own PR.** The person who pushed the code must wait for someone else to review and test the changes before it can be merged
- The reviewer is expected to pull the branch locally and test the changes, not just read the code
### Merging into Main
 
When merging `develop` into `main`:
 
1. Ensure all PRs into `develop` have been reviewed and approved
2. Open a PR from `develop` → `main` and get it approved
3. After merging, **the person who performed the merge must notify the team** that new code has been deployed to main (e.g., via your team's group chat or Discord)
> **Example notification:** "Hey team — just merged into main and deployed. Changes include [brief summary]. Let me know if you spot any issues!"
 
---
 
## Quick Reference
 
```
# 1. Make sure develop is up to date
git checkout develop
git pull origin develop
 
# 2. Create your feature branch
git checkout -b feature/initials-description
 
# 3. Do your work, then commit
git add .
git commit -m "Short description of change"
 
# 4. Push your branch
git push origin feature/initials-description
 
# 5. Open a PR on GitHub targeting develop
# 6. Wait for at least 1 approval before merging
```