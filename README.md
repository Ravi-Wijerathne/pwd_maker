# Password Maker

A secure, cross-platform password generator built with **React**, **Tauri**, and **Rust**.

## Features

- Cryptographically secure generation using Rust's `OsRng`
- Real-time password strength analysis (zxcvbn)
- AES-256-GCM encryption with Argon2 key derivation
- Clipboard auto-clears after 30 seconds
- Dark/light theme support
- Cross-platform (Windows, macOS, Linux)

## Prerequisites

- [Node.js](https://nodejs.org/) v18+
- [Rust](https://rustup.rs/)
- Platform-specific dependencies:

| Platform | Requirements |
|----------|-------------|
| **Windows** | VS C++ Build Tools, WebView2 |
| **macOS** | Xcode Command Line Tools (`xcode-select --install`) |
| **Linux** | `libwebkit2gtk-4.0-dev build-essential libssl-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev` |

See [Tauri Prerequisites](https://tauri.app/v1/guides/getting-started/prerequisites) for full details.

## Setup

### Quick Start (Recommended)

Use the included startup scripts — they check dependencies, install missing components, and launch the app:

```bash
# Linux / macOS
chmod +x startup.sh && ./startup.sh

# Windows (PowerShell)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\startup.ps1

# Windows (Command Prompt)
startup.bat
```

When prompted, choose **Option 1** (dev mode) or **Option 2** (production build).

### Manual Setup

```bash
# 1. Install dependencies
npm install

# 2. Run in development mode
npm run tauri:dev

# 3. Or build for production
npm run tauri:build
```

Production bundles are output to `src-tauri/target/release/bundle/`.

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Vite dev server only |
| `npm run tauri:dev` | Full Tauri dev environment |
| `npm run tauri:build` | Production build |
| `npm run build` | Build React frontend |

## Project Structure

```
src/                 # React frontend (components, utils)
src-tauri/           # Rust backend (password gen, encryption)
  src/commands/
    generate.rs      # Password generation
    vault.rs         # AES-256-GCM encryption / Argon2 KDF
```

## License

MIT
