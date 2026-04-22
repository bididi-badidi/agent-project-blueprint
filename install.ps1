$ErrorActionPreference = "Stop"

# Configuration
$RepoUrl = "https://github.com/bididi-badidi/agent-project-blueprint"
$SourceUrl = "$RepoUrl/archive/refs/heads/main.zip"
$TempDir = Join-Path $env:TEMP ([Guid]::NewGuid().ToString())
$TargetDir = Get-Location

# Create Temp Directory
New-Item -ItemType Directory -Path $TempDir | Out-Null

try {
    Write-Host "🚀 Starting Blueprint installation..." -ForegroundColor Cyan

    # 1. Download ZIP
    $ZipFile = Join-Path $TempDir "template.zip"
    Write-Host "📦 Downloading template from $RepoUrl..."
    Invoke-WebRequest -Uri $SourceUrl -OutFile $ZipFile -UseBasicParsing

    # 2. Extract
    Write-Host "📂 Extracting files..."
    $ExtractDir = Join-Path $TempDir "extracted"
    Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir

    # GitHub ZIPs wrap everything in a folder named 'repo-name-branch'
    $RootFolder = Get-ChildItem -Path $ExtractDir | Select-Object -First 1
    
    # 3. Copy Blueprint Files
    Write-Host "🏗️  Populating project structure..."
    $ItemsToCopy = @(".ai", ".gemini", ".claude", "GEMINI.md", "CLAUDE.md")

    foreach ($item in $ItemsToCopy) {
        $Src = Join-Path $RootFolder.FullName $item
        $Dest = Join-Path $TargetDir $item

        if (Test-Path $Src) {
            if (Test-Path $Dest) {
                $Choice = Read-Host "⚠️  '$item' already exists. Overwrite? (y/N)"
                if ($Choice -eq "y" -or $Choice -eq "Y") {
                    if (Test-Path $Dest -PathType Container) {
                        Remove-Item -Path $Dest -Recurse -Force
                    } else {
                        Remove-Item -Path $Dest -Force
                    }
                    Copy-Item -Path $Src -Destination $Dest -Recurse -Force
                    Write-Host "✅ Overwrote $item" -ForegroundColor Yellow
                } else {
                    Write-Host "⏭️  Skipped $item" -ForegroundColor Gray
                }
            } else {
                Copy-Item -Path $Src -Destination $Dest -Recurse -Force
                Write-Host "✅ Created $item" -ForegroundColor Green
            }
        }
    }

    # 4. Finalizing
    Write-Host "`n✨ Installation complete!" -ForegroundColor Cyan
    Write-Host "----------------------------------------------------------------"
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
    # Cleanup
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
