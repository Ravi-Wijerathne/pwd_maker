// src/utils/api.ts
import { invoke } from '@tauri-apps/api/tauri'

export type Options = {
  length: number
  upper: boolean
  lower: boolean
  digits: boolean
  symbols: boolean
  exclude_similar: boolean
  custom_chars?: string
}

export type VaultEntry = {
  id: string
  title: string
  username: string
  password: string
  url?: string
  notes?: string
  created_at: number
  modified_at: number
}

export async function generate(opts: Options): Promise<string> {
  return invoke('tauri_generate', { opts }) as Promise<string>
}

export async function encrypt(
  plaintext: string,
  masterPassword: string,
  saltB64: string
): Promise<string> {
  return invoke('tauri_encrypt', {
    plaintext,
    masterPassword,
    saltB64,
  }) as Promise<string>
}

export async function decrypt(
  ciphertext: string,
  masterPassword: string,
  saltB64: string
): Promise<string> {
  return invoke('tauri_decrypt', {
    ciphertext,
    masterPassword,
    saltB64,
  }) as Promise<string>
}

export async function generateSalt(): Promise<string> {
  return invoke('tauri_generate_salt') as Promise<string>
}

export async function encryptVault(
  entries: VaultEntry[],
  masterPassword: string,
  saltB64: string
): Promise<string> {
  return invoke('tauri_encrypt_vault', {
    entries,
    masterPassword,
    saltB64,
  }) as Promise<string>
}

export async function decryptVault(
  ciphertext: string,
  masterPassword: string,
  saltB64: string
): Promise<VaultEntry[]> {
  return invoke('tauri_decrypt_vault', {
    ciphertext,
    masterPassword,
    saltB64,
  }) as Promise<VaultEntry[]>
}
