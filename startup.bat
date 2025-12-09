@echo off
REM ============================================================================
REM  Password Maker - Automated Startup Script (Windows)
REM  
REM  This script automatically checks all dependencies, installs missing ones,
REM  verifies prerequisites, and starts the application on Windows.
REM  
REM  Note: This script requires elevated privileges (Administrator) for
REM  package installation. You will be prompted for admin access if needed.
REM ============================================================================

setlocal enabledelayedexpansion
title Password Maker - Automated Setup

REM Colors (using findstr for coloring)
for /F %%a in ('copy /Z "%~f0" nul') do set "BS=%%a"

goto :main

REM ============================================================================
REM UTILITY FUNCTIONS
REM ============================================================================

:print_header
    echo.
    cls
    echo.
    echo ===============================================================
    echo  %~1
    echo ===============================================================
    echo.
    goto :eof

:print_success
    echo [SUCCESS] %~1
    goto :eof

:print_error
    color 0C
    echo [ERROR] %~1
    color 07
    goto :eof

:print_warning
    color 0E
    echo [WARNING] %~1
    color 07
    goto :eof

:print_info
    color 09
    echo [INFO] %~1
    color 07
    goto :eof

REM ============================================================================
REM DEPENDENCY CHECKS
REM ============================================================================

:check_nodejs
    call :print_info "Checking Node.js installation..."
    where node >nul 2>nul
    if !errorlevel! neq 0 (
        call :print_error "Node.js is not installed"
        call :print_info "Installing Node.js..."
        call :install_nodejs
    ) else (
        for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
        call :print_success "Node.js is installed: !NODE_VERSION!"
    )
    goto :eof

:install_nodejs
    call :print_info "Downloading Node.js installer..."
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi', '%TEMP%\node-installer.msi')"
    
    if !errorlevel! neq 0 (
        call :print_error "Failed to download Node.js"
        call :print_info "Please install Node.js manually from https://nodejs.org/"
        exit /b 1
    )
    
    call :print_info "Running Node.js installer..."
    start /wait msiexec /i "%TEMP%\node-installer.msi" /quiet
    
    if !errorlevel! neq 0 (
        call :print_error "Failed to install Node.js"
        exit /b 1
    )
    
    call :print_success "Node.js installed successfully"
    goto :eof

:check_rust
    call :print_info "Checking Rust installation..."
    where rustc >nul 2>nul
    if !errorlevel! neq 0 (
        call :print_error "Rust is not installed"
        call :print_info "Installing Rust..."
        call :install_rust
    ) else (
        for /f "tokens=*" %%i in ('rustc --version') do set RUST_VERSION=%%i
        call :print_success "Rust is installed: !RUST_VERSION!"
    )
    goto :eof

:install_rust
    call :print_info "Downloading Rust installer..."
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://win.rustup.rs/x86_64', '%TEMP%\rustup-init.exe')"
    
    if !errorlevel! neq 0 (
        call :print_error "Failed to download Rust"
        call :print_info "Please install Rust manually from https://rustup.rs/"
        exit /b 1
    )
    
    call :print_info "Running Rust installer..."
    "%TEMP%\rustup-init.exe" -y
    
    if !errorlevel! neq 0 (
        call :print_error "Failed to install Rust"
        exit /b 1
    )
    
    call :print_success "Rust installed successfully"
    goto :eof

:check_git
    call :print_info "Checking Git installation..."
    where git >nul 2>nul
    if !errorlevel! neq 0 (
        call :print_warning "Git is not installed (optional but recommended)"
    ) else (
        call :print_success "Git is installed"
    )
    goto :eof

