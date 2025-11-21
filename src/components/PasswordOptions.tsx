import type { Options } from '../utils/api'

type Props = {
  opts: Options
  setOpts: (o: Options) => void
  onGenerate: () => void
}

export default function PasswordOptions({ opts, setOpts, onGenerate }: Props) {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 space-y-4">
      <h2 className="text-xl font-semibold text-gray-800 dark:text-white mb-4">
        Password Options
      </h2>

      {/* Length Slider */}
      <div className="space-y-2">
        <div className="flex justify-between items-center">
          <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
            Length
          </label>
          <span className="text-lg font-bold text-blue-600 dark:text-blue-400">
            {opts.length}
          </span>
        </div>
        <input
          type="range"
          min={4}
          max={64}
          value={opts.length}
          onChange={(e) => setOpts({ ...opts, length: +e.target.value })}
          className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
        />
      </div>

      {/* Character Type Checkboxes */}
      <div className="grid grid-cols-2 gap-3">
        <label className="flex items-center space-x-2 cursor-pointer">
          <input
            type="checkbox"
            checked={opts.upper}
            onChange={(e) => setOpts({ ...opts, upper: e.target.checked })}
            className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500"
          />
          <span className="text-sm text-gray-700 dark:text-gray-300">
            Uppercase (A-Z)
          </span>
        </label>

        <label className="flex items-center space-x-2 cursor-pointer">
          <input
            type="checkbox"
            checked={opts.lower}
            onChange={(e) => setOpts({ ...opts, lower: e.target.checked })}
            className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500"
          />
          <span className="text-sm text-gray-700 dark:text-gray-300">
            Lowercase (a-z)
          </span>
        </label>

        <label className="flex items-center space-x-2 cursor-pointer">
          <input
            type="checkbox"
            checked={opts.digits}
            onChange={(e) => setOpts({ ...opts, digits: e.target.checked })}
            className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500"
          />
          <span className="text-sm text-gray-700 dark:text-gray-300">
            Numbers (0-9)
          </span>
        </label>

        <label className="flex items-center space-x-2 cursor-pointer">
          <input
            type="checkbox"
            checked={opts.symbols}
            onChange={(e) => setOpts({ ...opts, symbols: e.target.checked })}
            className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500"
          />
          <span className="text-sm text-gray-700 dark:text-gray-300">
            Symbols (!@#$...)
          </span>
        </label>
      </div>

      {/* Exclude Similar */}
      <label className="flex items-center space-x-2 cursor-pointer">
        <input
          type="checkbox"
          checked={opts.exclude_similar}
          onChange={(e) =>
            setOpts({ ...opts, exclude_similar: e.target.checked })
          }
          className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500"
        />
        <span className="text-sm text-gray-700 dark:text-gray-300">
          Exclude similar characters (i, l, 1, L, o, 0, O)
        </span>
      </label>

      {/* Custom Characters */}
      <div className="space-y-2">
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
          Custom Characters (optional)
        </label>
        <input
          type="text"
          value={opts.custom_chars || ''}
          onChange={(e) => setOpts({ ...opts, custom_chars: e.target.value })}
          placeholder="e.g., @#$%"
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:border-gray-600 dark:text-white"
        />
      </div>

      {/* Generate Button */}
      <button
        onClick={onGenerate}
        className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-lg transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      >
        Generate Password
      </button>
    </div>
  )
}
