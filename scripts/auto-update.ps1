# auto-update.ps1
# AI-Company Skill Auto-Update Script
# Bundled with skill at: {SKILL_DIR}/scripts/auto-update.ps1
#
# Update Modes (configurable via update-config.json or -Mode parameter):
#   auto          - Auto download and install updates
#   auto-download - Auto download, notify user, but do NOT install
#   notify        - Notify user when update available, do NOT download
#   none          - No auto-update (default) — only check when run manually with -Force
#
# Usage:
#   pwsh -File auto-update.ps1                    # Run with configured mode (default: none)
#   pwsh -File auto-update.ps1 -Mode auto         # Override: auto update this run
#   pwsh -File auto-update.ps1 -Mode notify       # Override: notify only this run
#   pwsh -File auto-update.ps1 -Force             # Force update regardless of mode
#   pwsh -File auto-update.ps1 -SetMode auto      # Persist mode to config file
#   pwsh -File auto-update.ps1 -ShowConfig        # Display current config
#
# Cross-platform path example:
#   Windows : pwsh -File "$env:USERPROFILE\.agents\skills\ai-company\scripts\auto-update.ps1"
#   macOS   : pwsh -File "$HOME/.agents/skills/ai-company/scripts/auto-update.ps1"

param(
    [ValidateSet("auto","auto-download","notify","none")]
    [string]$Mode,           # Override update mode for this run
    [switch]$Force,          # Force update even if same version
    [switch]$SkipBackup,     # Skip backup (for testing only)
    [ValidateSet("auto","auto-download","notify","none")]
    [string]$SetMode,        # Persist update mode to config and exit
    [switch]$ShowConfig      # Display current config and exit
)

$ErrorActionPreference = "Stop"
$SKILL_SLUG = "ai-company-unified"

# Resolve skill dir relative to this script's location
$SCRIPT_DIR  = Split-Path -Parent $MyInvocation.MyCommand.Path
$SKILL_DIR   = Split-Path -Parent $SCRIPT_DIR   # parent of scripts/

$BACKUP_DIR  = "$env:USERPROFILE\.agents\skills\backups"
$LOG_DIR     = "$SKILL_DIR\.logs"
$LOG_FILE    = "$LOG_DIR\auto-update-log.md"
$SKILL_MD    = "$SKILL_DIR\SKILL.md"
$CONFIG_FILE = "$SCRIPT_DIR\update-config.json"
$DOWNLOAD_DIR = "$SKILL_DIR\.downloads"

# Default config values
$DEFAULT_MODE = "none"
$DEFAULT_SCHEDULE = "FREQ=WEEKLY;BYDAY=SU;BYHOUR=2;BYMINUTE=0"
$DEFAULT_BACKUP_RETENTION = 1

# =============================================================================
# Config Management
# =============================================================================

function Get-DefaultConfig {
    return @{
        mode              = $DEFAULT_MODE
        schedule          = $DEFAULT_SCHEDULE
        backupRetention   = $DEFAULT_BACKUP_RETENTION
        lastCheck         = $null
        lastUpdate        = $null
        lastNotified      = $null
        notificationFile  = "$SKILL_DIR\.update-notification.md"
    }
}

function Read-Config {
    if (Test-Path $CONFIG_FILE) {
        try {
            $raw = Get-Content $CONFIG_FILE -Raw | ConvertFrom-Json
            $config = Get-DefaultConfig
            # Merge saved values over defaults
            if ($null -ne $raw.mode)             { $config.mode             = $raw.mode }
            if ($null -ne $raw.schedule)          { $config.schedule         = $raw.schedule }
            if ($null -ne $raw.backupRetention)   { $config.backupRetention  = [int]$raw.backupRetention }
            if ($null -ne $raw.lastCheck)         { $config.lastCheck        = $raw.lastCheck }
            if ($null -ne $raw.lastUpdate)        { $config.lastUpdate       = $raw.lastUpdate }
            if ($null -ne $raw.lastNotified)      { $config.lastNotified     = $raw.lastNotified }
            if ($null -ne $raw.notificationFile)  { $config.notificationFile = $raw.notificationFile }
            return $config
        } catch {
            Write-Host "[WARN] Config file corrupt, using defaults: $_" -ForegroundColor Yellow
        }
    }
    return Get-DefaultConfig
}

