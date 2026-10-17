# Realtime Repository Scheduler Script for Windows PowerShell
# Usage: .\scripts\update_repos.ps1 -LoopSeconds 2
param (
    [int]$LoopSeconds = 0
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace = Split-Path -Parent $scriptDir

function Sync-Repos {
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    try {
        $jsonStr = gh repo list hoangphan636 --limit 25 --json name,description,updatedAt,isPrivate,stargazerCount
        if ($LASTEXITCODE -eq 0 -and $jsonStr) {
            $repos = $jsonStr | ConvertFrom-Json
            $filtered = $repos | Where-Object { $_.name -ne "hoangphan636" }
            
            # Top 3 Most Accessed (by stars & activity)
            $accessed = $filtered | Sort-Object -Property @{Expression="stargazerCount"; Descending=$true}, @{Expression="updatedAt"; Descending=$true} | Select-Object -First 3
            
            # Top 3 Newest
            $newest = $filtered | Sort-Object -Property updatedAt -Descending | Select-Object -First 3

            Write-Host "[$now] [Scheduler $($LoopSeconds)s] Successfully synced repositories:" -ForegroundColor Cyan
            Write-Host "  -> Top Accessed: $(($accessed | ForEach-Object { $_.name }) -join ', ')" -ForegroundColor Green
            Write-Host "  -> Top Newest:   $(($newest | ForEach-Object { $_.name }) -join ', ')" -ForegroundColor Yellow
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
