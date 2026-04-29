<#
Push local site to GitHub (automates init/add/commit/push).
Usage:
  .\push_to_github.ps1 [-GitHubUsername 'Simon-it-dell'] [-RepoName 'ITCompanyWebsite'] [-UserName 'Your Name'] [-UserEmail 'you@example.com']
Note: Requires Git installed and a remote GitHub repository created (https://github.com/new).
#>

param(
  [string]$GitHubUsername = "Simon-it-dell",
  [string]$RepoName = "ITCompanyWebsite",
  [string]$UserName = "",
  [string]$UserEmail = ""
)

function ExitWith($code,$msg) { Write-Host $msg; exit $code }

# Ensure git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  ExitWith 1 "Git not found. Install Git and re-run: https://git-scm.com/download/win"
}

# Move to script directory (project root)
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location $scriptDir

Write-Host "Working directory: $scriptDir"

# optional set git user
if ($UserName) {
  git config --global user.name $UserName
  Write-Host "Set git user.name = $UserName"
}
if ($UserEmail) {
  git config --global user.email $UserEmail
  Write-Host "Set git user.email = $UserEmail"
}

# init repo if needed
if (-not (Test-Path .git)) {
  git init
  Write-Host "Initialized empty Git repository."
} else {
  Write-Host "Repository already initialized."
}

# Stage files and commit if changes exist
git add .
$status = git status --porcelain
if ($status) {
  git commit -m "Initial Scar X site"
  Write-Host "Committed files."
} else {
  Write-Host "No changes to commit."
}

# Ensure main branch
git branch -M main

# Remote handling
$remoteUrl = "https://github.com/$GitHubUsername/$RepoName.git"
$existingRemote = $null
try {
  $existingRemote = git remote get-url origin 2>$null
} catch {}

if ($existingRemote) {
  Write-Host "Existing 'origin' remote: $existingRemote"
  $answer = Read-Host "Overwrite 'origin' with $remoteUrl? (y/n)"
  if ($answer -eq 'y' -or $answer -eq 'Y') {
    git remote remove origin
    git remote add origin $remoteUrl
    Write-Host "'origin' updated to $remoteUrl"
  } else {
    Write-Host "Keeping existing remote."
  }
} else {
  git remote add origin $remoteUrl
  Write-Host "Added remote origin -> $remoteUrl"
}

# Push
Write-Host "Pushing to origin main..."
try {
  git push -u origin main
  Write-Host "Push completed. If prompted for credentials, use your GitHub username and a Personal Access Token (PAT)."
} catch {
  Write-Error "Push failed. See error above. If authentication fails, create a PAT: https://github.com/settings/tokens"
  exit 1
}
