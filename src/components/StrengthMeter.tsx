import { calculateStrength } from '../utils/strength'

type Props = {
  password: string
}

export default function StrengthMeter({ password }: Props) {
  const strength = calculateStrength(password)

  if (!password) return null

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-4 space-y-2">
      <div className="flex justify-between items-center">
        <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
          Password Strength:
        </span>
        <span
          className="text-sm font-bold"
          style={{ color: strength.color }}
        >
          {strength.feedback}
        </span>
      </div>

      {/* Strength Bar */}
      <div className="w-full bg-gray-200 rounded-full h-2 dark:bg-gray-700">
        <div
          className="h-2 rounded-full transition-all duration-300"
          style={{
            width: `${(strength.score + 1) * 20}%`,
            backgroundColor: strength.color,
          }}
        />
      </div>

      {/* Crack Time */}
      {strength.crackTime && (
        <p className="text-xs text-gray-600 dark:text-gray-400">
          Time to crack (offline): {strength.crackTime}
        </p>
      )}
    </div>
  )
}
