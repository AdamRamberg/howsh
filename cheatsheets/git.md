# Git

## Setup

- `git init` - Initialize repository
- `git clone URL` - Clone repository
- `git config --global user.name "Name"` - Set name
- `git config --global user.email "email"` - Set email

## Basic Workflow

- `git status` - Check status
- `git add file.txt` - Stage file
- `git add .` - Stage all changes
- `git commit -m "message"` - Commit changes
- `git push` - Push to remote
- `git pull` - Pull from remote

## Branching

- `git branch` - List branches
- `git branch feature` - Create branch
- `git checkout feature` - Switch branch
- `git checkout -b feature` - Create and switch
- `git switch feature` - Switch (modern)
- `git switch -c feature` - Create and switch (modern)
- `git merge feature` - Merge branch
- `git branch -d feature` - Delete branch

## Viewing History

- `git log` - Commit history
- `git log --oneline` - Compact history
- `git log --graph` - Visual branch history
- `git log -p` - History with diffs
- `git show COMMIT` - Show commit details
- `git diff` - Unstaged changes
- `git diff --staged` - Staged changes

## Undoing Changes

- `git checkout -- file.txt` - Discard changes
- `git restore file.txt` - Discard changes (modern)
- `git reset HEAD file.txt` - Unstage file
- `git reset --soft HEAD~1` - Undo last commit, keep changes
- `git reset --hard HEAD~1` - Undo last commit, discard changes
- `git revert COMMIT` - Create undo commit

## Stashing

- `git stash` - Stash changes
- `git stash list` - List stashes
- `git stash pop` - Apply and remove stash
- `git stash apply` - Apply stash, keep it
- `git stash drop` - Delete stash

## Remote

- `git remote -v` - List remotes
- `git remote add origin URL` - Add remote
- `git fetch` - Fetch without merge
- `git pull --rebase` - Pull with rebase
- `git push -u origin main` - Push and track

## Collaboration

- `git blame file.txt` - Who changed each line
- `git cherry-pick COMMIT` - Apply specific commit
- `git rebase main` - Rebase onto main
- `git rebase -i HEAD~3` - Interactive rebase

## Tags

- `git tag v1.0.0` - Create tag
- `git tag -a v1.0.0 -m "msg"` - Annotated tag
- `git push --tags` - Push tags
- `git tag -d v1.0.0` - Delete tag