function Write-Config {
    param([hashtable]$Config)
    $Config | ConvertTo-Json -Depth 3 | Set-Content $CONFIG_FILE -Encoding UTF8
}

function Resolve-EffectiveMode {
    param([hashtable]$Config)
    # CLI -Mode overrides config
    if ($Mode) { return $Mode }
    return $Config.mode
}

# =============================================================================
# Helper Functions
# =============================================================================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
    $entry = "## $timestamp - $Level`n- $Message`n"
    Add-Content -Path $LOG_FILE -Value $entry
    Write-Host "[$Level] $Message"
}

function Parse-SemVer {
    param([string]$Version)
    $m = [regex]::Match($Version, '^(\d+)\.(\d+)\.(\d+)(?:-(.+))?$')
    if (-not $m.Success) {
        throw "Invalid semver: $Version"
    }
    return @{
        Major      = [int]$m.Groups[1].Value
        Minor      = [int]$m.Groups[2].Value
        Patch      = [int]$m.Groups[3].Value
        PreRelease = $m.Groups[4].Value
    }
}

function Compare-SemVer {
    param([string]$V1, [string]$V2)
    $p1 = Parse-SemVer $V1
    $p2 = Parse-SemVer $V2

    if ($p2.Major -gt $p1.Major) { return 1 }
    if ($p2.Major -lt $p1.Major) { return -1 }
    if ($p2.Minor -gt $p1.Minor) { return 1 }
    if ($p2.Minor -lt $p1.Minor) { return -1 }
    if ($p2.Patch -gt $p1.Patch) { return 1 }
    if ($p2.Patch -lt $p1.Patch) { return -1 }
    return 0
}

