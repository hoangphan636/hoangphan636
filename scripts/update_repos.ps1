# Repository Metadata Synchronization Script for Windows PowerShell
# Usage: .\scripts\update_repos.ps1
param (
    [int]$LoopSeconds = 0
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace = Split-Path -Parent $scriptDir

function Sync-Repos {
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    try {
        $jsonStr = gh repo list hoangphan636 --limit 25 --json name,description,updatedAt,isPrivate,stargazerCount,primaryLanguage
        if ($LASTEXITCODE -eq 0 -and $jsonStr) {
            $repos = $jsonStr | ConvertFrom-Json
            $filtered = $repos | Where-Object { $_.name -ne "hoangphan636" }
            
            # Featured Repositories (Stars & High-Activity)
            $featured = $filtered | Sort-Object -Property @{Expression="stargazerCount"; Descending=$true}, @{Expression="updatedAt"; Descending=$true} | Select-Object -First 3
            
            # Recently Updated Repositories
            $recent = $filtered | Sort-Object -Property updatedAt -Descending | Select-Object -First 3

            Write-Host "[$now] Successfully verified repository metadata from GitHub API:" -ForegroundColor Cyan
            Write-Host "  -> Featured: $($featured.name -join ', ')" -ForegroundColor Green
            Write-Host "  -> Recent:   $($recent.name -join ', ')" -ForegroundColor Blue
        }
    } catch {
        Write-Warning "[$now] Error checking repositories: $_"
    }
}

do {
    Sync-Repos
    if ($LoopSeconds -gt 0) {
        Start-Sleep -Seconds $LoopSeconds
    }
} while ($LoopSeconds -gt 0)
