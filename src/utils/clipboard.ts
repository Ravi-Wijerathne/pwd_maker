// src/utils/clipboard.ts
import { writeText } from '@tauri-apps/api/clipboard'

export async function copyToClipboard(text: string): Promise<void> {
  await writeText(text)
}

export function clearClipboardAfter(seconds: number): void {
  setTimeout(async () => {
    await writeText('')
  }, seconds * 1000)
}
