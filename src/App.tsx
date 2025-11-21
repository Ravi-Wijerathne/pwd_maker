import { useState } from 'react'
import PasswordOptions from './components/PasswordOptions'
import OutputBox from './components/OutputBox'
import StrengthMeter from './components/StrengthMeter'
import { generate, type Options } from './utils/api'

export default function App() {
  const [opts, setOpts] = useState<Options>({
    length: 16,
    upper: true,
    lower: true,
    digits: true,
    symbols: true,
    exclude_similar: false,
    custom_chars: '',
  })
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  async function onGenerate() {
    try {
      setLoading(true)
      const result = await generate(opts)
      setPassword(result)
    } catch (error) {
      console.error('Failed to generate password:', error)
      alert('Failed to generate password. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800">
      <div className="container mx-auto px-4 py-8 max-w-2xl">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-2">
            🔐 Password Maker
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Generate secure, cryptographically strong passwords
          </p>
        </div>

        {/* Main Content */}
        <div className="space-y-6">
          <PasswordOptions
            opts={opts}
            setOpts={setOpts}
            onGenerate={onGenerate}
          />

          {loading && (
            <div className="text-center text-gray-600 dark:text-gray-400">
              Generating...
            </div>
          )}

          <OutputBox value={password} />
          
          <StrengthMeter password={password} />
        </div>

        {/* Footer */}
        <div className="mt-8 text-center text-sm text-gray-600 dark:text-gray-400">
          <p>Built with React + Tauri + Rust</p>
          <p className="mt-1">All cryptographic operations run securely in Rust</p>
        </div>
      </div>
    </div>
  )
}
