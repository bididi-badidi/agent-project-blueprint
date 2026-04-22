# ==============================================================================
# Blueprint Installation Script (Windows PowerShell)
# ==============================================================================
# This script populates an existing project with the Gemini/Claude Agent
# Blueprint structure (.ai, .gemini, .claude, GEMINI.md, CLAUDE.md).
#
# Usage:
#   .\install.ps1                        # installs latest release
#   .\install.ps1 -Version v1.2.0        # installs a specific tagged version
#   .\install.ps1 -Version latest        # explicitly installs latest release
# ==============================================================================

param(
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"

# Configuration
$RepoOwner = "bididi-badidi"
$RepoName  = "agent-project-blueprint"
$RepoUrl   = "https://github.com/${RepoOwner}/${RepoName}"
$TempDir   = Join-Path $env:TEMP ([Guid]::NewGuid().ToString())
$TargetDir = Get-Location
$StampFile = Join-Path $TargetDir ".ai\assets\.blueprint-version"

# ------------------------------------------------------------------------------
# Version resolution
# ------------------------------------------------------------------------------
function Resolve-BlueprintVersion {
    param([string]$RequestedVersion)

    if ($RequestedVersion -eq "latest" -or [string]::IsNullOrEmpty($RequestedVersion)) {
        Write-Host "🔍 Fetching latest release..." -ForegroundColor Gray
        try {
            $ApiUrl   = "https://api.github.com/repos/${RepoOwner}/${RepoName}/releases/latest"
            $Response = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing -ErrorAction Stop
            return $Response.tag_name
        } catch {
            Write-Host "⚠️  No releases found, falling back to main branch." -ForegroundColor Yellow
            return "main"
        }
    }
    return $RequestedVersion
}

$ResolvedVersion = Resolve-BlueprintVersion -RequestedVersion $Version

if ($ResolvedVersion -eq "main") {
    $SourceUrl = "${RepoUrl}/archive/refs/heads/main.zip"
} else {
    $SourceUrl = "${RepoUrl}/archive/refs/tags/${ResolvedVersion}.zip"
}

# ------------------------------------------------------------------------------
# Detect existing installation
# ------------------------------------------------------------------------------
$InstalledVersion = $null
$IsUpgrade        = $false

if (Test-Path $StampFile) {
    $InstalledVersion = (Get-Content $StampFile -Raw).Trim()
}

if ($InstalledVersion) {
    if ($InstalledVersion -eq $ResolvedVersion) {
        Write-Host "✅ Blueprint ${ResolvedVersion} is already installed." -ForegroundColor Green
        $Choice = Read-Host "   Reinstall anyway? (y/N)"
        if ($Choice -notmatch "^[Yy]$") {
            Write-Host "Nothing to do."
            exit 0
        }
    } else {
        Write-Host "⬆️  Upgrading Blueprint: ${InstalledVersion} → ${ResolvedVersion}" -ForegroundColor Cyan
        $IsUpgrade = $true
    }
}

Write-Host "🚀 Starting Blueprint installation (${ResolvedVersion})..." -ForegroundColor Cyan

New-Item -ItemType Directory -Path $TempDir | Out-Null

try {
    # ----------------------------------------------------------------------------
    # Download ZIP
    # ----------------------------------------------------------------------------
    $ZipFile = Join-Path $TempDir "template.zip"
    Write-Host "📦 Downloading template from ${SourceUrl}..."
    try {
        Invoke-WebRequest -Uri $SourceUrl -OutFile $ZipFile -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "❌ Error: Failed to download the template." -ForegroundColor Red
        if ($ResolvedVersion -ne "main") {
            Write-Host "   Verify that tag '${ResolvedVersion}' exists at: ${RepoUrl}/releases"
        } else {
            Write-Host "   Verify the repository is public at: ${RepoUrl}"
        }
        exit 1
    }

    # ----------------------------------------------------------------------------
    # Extract
    # ----------------------------------------------------------------------------
    Write-Host "📂 Extracting files..."
    $ExtractDir = Join-Path $TempDir "extracted"
    Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir
    $RootFolder = Get-ChildItem -Path $ExtractDir | Select-Object -First 1

    # ----------------------------------------------------------------------------
    # Copy blueprint files
    # ----------------------------------------------------------------------------
    Write-Host "🏗️  Populating project structure..."
    $ItemsToCopy    = @(".ai", ".gemini", ".claude", "GEMINI.md", "CLAUDE.md")
    $UpstreamWritten = @()

    foreach ($Item in $ItemsToCopy) {
        $Src  = Join-Path $RootFolder.FullName $Item
        $Dest = Join-Path $TargetDir $Item

        if (-not (Test-Path $Src)) { continue }

        if (-not (Test-Path $Dest)) {
            # Item doesn't exist yet — copy directly
            Copy-Item -Path $Src -Destination $Dest -Recurse -Force
            Write-Host "✅ Created $Item" -ForegroundColor Green

        } elseif ($IsUpgrade) {
            # Upgrade: write alongside as .upstream so user can diff and merge
            $Upstream = "${Dest}.upstream"
            if (Test-Path $Upstream) {
                Remove-Item -Path $Upstream -Recurse -Force
            }
            Copy-Item -Path $Src -Destination $Upstream -Recurse -Force
            $UpstreamWritten += $Item
            Write-Host "📋 Staged $Item → ${Item}.upstream" -ForegroundColor Yellow

        } else {
            # Reinstall: ask before overwriting
            $Choice = Read-Host "⚠️  '$Item' already exists. Overwrite? (y/N)"
            if ($Choice -match "^[Yy]$") {
                if (Test-Path $Dest -PathType Container) {
                    Remove-Item -Path $Dest -Recurse -Force
                } else {
                    Remove-Item -Path $Dest -Force
                }
                Copy-Item -Path $Src -Destination $Dest -Recurse -Force
                Write-Host "✅ Overwrote $Item" -ForegroundColor Yellow
            } else {
                Write-Host "⏭️  Skipped $Item" -ForegroundColor Gray
            }
        }
    }

    # ----------------------------------------------------------------------------
    # Write version stamp
    # ----------------------------------------------------------------------------
    $StampDir = Split-Path $StampFile -Parent
    if (-not (Test-Path $StampDir)) {
        New-Item -ItemType Directory -Path $StampDir | Out-Null
    }
    Set-Content -Path $StampFile -Value $ResolvedVersion
    Write-Host "📌 Version stamp written: $ResolvedVersion"

    # ----------------------------------------------------------------------------
    # Finalizing
    # ----------------------------------------------------------------------------
    Write-Host "`n✨ Installation complete!" -ForegroundColor Cyan
    Write-Host "----------------------------------------------------------------"

    if ($UpstreamWritten.Count -gt 0) {
        Write-Host "Upgrade notes (${InstalledVersion} → ${ResolvedVersion}):" -ForegroundColor Yellow
        Write-Host "  Upstream files have been written alongside your existing files."
        Write-Host "  Review and merge changes, then delete the .upstream copies:"
        Write-Host ""
        foreach ($Item in $UpstreamWritten) {
            $Dest = Join-Path $TargetDir $Item
            if (Test-Path $Dest -PathType Container) {
                Write-Host "    Compare-Object (ls $Item) (ls ${Item}.upstream)"
            } else {
                Write-Host "    Compare-Object (gc $Item) (gc ${Item}.upstream)"
            }
        }
        Write-Host ""
        $CleanupList = ($UpstreamWritten | ForEach-Object { "${_}.upstream" }) -join ", "
        Write-Host "  When done: Remove-Item $CleanupList -Recurse -Force"
        Write-Host ""
    }

    Write-Host "Next steps:"
    Write-Host "1. Review 'GEMINI.md' and 'CLAUDE.md' for agent instructions."
    Write-Host "2. Check '.ai/assets/progress.md' to start tracking your project."
    Write-Host "3. Add '.ai/assets/branches/' and '.ai/assets/memory.jsonl' to your .gitignore."
    Write-Host "----------------------------------------------------------------"
    Write-Host "Happy coding! 🚀"
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
