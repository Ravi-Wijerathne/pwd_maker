use rand::RngCore;
use rand::rngs::OsRng;
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Options {
    pub length: usize,
    pub upper: bool,
    pub lower: bool,
    pub digits: bool,
    pub symbols: bool,
    pub exclude_similar: bool,
    pub custom_chars: Option<String>,
}

impl Default for Options {
    fn default() -> Self {
        Self {
            length: 16,
            upper: true,
            lower: true,
            digits: true,
            symbols: true,
            exclude_similar: false,
            custom_chars: None,
        }
    }
}

pub fn generate_password(opts: &Options) -> String {
    let mut charset = String::new();
    
    // Add custom chars first if provided
    if let Some(c) = &opts.custom_chars {
        if !c.is_empty() {
            charset.push_str(c);
        }
    }
    
    // Add standard character sets
    if opts.lower {
        charset.push_str("abcdefghijklmnopqrstuvwxyz");
    }
    if opts.upper {
        charset.push_str("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    }
    if opts.digits {
        charset.push_str("0123456789");
    }
    if opts.symbols {
        charset.push_str("!@#$%^&*()-_=+[]{};:,.<>?/|\\");
    }

    // Exclude similar-looking characters
    if opts.exclude_similar {
        let similar = "il1Lo0O";
        charset.retain(|c| !similar.contains(c));
    }

    // Fallback if charset is empty
    if charset.is_empty() {
        charset.push_str("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
    }

    // Use OsRng for cryptographically secure randomness
    let mut rng = OsRng;
    let mut result = String::with_capacity(opts.length);
    let chars: Vec<char> = charset.chars().collect();
    
    for _ in 0..opts.length {
        let idx = (rng.next_u64() as usize) % chars.len();
        result.push(chars[idx]);
    }

    result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_password_length() {
        let opts = Options {
            length: 20,
            ..Default::default()
        };
        let password = generate_password(&opts);
        assert_eq!(password.len(), 20);
    }

    #[test]
    fn test_generate_password_custom_chars() {
        let opts = Options {
            length: 10,
            upper: false,
            lower: false,
            digits: false,
            symbols: false,
            exclude_similar: false,
            custom_chars: Some("ABC".to_string()),
        };
        let password = generate_password(&opts);
        assert!(password.chars().all(|c| "ABC".contains(c)));
    }
}
