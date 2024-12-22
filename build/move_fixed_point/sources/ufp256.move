/// A module providing an unsigned fixed-point number type
/// and methods for working with these numbers.
module move_fixed_point::ufp256 {

    const DECIMAL_FACTOR: u256 = 10_000_000_000_000_000_000; // 10^18

    // A 256-bit unsigned fixed point number with 18 decimal places for 
    // high-precision calculations.
    public struct UFP256 has store, copy, drop {
        mantissa: u256
    }

    // Create a new 256-bit unsigned fixed point integer (type UFP256)
    public fun new(mantissa: u256): UFP256 {
        UFP256 {
            mantissa
        }
    }

    // UFP256 with value 0
    public fun zero(): UFP256 {
        UFP256 {
            mantissa: 0
        }
    }

    // UFP256 with value 1
    public fun unit(): UFP256 {
        UFP256 {
            mantissa: DECIMAL_FACTOR
        }
    }

    // Create a UFP256 from a fraction
    public fun from_fraction(numerator: u256, denominator: u256) : UFP256 {
        assert!(denominator != 0);

        let mantissa = (DECIMAL_FACTOR * numerator) / denominator;
        UFP256 {
            mantissa
        }
    }

    // Cast to a u64 by flooring to the closest integer
    public fun truncate_to_u64(n: &UFP256): u64 {
        (n.mantissa / DECIMAL_FACTOR) as u64
    }

    // Calculate `n * u` where `u` is a u64
    public fun mul_u64(n: &UFP256, u: u64): u64 {
        let result = new(DECIMAL_FACTOR * (u as u256)).mul(*n);

        result.truncate_to_u64()
    }

    // Calculate `u / n` where `u` is a u64 (floor division)
    public fun div_u64(n: &UFP256, u: u64): u64 {        
        let result = new(DECIMAL_FACTOR * (u as u256)).div(*n);

        result.truncate_to_u64()
    }

    // Calculate `n / u` where `u` is a u64 (floor division)
    public fun div_by_u64(n: &UFP256, u: u64): u64 {        
        let result = n.div(new(DECIMAL_FACTOR * (u as u256)));

        result.truncate_to_u64()
    }

    // Get max(first, second), i.e. the largest of `first` and `second`
    public fun max(first: UFP256, second: UFP256): UFP256 {
        if (first.mantissa >= second.mantissa) {
            return first
        } else {
            return second
        }
    }

    // Get min(first, second), i.e. the smallest of `first` and `second`
    public fun min(first: UFP256, second: UFP256): UFP256 {
        if (first.mantissa <= second.mantissa) {
            return first
        } else {
            return second
        }
    }

    // Calculate sums: `n.add(other) = n + other`
    public fun add(n: &UFP256, other: UFP256): UFP256 {
        UFP256 {
            mantissa: n.mantissa + other.mantissa
        }
    }

    // Calculate absolute differences: `n.diff(n, other) = abs(n - other)`
    public fun diff(n: &UFP256, other: UFP256): UFP256 {
        let min = min(*n, other);
        let max = max(*n, other);
        UFP256 {
            mantissa: max.mantissa - min.mantissa
        }
    }

    // Calculate products: `n.mul(other) = n * other`
    public fun mul(n: &UFP256, other: UFP256): UFP256 {
        let mantissa = (n.mantissa * other.mantissa) / DECIMAL_FACTOR;
        UFP256 {
            mantissa
        }
    }

    // Calculate powers of n: `n.pow(p) = n^p`
    public fun pow(n: &UFP256, p: u64): UFP256 {
        let base = *n;
        let mut result = new(DECIMAL_FACTOR);
        p.do!(|_| result = result.mul(base));
        result
    }

    // Calculate quotients: `n.div(other) = n / other`
    public fun div(n: &UFP256, other: UFP256): UFP256 {
        let mantissa = (DECIMAL_FACTOR * n.mantissa) / other.mantissa;

        UFP256 {
            mantissa
        }
    }

    // Calculate negative powers: `n.pow_neg(p) = n^{-p}`
    public fun pow_neg(n: &UFP256, p: u64): UFP256 {
        let base = *n;
        let mut result = new(DECIMAL_FACTOR);
        p.do!(|_| result = result.div(base));
        result
    }
}