function Get-LocalVersion {
    $content = Get-Content $SKILL_MD -Raw
    $m = [regex]::Match($content, '^version:\s*"?([\d.]+)"?$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($m.Success) { return $m.Groups[1].Value }
    throw "Cannot parse local version from SKILL.md"
}

function Get-RemoteVersion {
    $result = clawhub search $SKILL_SLUG 2>&1
    if ($LASTEXITCODE -ne 0) { throw "clawhub search failed: $result" }
    $m = [regex]::Match($result, 'v?(\d+\.\d+\.\d+)')
    if ($m.Success) { return $m.Groups[1].Value }
    throw "Cannot parse remote version from clawhub output"
}

function Test-SecurityGates {
    param([string]$SkillDir)

    $errors = @()

    # Gate 1: SKILL.md exists and readable
    $mdFile = "$SkillDir\SKILL.md"
    if (-not (Test-Path $mdFile)) {
        $errors += "SKILL.md not found"
        return $errors
    }

    $content = Get-Content $mdFile -Raw

    # Gate 2: Publisher check
    if ($content -notmatch 'author:\s*"AI Company Team"') {
        $errors += "Publisher mismatch: expected 'AI Company Team'"
    }

    # Gate 3: License check (GPL-3.0)
    if ($content -notmatch 'license:\s*"GPL-3\.0"') {
        $errors += "License mismatch: expected 'GPL-3.0'"
    }

    # Gate 4: Slug check
    if ($content -notmatch 'slug:\s*"ai-company-unified"') {
        $errors += "Slug mismatch: expected 'ai-company-unified'"
    }

    # Gate 5: No dangerous patterns
    $dangerPatterns = @(
        'eval\s*\(',
        'exec\s*\(',
        'subprocess.*shell\s*=\s*True',
        '__import__\s*\('
    )
    foreach ($pattern in $dangerPatterns) {
        if ($content -match $pattern) {
            $errors += "Dangerous pattern detected: $pattern"
        }
    }

    # Gate 6: File count check (>= 18 .md files)
    $mdFiles = Get-ChildItem -Path $SkillDir -Filter "*.md" -Recurse
    if ($mdFiles.Count -lt 18) {
        $errors += "File count too low: $($mdFiles.Count) (expected >= 18)"
    }

    return $errors
}

function Invoke-Rollback {
    param([string]$BackupPath)

    Write-Log "Initiating rollback from: $BackupPath" "WARN"

    if (-not (Test-Path $BackupPath)) {
        Write-Log "Backup path not found: $BackupPath" "ERROR"
        throw "Rollback failed: backup not found"
    }

    # Remove current skill
    if (Test-Path $SKILL_DIR) {
        Remove-Item -Path $SKILL_DIR -Recurse -Force
    }

    # Restore from backup
    Copy-Item -Path "$BackupPath\*" -Destination "$SKILL_DIR" -Recurse -Force

    Write-Log "Rollback completed successfully" "INFO"
}

# =============================================================================
# Notification System
# =============================================================================

function Write-Notification {
    param(
        [string]$LocalVersion,
        [string]$RemoteVersion,
        [string]$Mode,
        [string]$Status,          # "available", "downloaded", "installed"
        [string]$DownloadPath = $null,
        [string[]]$Errors = @()
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"

    $statusEmoji = switch ($Status) {
        "available" { "🔔" }
        "downloaded" { "📦" }
        "installed" { "✅" }
        default { "ℹ️" }
    }

    $actionRequired = switch ($Mode) {
        "notify"       { "An update is available. Run with -Mode auto or -Mode auto-download to proceed." }
        "auto-download" { "Update downloaded. Run with -Mode auto to install, or manually install from: $DownloadPath" }
        "auto"         { "Update installed automatically." }
        "none"         { "No automatic action taken. Run with -Force or -Mode auto to update." }
        default        { "No action taken." }
    }

    $notification = @"
# $statusEmoji AI-Company Skill Update Notification

- **Timestamp**: $timestamp
- **Local Version**: $localVersion
- **Remote Version**: $remoteVersion
- **Update Mode**: $Mode
- **Status**: $Status

## Action Required

$actionRequired

"@

    if ($Errors.Count -gt 0) {
        $notification += "`n## Errors`n`n"
        foreach ($err in $Errors) {
            $notification += "- $err`n"
        }
    }

    $notificationFile = $config.notificationFile
    Set-Content -Path $notificationFile -Value $notification -Encoding UTF8
    Write-Log "Notification written to: $notificationFile" "INFO"

    # Also output to console for visibility
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " $statusEmoji AI-Company Update Available" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Local : $LocalVersion" -ForegroundColor White
    Write-Host "  Remote: $RemoteVersion" -ForegroundColor Yellow
    Write-Host "  Mode  : $Mode" -ForegroundColor White
    Write-Host "  Status: $Status" -ForegroundColor White
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host "  $actionRequired" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Clear-Notification {
    $notificationFile = $config.notificationFile
    if (Test-Path $notificationFile) {
        Remove-Item $notificationFile -Force
        Write-Log "Cleared previous notification" "INFO"
    }
}

# =============================================================================
# Mode Handlers
# =============================================================================

function Invoke-AutoUpdate {
    param(
        [string]$LocalVersion,
        [string]$RemoteVersion,
        [hashtable]$Config
    )

    Write-Log "Mode: AUTO — downloading and installing update" "INFO"

    # Step 1: Create backup
    $backupTimestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $currentBackupPath = "$BACKUP_DIR\$SKILL_SLUG-$backupTimestamp"

    if (-not $SkipBackup) {
        Write-Log "Creating backup at: $currentBackupPath ..."
        New-Item -ItemType Directory -Path $currentBackupPath -Force | Out-Null
        Copy-Item -Path "$SKILL_DIR\*" -Destination $currentBackupPath -Recurse -Force
        Write-Log "Backup created successfully" "INFO"
    }

    # Step 2: Download and install
    Write-Log "Downloading and installing new version from ClawHub..."
    $installResult = clawhub install $SKILL_SLUG --force 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "clawhub install failed: $installResult"
    }
    Write-Log "Download and install completed" "INFO"

    # Step 3: Verify integrity (security gates)
    Write-Log "Running security gates..."
    $gateErrors = Test-SecurityGates $SKILL_DIR

    if ($gateErrors.Count -gt 0) {
        Write-Log "Security gates FAILED:" "ERROR"
        foreach ($err in $gateErrors) {
            Write-Log "  - $err" "ERROR"
        }
        if (-not $SkipBackup) {
            Invoke-Rollback -BackupPath $currentBackupPath
        }
        throw "Update blocked by security gates"
    }

    Write-Log "All security gates PASSED" "INFO"

    # Step 4: Verify new version matches remote
    $newVersion = Get-LocalVersion
    if ($newVersion -ne $RemoteVersion) {
        Write-Log "Version mismatch after install: expected $RemoteVersion, got $newVersion" "ERROR"
        if (-not $SkipBackup) {
            Invoke-Rollback -BackupPath $currentBackupPath
        }
        throw "Version verification failed"
    }

    # Step 5: Cleanup old backups
    Cleanup-OldBackups -Config $Config

    # Step 6: Update config
    $Config.lastUpdate = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    Write-Config $Config

    # Step 7: Notify
    Write-Notification -LocalVersion $LocalVersion -RemoteVersion $RemoteVersion -Mode "auto" -Status "installed"

    return $newVersion
}

function Invoke-AutoDownload {
    param(
        [string]$LocalVersion,
        [string]$RemoteVersion,
        [hashtable]$Config
    )

    Write-Log "Mode: AUTO-DOWNLOAD — downloading update (not installing)" "INFO"

    # Step 1: Create download directory
    if (-not (Test-Path $DOWNLOAD_DIR)) {
        New-Item -ItemType Directory -Path $DOWNLOAD_DIR -Force | Out-Null
    }

    # Step 2: Download to staging area using clawhub
    Write-Log "Downloading new version to staging area..."
    $downloadTimestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $stagingPath = "$DOWNLOAD_DIR\$SKILL_SLUG-$downloadTimestamp"
    New-Item -ItemType Directory -Path $stagingPath -Force | Out-Null

    # Use clawhub download (not install) to get files without replacing current
    $downloadResult = clawhub download $SKILL_SLUG --output $stagingPath 2>&1
    if ($LASTEXITCODE -ne 0) {
        # Fallback: if 'download' not supported, use 'install' with --dry-run or manual approach
        Write-Log "clawhub download not available, trying alternative approach..." "WARN"
        # Download to a temp location by cloning the skill temporarily
        $tempInstallPath = "$env:TEMP\clawhub-$SKILL_SLUG-$downloadTimestamp"
        $installResult = clawhub install $SKILL_SLUG --output $tempInstallPath 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Download failed: $installResult"
        }
        # Move downloaded files to staging
        if (Test-Path $tempInstallPath) {
            Copy-Item -Path "$tempInstallPath\*" -Destination $stagingPath -Recurse -Force
            Remove-Item $tempInstallPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Log "Download completed to: $stagingPath" "INFO"

    # Step 3: Verify security gates on downloaded content
    Write-Log "Running security gates on downloaded content..."
    $gateErrors = Test-SecurityGates $stagingPath
    if ($gateErrors.Count -gt 0) {
        Write-Log "Security gates FAILED on downloaded content:" "ERROR"
        foreach ($err in $gateErrors) {
            Write-Log "  - $err" "ERROR"
        }
        Remove-Item $stagingPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Notification -LocalVersion $LocalVersion -RemoteVersion $RemoteVersion -Mode "auto-download" -Status "available" -Errors $gateErrors
        throw "Download blocked by security gates"
    }

    Write-Log "Security gates PASSED for downloaded content" "INFO"

    # Step 4: Update config
    $Config.lastCheck = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    Write-Config $Config

    # Step 5: Notify user
    Write-Notification -LocalVersion $LocalVersion -RemoteVersion $RemoteVersion -Mode "auto-download" -Status "downloaded" -DownloadPath $stagingPath

    return $stagingPath
}

function Invoke-NotifyOnly {
    param(
        [string]$LocalVersion,
        [string]$RemoteVersion,
        [hashtable]$Config
    )

    Write-Log "Mode: NOTIFY — update available, notifying user" "INFO"

    # Update config
    $Config.lastCheck = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    $Config.lastNotified = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    Write-Config $Config

    # Notify user
    Write-Notification -LocalVersion $LocalVersion -RemoteVersion $RemoteVersion -Mode "notify" -Status "available"
}

function Invoke-NoAutoUpdate {
    param(
        [string]$LocalVersion,
        [string]$RemoteVersion,
        [hashtable]$Config
    )

    Write-Log "Mode: NONE — no auto-update configured" "INFO"
    Write-Log "Update available: $LocalVersion -> $RemoteVersion" "INFO"
    Write-Log "To update, run with -Mode auto or -Force" "INFO"

    # Update lastCheck timestamp only
    $Config.lastCheck = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    Write-Config $Config
}

# =============================================================================
# Backup Cleanup
# =============================================================================

function Cleanup-OldBackups {
    param([hashtable]$Config)

    $retention = $Config.backupRetention
    if ($retention -lt 1) { return }

    if (-not (Test-Path $BACKUP_DIR)) { return }

    $backups = Get-ChildItem -Path $BACKUP_DIR -Directory |
        Where-Object { $_.Name -like "$SKILL_SLUG-*" } |
        Sort-Object Name -Descending

    if ($backups.Count -gt $retention) {
        $toRemove = $backups | Select-Object -Skip $retention
        foreach ($old in $toRemove) {
            Write-Log "Removing old backup: $($old.FullName)" "INFO"
            Remove-Item $old.FullName -Recurse -Force
        }
    }
}

# =============================================================================
# Show Config
# =============================================================================

function Show-CurrentConfig {
    $config = Read-Config

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  AI-Company Update Configuration" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Mode             : $($config.mode)" -ForegroundColor White
    Write-Host "  Schedule         : $($config.schedule)" -ForegroundColor White
    Write-Host "  Backup Retention : $($config.backupRetention) versions" -ForegroundColor White
    Write-Host "  Last Check       : $($config.lastCheck ?? 'Never')" -ForegroundColor White
    Write-Host "  Last Update      : $($config.lastUpdate ?? 'Never')" -ForegroundColor White
    Write-Host "  Last Notified    : $($config.lastNotified ?? 'Never')" -ForegroundColor White
    Write-Host "  Notification File: $($config.notificationFile)" -ForegroundColor White
    Write-Host "  Config File      : $CONFIG_FILE" -ForegroundColor Gray
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # Show pending notification if any
    if (Test-Path $config.notificationFile) {
        Write-Host "  Pending Notification:" -ForegroundColor Yellow
        Get-Content $config.notificationFile | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
        Write-Host ""
    }

    # Show downloaded updates
    if (Test-Path $DOWNLOAD_DIR) {
        $downloads = Get-ChildItem -Path $DOWNLOAD_DIR -Directory | Where-Object { $_.Name -like "$SKILL_SLUG-*" }
        if ($downloads.Count -gt 0) {
            Write-Host "  Downloaded Updates (ready to install):" -ForegroundColor Green
            foreach ($dl in $downloads) {
                Write-Host "    - $($dl.FullName)" -ForegroundColor Green
            }
            Write-Host ""
        }
    }
}

# =============================================================================
# Main Execution
# =============================================================================

# Ensure log directory exists
if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null
}

# Handle -SetMode: persist mode to config and exit
if ($SetMode) {
    $config = Read-Config
    $oldMode = $config.mode
    $config.mode = $SetMode
    Write-Config $config
    Write-Host "Update mode changed: $oldMode -> $SetMode" -ForegroundColor Green
    Write-Host "Config saved to: $CONFIG_FILE" -ForegroundColor Gray
    exit 0
}

# Handle -ShowConfig: display config and exit
if ($ShowConfig) {
    Show-CurrentConfig
    exit 0
}

# Load config
$config = Read-Config
$effectiveMode = Resolve-EffectiveMode $config

Write-Log "=== AI-Company Auto-Update Started ===" "INFO"
Write-Log "Skill dir : $SKILL_DIR" "INFO"
Write-Log "Backup dir: $BACKUP_DIR" "INFO"
Write-Log "Effective mode: $effectiveMode" "INFO"
$startTime = Get-Date

# Clear previous notification
Clear-Notification

try {
    # Step 1: Read local version
    Write-Log "Reading local version..."
    $localVersion = Get-LocalVersion
    Write-Log "Local version: $localVersion" "INFO"

    # Step 2: Query remote version
    Write-Log "Querying remote version from ClawHub..."
    $remoteVersion = Get-RemoteVersion
    Write-Log "Remote version: $remoteVersion" "INFO"

    # Step 3: Compare versions
    $comparison = Compare-SemVer $localVersion $remoteVersion

    if ($comparison -eq 0 -and -not $Force) {
        Write-Log "Already up-to-date: $localVersion" "INFO"

        # Update lastCheck even when up-to-date
        $config.lastCheck = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        Write-Config $config

        # Duration log
        $duration = (Get-Date) - $startTime
        Write-Log "Check completed in $($duration.TotalSeconds) seconds — no update needed" "INFO"
        exit 0
    }
    elseif ($comparison -gt 0) {
        Write-Log "Local ($localVersion) > remote ($remoteVersion) — unexpected, check ClawHub" "WARN"
        if (-not $Force) {
            exit 0
        }
    }

    if ($comparison -lt 0 -or $Force) {
        if ($comparison -lt 0) {
            Write-Log "Update available: $localVersion -> $remoteVersion" "INFO"
        }
        if ($Force -and $comparison -eq 0) {
            Write-Log "Force flag set — reinstalling same version $localVersion" "WARN"
        }
    }

    # Step 4: Dispatch by mode
    switch ($effectiveMode) {
        "auto" {
            $newVersion = Invoke-AutoUpdate -LocalVersion $localVersion -RemoteVersion $remoteVersion -Config $config
            $finalVersion = $newVersion
        }
        "auto-download" {
            $downloadPath = Invoke-AutoDownload -LocalVersion $localVersion -RemoteVersion $remoteVersion -Config $config
            $finalVersion = $remoteVersion
        }
        "notify" {
            Invoke-NotifyOnly -LocalVersion $localVersion -RemoteVersion $remoteVersion -Config $config
            $finalVersion = $remoteVersion
        }
        "none" {
            Invoke-NoAutoUpdate -LocalVersion $localVersion -RemoteVersion $remoteVersion -Config $config
            $finalVersion = $remoteVersion
        }
    }

    # Final log
    $duration = (Get-Date) - $startTime
    $logEntry = @"
### Update Check Completed
- **Time**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
- **Local**: $localVersion
- **Remote**: $remoteVersion
- **Mode**: $effectiveMode
- **Duration**: $($duration.TotalSeconds) seconds

"@
    Add-Content -Path $LOG_FILE -Value $logEntry

    Write-Log "=== Update Check Completed ===" "INFO"
    exit 0

} catch {
    $duration = (Get-Date) - $startTime
    Write-Log "=== Update FAILED ===" "ERROR"
    Write-Log "Error: $_" "ERROR"

    $logEntry = @"
### Update Failed
- **Time**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
- **Local**: $localVersion
- **Remote**: $remoteVersion
- **Mode**: $effectiveMode
- **Error**: $_
- **Duration**: $($duration.TotalSeconds) seconds

"@
    Add-Content -Path $LOG_FILE -Value $logEntry

    # Write error notification
    Write-Notification -LocalVersion $localVersion -RemoteVersion $remoteVersion -Mode $effectiveMode -Status "available" -Errors @("$($_.Exception.Message)")

    exit 1
}
