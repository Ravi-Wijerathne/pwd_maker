// src/utils/strength.ts
import zxcvbn from 'zxcvbn'

export type StrengthResult = {
  score: number // 0-4
  feedback: string
  crackTime: string | number
  color: string
}

export function calculateStrength(password: string): StrengthResult {
  if (!password) {
    return {
      score: 0,
      feedback: 'Enter a password',
      crackTime: '',
      color: 'gray',
    }
  }

  const result = zxcvbn(password)
  
  const colors = ['red', 'orange', 'yellow', 'lime', 'green']
  const labels = ['Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong']
  
  return {
    score: result.score,
    feedback: labels[result.score],
    crackTime: result.crack_times_display.offline_slow_hashing_1e4_per_second,
    color: colors[result.score],
  }
}
