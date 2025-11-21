// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod commands;

use base64::{engine::general_purpose, Engine as _};
use commands::generate::{generate_password, Options};
use commands::vault::{decrypt, derive_key, encrypt, generate_salt, VaultEntry};

#[tauri::command]
fn tauri_generate(opts: Options) -> Result<String, String> {
    Ok(generate_password(&opts))
}

#[tauri::command]
fn tauri_encrypt(
    plaintext: String,
    master_password: String,
    salt_b64: String,
) -> Result<String, String> {
    let salt = general_purpose::STANDARD
        .decode(salt_b64)
        .map_err(|e| format!("Invalid salt: {}", e))?;
    
    let key = derive_key(&master_password, &salt)
        .map_err(|e| format!("Key derivation failed: {}", e))?;
    
    encrypt(plaintext.as_bytes(), &key).map_err(|e| format!("Encryption failed: {}", e))
}

#[tauri::command]
fn tauri_decrypt(
    ciphertext: String,
    master_password: String,
    salt_b64: String,
) -> Result<String, String> {
    let salt = general_purpose::STANDARD
        .decode(salt_b64)
        .map_err(|e| format!("Invalid salt: {}", e))?;
    
    let key = derive_key(&master_password, &salt)
        .map_err(|e| format!("Key derivation failed: {}", e))?;
    
    let plaintext_bytes = decrypt(&ciphertext, &key)
        .map_err(|e| format!("Decryption failed: {}", e))?;
    
    String::from_utf8(plaintext_bytes).map_err(|e| format!("Invalid UTF-8: {}", e))
}

#[tauri::command]
fn tauri_generate_salt() -> String {
    let salt = generate_salt();
    general_purpose::STANDARD.encode(salt)
}

#[tauri::command]
fn tauri_encrypt_vault(
    entries: Vec<VaultEntry>,
    master_password: String,
    salt_b64: String,
) -> Result<String, String> {
    let json = serde_json::to_string(&entries).map_err(|e| format!("JSON error: {}", e))?;
    tauri_encrypt(json, master_password, salt_b64)
}

#[tauri::command]
fn tauri_decrypt_vault(
    ciphertext: String,
    master_password: String,
    salt_b64: String,
) -> Result<Vec<VaultEntry>, String> {
    let json = tauri_decrypt(ciphertext, master_password, salt_b64)?;
    serde_json::from_str(&json).map_err(|e| format!("JSON parse error: {}", e))
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            tauri_generate,
            tauri_encrypt,
            tauri_decrypt,
            tauri_generate_salt,
            tauri_encrypt_vault,
            tauri_decrypt_vault
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
