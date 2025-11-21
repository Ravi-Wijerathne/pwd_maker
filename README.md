# Password Maker — React + Tauri + Rust

A secure, cross-platform password generator built with React, Tauri, and Rust. Generate cryptographically strong passwords with customizable options and built-in strength analysis.

## ✨ Features

- 🔐 **Cryptographically Secure** - Uses Rust's `OsRng` for true random password generation
- 🎨 **Modern UI** - Beautiful React interface with Tailwind CSS
- 🔒 **Encryption Ready** - Built-in AES-256-GCM encryption with Argon2 key derivation
- 📊 **Strength Analysis** - Real-time password strength meter using zxcvbn
- 📋 **Smart Clipboard** - Auto-clears clipboard after 30 seconds for security
- 🌙 **Dark Mode** - Automatic light/dark theme support
- 🚀 **Cross-Platform** - Works on Windows, macOS, and Linux
- ⚡ **Fast & Lightweight** - Native performance with Tauri

## 🏗️ Architecture

```
┌─────────────────────────────┐
│       React UI              │
│  (Vite + React + Tailwind)  │
└─────────────┬───────────────┘
              │
        Tauri Bridge
              │
┌─────────────▼───────────────┐
│      Rust Backend           │
│  • Password Generator       │
│  • Encryption (AES-GCM)     │
│  • Key Derivation (Argon2)  │
│  • OS Integrations          │
└─────────────────────────────┘
```

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### 1. **Node.js & npm**
- Download from [nodejs.org](https://nodejs.org/) (v18 or higher recommended)
- Verify installation:
  ```powershell
  node --version
  npm --version
  ```

### 2. **Rust**
- Install from [rustup.rs](https://rustup.rs/)
- Verify installation:
  ```powershell
  rustc --version
  cargo --version
  ```

### 3. **Tauri Prerequisites**

#### Windows
- Install Microsoft Visual Studio C++ Build Tools
- Install WebView2 (usually pre-installed on Windows 10/11)

#### macOS
```bash
xcode-select --install
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install libwebkit2gtk-4.0-dev \
    build-essential \
    curl \
    wget \
    file \
    libssl-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev
```

For other Linux distributions, see [Tauri Prerequisites](https://tauri.app/v1/guides/getting-started/prerequisites).

## 🚀 Getting Started

### 1. Install Dependencies

```powershell
npm install
```

This will install all Node.js dependencies including React, Vite, Tailwind CSS, and Tauri CLI.

### 2. Development Mode

Run the application in development mode with hot-reload:

```powershell
npm run tauri:dev
```

This command will:
- Start the Vite development server (React)
- Compile the Rust backend
- Launch the Tauri application window

### 3. Build for Production

Create optimized production builds for your platform:

```powershell
npm run tauri:build
```

The built application will be available in:
- Windows: `src-tauri/target/release/bundle/msi/`
- macOS: `src-tauri/target/release/bundle/dmg/`
- Linux: `src-tauri/target/release/bundle/deb/` or `appimage/`

## 📁 Project Structure

```
password-maker/
├── src/                          # React frontend
│   ├── components/
│   │   ├── PasswordOptions.tsx   # Password configuration UI
│   │   ├── StrengthMeter.tsx     # Password strength indicator
│   │   └── OutputBox.tsx         # Generated password display
│   ├── utils/
│   │   ├── api.ts                # Tauri command wrappers
│   │   ├── clipboard.ts          # Clipboard utilities
│   │   └── strength.ts           # Password strength calculation
│   ├── App.tsx                   # Main app component
│   ├── main.tsx                  # React entry point
│   └── index.css                 # Global styles
│
├── src-tauri/                    # Rust backend
│   ├── src/
│   │   ├── commands/
│   │   │   ├── generate.rs       # Password generation logic
│   │   │   └── vault.rs          # Encryption/decryption
│   │   └── main.rs               # Tauri app entry point
│   ├── Cargo.toml                # Rust dependencies
│   └── tauri.conf.json           # Tauri configuration
│
├── package.json                  # Node.js dependencies & scripts
├── vite.config.ts                # Vite configuration
├── tailwind.config.js            # Tailwind CSS configuration
└── tsconfig.json                 # TypeScript configuration
```

## 🎮 Usage

### Generate a Password

1. **Set Password Length** - Use the slider to choose length (4-64 characters)
2. **Select Character Types**:
   - Uppercase letters (A-Z)
   - Lowercase letters (a-z)
   - Numbers (0-9)
   - Symbols (!@#$%^&*...)
3. **Optional Settings**:
   - Exclude similar characters (i, l, 1, L, o, 0, O)
   - Add custom characters
4. Click **Generate Password**

### Password Strength

The app displays a real-time strength meter showing:
- **Score**: Very Weak to Very Strong (5 levels)
- **Estimated crack time**: Time to crack via offline attack
- **Visual indicator**: Color-coded strength bar

### Security Features

- ✅ Passwords generated using cryptographically secure random number generator
- ✅ All crypto operations run in Rust (isolated from JavaScript)
- ✅ Clipboard auto-clears after 30 seconds
- ✅ No passwords are logged or stored by default

## 🔒 Encryption API (Advanced)

The app includes built-in encryption capabilities:

### Commands Available

```typescript
// Generate a random salt
const salt = await generateSalt()

// Encrypt text
const encrypted = await encrypt(plaintext, masterPassword, salt)

// Decrypt text
const decrypted = await decrypt(encrypted, masterPassword, salt)
```

### Security Details

- **Key Derivation**: Argon2id (default parameters, tunable)
- **Encryption**: AES-256-GCM (authenticated encryption)
- **Nonce**: Randomly generated for each encryption
- **Storage**: Base64-encoded (nonce + ciphertext)

## 🛠️ Development

### Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start Vite dev server only |
| `npm run build` | Build React app for production |
| `npm run tauri:dev` | Run Tauri app in development |
| `npm run tauri:build` | Build production app bundle |
| `npm run preview` | Preview production build locally |

### Running Rust Tests

```powershell
cd src-tauri
cargo test
```

### Linting & Type Checking

```powershell
# TypeScript type checking
npm run build

# Format Rust code
cd src-tauri
cargo fmt
```

## 🐛 Troubleshooting

### Issue: Tauri build fails on Windows

**Solution**: Ensure Microsoft Visual Studio C++ Build Tools are installed:
```powershell
# Download from: https://visualstudio.microsoft.com/downloads/
# Select "Desktop development with C++"
```

### Issue: `Cannot find module '@tauri-apps/api'`

**Solution**: Reinstall dependencies:
```powershell
rm -r node_modules
npm install
```

### Issue: Rust compilation errors

**Solution**: Update Rust toolchain:
```powershell
rustup update
```

### Issue: WebView2 missing (Windows)

**Solution**: Download and install [WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)

## 📦 Customization

### Change App Name & Icon

1. Edit `src-tauri/tauri.conf.json`:
```json
{
  "package": {
    "productName": "Your App Name",
    "version": "1.0.0"
  }
}
```

2. Replace icons in `src-tauri/icons/` directory

### Adjust Encryption Parameters

Edit `src-tauri/src/commands/vault.rs`:
```rust
// Increase Argon2 memory cost for stronger security
use argon2::{Argon2, Params};

let params = Params::new(65536, 3, 4, None)?; // mem, time, parallelism
let argon2 = Argon2::new(Algorithm::Argon2id, Version::V0x13, params);
```

## 🔐 Security Best Practices

1. ✅ **Use strong master passwords** for encryption
2. ✅ **Never store master passwords** - keep them in memory only
3. ✅ **Generate long passwords** - 16+ characters recommended
4. ✅ **Use all character types** for maximum entropy
5. ✅ **Avoid patterns** - let the generator create truly random passwords
6. ✅ **Update dependencies** regularly for security patches

## 📄 License

MIT License - feel free to use this project for personal or commercial purposes.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙏 Acknowledgments

- [Tauri](https://tauri.app/) - Cross-platform app framework
- [React](https://react.dev/) - UI library
- [Vite](https://vitejs.dev/) - Fast build tool
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS
- [zxcvbn](https://github.com/dropbox/zxcvbn) - Password strength estimation

---

**Built with ❤️ using React, Tauri, and Rust**
