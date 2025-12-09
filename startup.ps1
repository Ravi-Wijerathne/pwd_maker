#Requires -Version 5.0
<#
.SYNOPSIS
    Password Maker - Automated Startup Script (PowerShell)
    
.DESCRIPTION
    This script automatically checks all dependencies, installs missing ones,
    verifies prerequisites, and starts the application on Windows.
    
.NOTES
    Requires: PowerShell 5.0+
    Admin privileges needed for package installation
    
.EXAMPLE
    .\startup.ps1
#>

param(
    [ValidateSet('dev', 'build')]
    [string]$Mode = 'interactive'
)

# Enable error handling
$ErrorActionPreference = "Stop"

# Color definitions
$Colors = @{
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Cyan"
    Header = "Blue"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "═════════════════════════════════════════════════════════" -ForegroundColor $Colors.Header
    Write-Host "  $Message" -ForegroundColor $Colors.Header
    Write-Host "═════════════════════════════════════════════════════════" -ForegroundColor $Colors.Header
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $Colors.Success
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $Colors.Error
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $Colors.Warning
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor $Colors.Info
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

function Check-NodeJS {
    Write-Info "Checking Node.js installation..."
    
    if (Test-CommandExists node) {
        $version = node --version
        Write-Success "Node.js is installed: $version"
        
        $major = [int]$version.Split('.')[0].TrimStart('v')
        if ($major -lt 18) {
            Write-Warning-Custom "Node.js version is below 18. Recommended version is 18+. Current: $version"
            $response = Read-Host "Continue anyway? (y/n)"
            if ($response -ne 'y' -and $response -ne 'Y') {
                exit 1
            }
        }
    }
    else {
        Write-Error-Custom "Node.js is not installed"
        Write-Info "Installing Node.js..."
        Install-NodeJS
    }
}

function Install-NodeJS {
    Write-Info "Downloading Node.js installer..."
    
    try {
        $downloadUrl = "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi"
        $installerPath = "$env:TEMP\node-installer.msi"
        
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $installerPath)
        
        Write-Info "Running Node.js installer..."
        $process = Start-Process -FilePath msiexec -ArgumentList "/i `"$installerPath`" /quiet" -Wait -PassThru
        
        if ($process.ExitCode -ne 0) {
            Write-Error-Custom "Failed to install Node.js"
            exit 1
        }
        
        Write-Success "Node.js installed successfully"
    }
    catch {
        Write-Error-Custom "Failed to download/install Node.js: $_"
        Write-Info "Please install Node.js manually from https://nodejs.org/"
        exit 1
    }
}

function Check-Rust {
    Write-Info "Checking Rust installation..."
    
    if (Test-CommandExists rustc) {
        $version = rustc --version
        Write-Success "Rust is installed: $version"
    }
    else {
        Write-Error-Custom "Rust is not installed"
        Write-Info "Installing Rust..."
        Install-Rust
    }
}

function Install-Rust {
    Write-Info "Downloading Rust installer..."
    
    try {
        $downloadUrl = "https://win.rustup.rs/x86_64"
        $installerPath = "$env:TEMP\rustup-init.exe"
        
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $installerPath)
        
        Write-Info "Running Rust installer..."
        $process = Start-Process -FilePath $installerPath -ArgumentList "-y" -Wait -PassThru
        
        if ($process.ExitCode -ne 0) {
            Write-Error-Custom "Failed to install Rust"
            exit 1
        }
        
        Write-Success "Rust installed successfully"
    }
    catch {
        Write-Error-Custom "Failed to download/install Rust: $_"
        Write-Info "Please install Rust manually from https://rustup.rs/"
        exit 1
    }
}

function Check-Git {
    Write-Info "Checking Git installation..."
    
    if (Test-CommandExists git) {
        Write-Success "Git is installed"
    }
    else {
        Write-Warning-Custom "Git is not installed (optional but recommended)"
    }
}

function Check-VSBuildTools {
    Write-Info "Checking Microsoft Visual C++ Build Tools..."
    
    $vs2022Path = "C:\Program Files\Microsoft Visual Studio\2022"
    $vs2019Path = "C:\Program Files\Microsoft Visual Studio\2019"
    $buildToolsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022"
    
    if ((Test-Path $vs2022Path) -or (Test-Path $vs2019Path) -or (Test-Path $buildToolsPath)) {
        Write-Success "Visual Studio/Build Tools found"
        return
    }
    
    Write-Error-Custom "Microsoft Visual C++ Build Tools not found"
    Write-Info "Installing Build Tools..."
    Install-VSBuildTools
}

function Install-VSBuildTools {
    Write-Info "Downloading Visual Studio Build Tools..."
    
    try {
        $downloadUrl = "https://aka.ms/vs/17/release/vs_BuildTools.exe"
        $installerPath = "$env:TEMP\vs_BuildTools.exe"
        
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $installerPath)
        
        Write-Info "Running Build Tools installer..."
        $process = Start-Process -FilePath $installerPath -ArgumentList "--quiet --wait" -Wait -PassThru
        
        if ($process.ExitCode -ne 0) {
            Write-Warning-Custom "Build Tools installation may require manual configuration"
        }
        
        Write-Success "Build Tools installed"
    }
    catch {
        Write-Error-Custom "Failed to install Build Tools: $_"
        Write-Info "Please install manually from https://visualstudio.microsoft.com/downloads/"
        exit 1
    }
}

function Check-ProjectStructure {
    Write-Info "Checking project structure..."
    
    $requiredFiles = @(
        "package.json",
        "vite.config.ts",
        "tsconfig.json",
        "src-tauri\Cargo.toml",
        "src-tauri\tauri.conf.json",
        "src"
    )
    
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            Write-Error-Custom "Missing required file/directory: $file"
            exit 1
        }
    }
    
    Write-Success "Project structure is valid"
}

function Check-NPMDependencies {
    Write-Info "Checking npm dependencies..."
    
    if (-not (Test-Path "node_modules")) {
        Write-Warning-Custom "node_modules not found"
        Write-Info "Installing npm dependencies..."
        
        try {
            & npm install
            if ($LASTEXITCODE -ne 0) {
                Write-Error-Custom "Failed to install npm dependencies"
                exit 1
            }
            Write-Success "npm dependencies installed"
        }
        catch {
            Write-Error-Custom "npm install failed: $_"
            exit 1
        }
    }
    else {
        Write-Success "node_modules directory exists"
        Write-Info "Checking for updates..."
        & npm install
    }
}

function Check-CargoDependencies {
    Write-Info "Checking Cargo dependencies..."
    
    try {
        Push-Location "src-tauri"
        & cargo check --message-format=short
        Pop-Location
        Write-Success "Cargo dependencies verified"
    }
    catch {
        Write-Error-Custom "Cargo check failed: $_"
        exit 1
    }
}

function Start-Application {
    Write-Header "Starting Password Maker Application"
    
    Write-Host "1. Development Mode (npm run tauri:dev)" -ForegroundColor White
    Write-Host "2. Production Build (npm run tauri:build)" -ForegroundColor White
    Write-Host ""
    
    if ($Mode -eq 'interactive') {
        $selection = Read-Host "Select mode (1 or 2)"
    }
    else {
        $selection = if ($Mode -eq 'dev') { '1' } else { '2' }
    }
    
    switch ($selection) {
        '1' {
            Write-Info "Starting in development mode..."
            & npm run tauri:dev
        }
        '2' {
            Write-Info "Building for production..."
            & npm run tauri:build
        }
        default {
            Write-Error-Custom "Invalid option"
            exit 1
        }
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Main {
    try {
        Write-Header "Password Maker - Automated Setup & Startup (Windows)"
        
        Write-Info "Starting system checks..."
        Write-Host ""
        
        Write-Header "Phase 1: Core Dependencies"
        Check-NodeJS
        Check-Rust
        Check-Git
        
        Write-Header "Phase 2: Windows-Specific Dependencies"
        Check-VSBuildTools
        
        Write-Header "Phase 3: Project Verification"
        Check-ProjectStructure
        Check-NPMDependencies
        Check-CargoDependencies
        
        Write-Header "All Checks Passed!"
        Write-Success "Your system is ready to run Password Maker"
        Write-Host ""
        
        Start-Application
    }
    catch {
        Write-Error-Custom "An error occurred: $_"
        exit 1
    }
}

# Run main function
Main
