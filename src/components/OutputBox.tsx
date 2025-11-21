import { useState } from 'react'
import { copyToClipboard, clearClipboardAfter } from '../utils/clipboard'

type Props = {
  value: string
}

export default function OutputBox({ value }: Props) {
  const [copied, setCopied] = useState(false)

  const handleCopy = async () => {
    if (!value) return
    await copyToClipboard(value)
    setCopied(true)
    clearClipboardAfter(30) // Clear after 30 seconds
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-4 space-y-3">
      <h3 className="text-sm font-medium text-gray-700 dark:text-gray-300">
        Generated Password
      </h3>

      <div className="relative">
        <input
          type="text"
          readOnly
          value={value}
          placeholder="Your password will appear here..."
          className="w-full px-4 py-3 pr-24 text-lg font-mono bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"
        />
        <button
          onClick={handleCopy}
          disabled={!value}
          className={`absolute right-2 top-1/2 -translate-y-1/2 px-4 py-1.5 rounded-md font-medium transition-colors ${
            copied
              ? 'bg-green-500 text-white'
              : 'bg-blue-600 hover:bg-blue-700 text-white disabled:bg-gray-400 disabled:cursor-not-allowed'
          }`}
        >
          {copied ? '✓ Copied' : 'Copy'}
        </button>
      </div>

      {value && (
        <div className="flex items-center space-x-2 text-xs text-gray-600 dark:text-gray-400">
          <span>⚠️ Clipboard will auto-clear in 30 seconds</span>
        </div>
      )}
    </div>
  )
}
