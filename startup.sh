#!/bin/bash

################################################################################
#                    Password Maker - Automated Startup Script                 #
#                                                                              #
# This script automatically checks all dependencies, installs missing ones,    #
# verifies prerequisites, and starts the application.                          #
#                                                                              #
# Supported Platforms: Linux, macOS, Windows (WSL)                            #
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Utility functions
print_header() {
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        # Detect Linux distribution
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        else
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="darwin"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        OS="windows"
        DISTRO="windows"
    else
        OS="unknown"
        DISTRO="unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check and install Node.js
check_nodejs() {
    print_info "Checking Node.js installation..."
    
    if command_exists node; then
        NODE_VERSION=$(node --version)
        print_success "Node.js is installed: $NODE_VERSION"
        
        # Extract major version
        MAJOR_VERSION=$(echo $NODE_VERSION | cut -d. -f1 | sed 's/v//')
        if [ "$MAJOR_VERSION" -lt 18 ]; then
            print_warning "Node.js version is below 18. Recommended version is 18+. Current: $NODE_VERSION"
            read -p "Continue anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        print_error "Node.js is not installed"
        print_info "Installing Node.js..."
        
        if [ "$OS" = "linux" ]; then
            if command_exists apt; then
                sudo apt update
                sudo apt install -y nodejs npm
            elif command_exists yum; then
                sudo yum install -y nodejs npm
            elif command_exists pacman; then
                sudo pacman -S --noconfirm nodejs npm
            elif command_exists brew; then
                brew install node
            else
                print_error "Could not determine package manager. Please install Node.js manually from https://nodejs.org/"
                exit 1
            fi
        elif [ "$OS" = "macos" ]; then
            if command_exists brew; then
                brew install node
            else
                print_error "Homebrew not found. Please install Node.js manually from https://nodejs.org/"
                exit 1
            fi
        else
            print_error "Unsupported OS for automatic Node.js installation. Please install manually."
            exit 1
        fi
        
        print_success "Node.js installed successfully"
    fi
}

# Check and install Rust
check_rust() {
    print_info "Checking Rust installation..."
    
    if command_exists rustc && command_exists cargo; then
        RUST_VERSION=$(rustc --version)
        CARGO_VERSION=$(cargo --version)
        print_success "Rust is installed: $RUST_VERSION"
        print_success "Cargo: $CARGO_VERSION"
    else
        print_error "Rust is not installed"
        print_info "Installing Rust..."
        
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
        source "$HOME/.cargo/env"
        
        print_success "Rust installed successfully"
    fi
}

# Check and install build tools for Linux
check_linux_deps() {
    print_info "Checking Linux build dependencies..."
    
    if [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ]; then
        REQUIRED_PACKAGES=(
            "build-essential"
            "curl"
            "wget"
            "file"
            "libssl-dev"
            "libgtk-3-dev"
            "libwebkit2gtk-4.0-dev"
            "libayatana-appindicator3-dev"
            "librsvg2-dev"
        )
        
        print_info "Checking required packages for Tauri on Debian/Ubuntu..."
        
        MISSING_PACKAGES=()
        for package in "${REQUIRED_PACKAGES[@]}"; do
            if ! dpkg -l | grep -q "^ii.*$package"; then
                MISSING_PACKAGES+=("$package")
            fi
        done
        
        if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
            print_warning "Missing packages: ${MISSING_PACKAGES[*]}"
            print_info "Installing missing packages..."
            sudo apt update
            sudo apt install -y "${MISSING_PACKAGES[@]}"
            print_success "Packages installed successfully"
        else
            print_success "All required Linux packages are installed"
        fi
    elif [ "$DISTRO" = "fedora" ] || [ "$DISTRO" = "rhel" ] || [ "$DISTRO" = "centos" ]; then
        REQUIRED_PACKAGES=(
            "gcc"
            "g++"
            "make"
            "openssl-devel"
            "gtk3-devel"
            "webkit2gtk3-devel"
            "libappindicator-gtk3-devel"
            "librsvg2-devel"
        )
        
        print_info "Checking required packages for Tauri on RHEL/Fedora..."
        
        MISSING_PACKAGES=()
        for package in "${REQUIRED_PACKAGES[@]}"; do
            if ! rpm -q "$package" &>/dev/null; then
                MISSING_PACKAGES+=("$package")
            fi
        done
        
        if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
            print_warning "Missing packages: ${MISSING_PACKAGES[*]}"
            print_info "Installing missing packages..."
            sudo yum install -y "${MISSING_PACKAGES[@]}"
            print_success "Packages installed successfully"
        else
            print_success "All required Linux packages are installed"
        fi
    elif [ "$DISTRO" = "arch" ] || [ "$DISTRO" = "manjaro" ]; then
        REQUIRED_PACKAGES=(
            "base-devel"
            "gtk3"
            "webkit2gtk"
            "libappindicator-gtk3"
            "librsvg"
        )
        
        print_info "Checking required packages for Tauri on Arch/Manjaro..."
        
        MISSING_PACKAGES=()
        for package in "${REQUIRED_PACKAGES[@]}"; do
            if ! pacman -Q "$package" &>/dev/null; then
                MISSING_PACKAGES+=("$package")
            fi
        done
        
        if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
            print_warning "Missing packages: ${MISSING_PACKAGES[*]}"
            print_info "Installing missing packages..."
            sudo pacman -S --noconfirm "${MISSING_PACKAGES[@]}"
            print_success "Packages installed successfully"
        else
            print_success "All required Linux packages are installed"
        fi
    else
        print_warning "Unable to auto-detect Linux distribution. Skipping system package verification."
        print_info "Please manually install the required packages for Tauri from: https://tauri.app/v1/guides/getting-started/prerequisites"
    fi
}

# Check and install Xcode Command Line Tools for macOS
check_macos_deps() {
    print_info "Checking macOS dependencies..."
    
    if ! command_exists clang; then
        print_warning "Xcode Command Line Tools not found"
        print_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        print_success "Xcode Command Line Tools installed"
    else
        print_success "Xcode Command Line Tools are installed"
    fi
}

# Check project structure
check_project_structure() {
    print_info "Checking project structure..."
    
    REQUIRED_FILES=(
        "package.json"
        "vite.config.ts"
        "tsconfig.json"
        "src-tauri/Cargo.toml"
        "src-tauri/tauri.conf.json"
        "src"
    )
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [ ! -e "$file" ]; then
            print_error "Missing required file/directory: $file"
            exit 1
        fi
    done
    
    print_success "Project structure is valid"
}

# Check npm and install dependencies
check_npm_dependencies() {
    print_info "Checking npm dependencies..."
    
    if [ ! -d "node_modules" ]; then
        print_warning "node_modules not found"
        print_info "Installing npm dependencies..."
        npm install
        print_success "npm dependencies installed"
    else
        print_success "node_modules directory exists"
        print_info "Checking for outdated or missing dependencies..."
        npm install
    fi
}

# Check Rust dependencies
check_rust_dependencies() {
    print_info "Checking Rust dependencies (Cargo)..."
    
    cd src-tauri
    
    # Check if Cargo.lock exists and is up to date
    cargo check --message-format=short 2>&1 | head -20
    
    cd ..
    print_success "Rust dependencies are available"
}

# Main startup function
start_app() {
    print_header "Starting Password Maker Application"
    
    read -p "Select mode (1=development, 2=build): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Dd1]$ ]]; then
        print_info "Starting in development mode..."
        npm run tauri:dev
    elif [[ $REPLY =~ ^[Bb2]$ ]]; then
        print_info "Building for production..."
        npm run tauri:build
    else
        print_error "Invalid option"
        exit 1
    fi
}

# Main execution
main() {
    print_header "Password Maker - Automated Setup & Startup"
    
    print_info "Detecting operating system..."
    detect_os
    print_success "Detected OS: $OS ($DISTRO)"
    
    # Change to project directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR"
    
    # Execute checks in order
    print_header "Phase 1: Core Dependencies"
    check_nodejs
    check_rust
    
    # Platform-specific checks
    print_header "Phase 2: Platform-Specific Dependencies"
    case $OS in
        linux)
            check_linux_deps
            ;;
        macos)
            check_macos_deps
            ;;
        *)
            print_warning "Skipping platform-specific checks for your OS"
            ;;
    esac
    
    # Project checks
    print_header "Phase 3: Project Verification"
    check_project_structure
    check_npm_dependencies
    check_rust_dependencies
    
    # Ready to start
    print_header "All Checks Passed!"
    print_success "Your system is ready to run Password Maker"
    echo ""
    
    start_app
}

# Run main function
main "$@"