:check_vs_build_tools
    call :print_info "Checking Microsoft Visual C++ Build Tools..."
    
    REM Check for Visual Studio
    if exist "C:\Program Files\Microsoft Visual Studio\2022" (
        call :print_success "Visual Studio 2022 found"
        goto :eof
    )
    if exist "C:\Program Files\Microsoft Visual Studio\2019" (
        call :print_success "Visual Studio 2019 found"
        goto :eof
    )
    
    REM Check for Build Tools
    if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022" (
        call :print_success "Visual Studio Build Tools found"
        goto :eof
    )
    
    call :print_error "Microsoft Visual C++ Build Tools not found"
    call :print_info "Installing Build Tools..."
    call :install_vs_build_tools
    goto :eof

:install_vs_build_tools
    call :print_info "Downloading Visual Studio Build Tools..."
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://aka.ms/vs/17/release/vs_BuildTools.exe', '%TEMP%\vs_BuildTools.exe')"
    
    if !errorlevel! neq 0 (
        call :print_error "Failed to download Build Tools"
        call :print_info "Please install manually from https://visualstudio.microsoft.com/downloads/"
        exit /b 1
    )
    
    call :print_info "Running Build Tools installer..."
    "%TEMP%\vs_BuildTools.exe" --quiet --wait
    
    if !errorlevel! neq 0 (
        call :print_error "Failed to install Build Tools"
        exit /b 1
    )
    
    call :print_success "Build Tools installed successfully"
    goto :eof

:check_project_structure
    call :print_info "Checking project structure..."
    
    if not exist "package.json" (
        call :print_error "Missing package.json"
        exit /b 1
    )
    if not exist "vite.config.ts" (
        call :print_error "Missing vite.config.ts"
        exit /b 1
    )
    if not exist "src-tauri\Cargo.toml" (
        call :print_error "Missing src-tauri\Cargo.toml"
        exit /b 1
    )
    if not exist "src" (
        call :print_error "Missing src directory"
        exit /b 1
    )
    
    call :print_success "Project structure is valid"
    goto :eof

:check_npm_dependencies
    call :print_info "Checking npm dependencies..."
    
    if not exist "node_modules" (
        call :print_warning "node_modules not found"
        call :print_info "Installing npm dependencies..."
        call npm install
        if !errorlevel! neq 0 (
            call :print_error "Failed to install npm dependencies"
            exit /b 1
        )
        call :print_success "npm dependencies installed"
    ) else (
        call :print_success "node_modules directory exists"
        call :print_info "Ensuring dependencies are up to date..."
        call npm install
    )
    goto :eof

:check_cargo_dependencies
    call :print_info "Checking Cargo dependencies..."
    cd src-tauri
    call cargo check --message-format=short
    cd ..
    call :print_success "Cargo dependencies verified"
    goto :eof

:start_app
    call :print_header "Starting Password Maker Application"
    echo.
    echo 1. Development Mode (npm run tauri:dev)
    echo 2. Production Build (npm run tauri:build)
    echo.
    set /p MODE="Select mode (1 or 2): "
    
    if "!MODE!"=="1" (
        call :print_info "Starting in development mode..."
        call npm run tauri:dev
    ) else if "!MODE!"=="2" (
        call :print_info "Building for production..."
        call npm run tauri:build
    ) else (
        call :print_error "Invalid option"
        exit /b 1
    )
    goto :eof

REM ============================================================================
REM MAIN EXECUTION
REM ============================================================================

:main
    call :print_header "Password Maker - Automated Setup & Startup (Windows)"
    
    call :print_info "Starting dependency checks..."
    echo.
    
    call :print_info "Phase 1: Core Dependencies"
    call :check_nodejs
    call :check_rust
    call :check_git
    
    call :print_info "Phase 2: Windows-Specific Dependencies"
    call :check_vs_build_tools
    
    call :print_info "Phase 3: Project Verification"
    call :check_project_structure
    call :check_npm_dependencies
    call :check_cargo_dependencies
    
    call :print_header "All Checks Passed!"
    call :print_success "Your system is ready to run Password Maker"
    echo.
    
    call :start_app
    
    exit /b 0
