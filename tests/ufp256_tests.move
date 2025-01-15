#[test_only]
module move_fixed_point::ufp256_tests {
    use move_fixed_point::ufp256::{Self, UFP256};

    use iota::test_utils::{assert_eq};

    const DECIMAL_FACTOR: u256 = 18446744073709551616; // 2^64, 64 fractional bits

    #[test]
    fun test_from_fraction() {
        // 3/2 = 1.5
        assert_eq(ufp256::from_fraction(3, 2), ufp256::new(DECIMAL_FACTOR * 15 / 10));
        
        // 1/10 = 0.1
        assert_eq(ufp256::from_fraction(1, 10), ufp256::new(DECIMAL_FACTOR * 1 / 10));
        
        // 7/4 = 1.25
        assert_eq(ufp256::from_fraction(7, 4), ufp256::new(DECIMAL_FACTOR * 175 / 100));

        // 2/3
        assert_eq(ufp256::from_fraction(2, 3), ufp256::new(DECIMAL_FACTOR * 2 / 3));

        // 9/8 = 1.125
        assert_eq(ufp256::from_fraction(9, 8), ufp256::new(DECIMAL_FACTOR * 1125 / 1000));
    }

    #[test_only]
    fun test_add_single(
        first: UFP256,
        second: UFP256,
        expected_result: UFP256
    ) {
        assert_eq(first.add(second), expected_result);
    }

    #[test]
    fun test_add() {
        // 1 + 1 = 2
        test_add_single(
            ufp256::new(DECIMAL_FACTOR),
            ufp256::new(DECIMAL_FACTOR),
            ufp256::new(DECIMAL_FACTOR * 2)
        );
        
        // 0.5 + 0.25 = 0.75
        test_add_single(
            ufp256::new(DECIMAL_FACTOR * 5 / 10),
            ufp256::new(DECIMAL_FACTOR * 5 / 10),
            ufp256::new(DECIMAL_FACTOR)
        );

        // 1.5 + 3.75 = 5.25
        test_add_single(
            ufp256::new(DECIMAL_FACTOR * 15 / 10),
            ufp256::new(DECIMAL_FACTOR * 375 / 100),
            ufp256::new(DECIMAL_FACTOR * 525 / 100)
        );

        // 0.25 + 9.75 = 10
        test_add_single(
            ufp256::new(DECIMAL_FACTOR * 25 / 100),
            ufp256::new(DECIMAL_FACTOR * 975 / 100),
            ufp256::new(DECIMAL_FACTOR * 10)
        );
    }

    #[test_only]
    fun test_mul_single(
        first: UFP256,
        second: UFP256,
        expected_result: UFP256
    ) {
        assert_eq(first.mul(second), expected_result);
    }

    #[test]
    fun test_mul() {
        // 2 * 3 = 6
        test_mul_single(
            ufp256::new(DECIMAL_FACTOR * 2),
            ufp256::new(DECIMAL_FACTOR * 3),
            ufp256::new(DECIMAL_FACTOR * 6)
        );

        // 1/2 * 6 = 3
        test_mul_single(
            ufp256::new(DECIMAL_FACTOR / 2),
            ufp256::new(DECIMAL_FACTOR * 6),
            ufp256::new(DECIMAL_FACTOR * 3)
        );

        // 1/2 * 1/4 = 1/8
        test_mul_single(
            ufp256::new(DECIMAL_FACTOR / 2),
            ufp256::new(DECIMAL_FACTOR / 4),
            ufp256::new(DECIMAL_FACTOR / 8)
        );

        // 3/4 * 12 = 9
        test_mul_single(
            ufp256::new(DECIMAL_FACTOR * 3 / 4),
            ufp256::new(DECIMAL_FACTOR * 12),
            ufp256::new(DECIMAL_FACTOR * 9)
        );

        // 2 * 1/2 = 1
        test_mul_single(
            ufp256::new(DECIMAL_FACTOR * 2),
            ufp256::new(DECIMAL_FACTOR / 2),
            ufp256::new(DECIMAL_FACTOR)
        );

        // 1/8 * 16 = 2
        test_mul_single(
            ufp256::new(DECIMAL_FACTOR / 8),
            ufp256::new(DECIMAL_FACTOR * 16),
            ufp256::new(DECIMAL_FACTOR * 2)
        );

        // 1/3 * 3 = 1
        test_mul_single(
            ufp256::new(DECIMAL_FACTOR / 3),
            ufp256::new(DECIMAL_FACTOR * 3),
            ufp256::new((DECIMAL_FACTOR / 3) * 3)
        );
    }

    #[test_only]
    fun test_diff_single(
        first: UFP256,
        second: UFP256,
        expected_result: UFP256
    ) {
        assert_eq(first.diff(second), expected_result);
    }

    #[test]
    fun test_diff() {
        // diff(5, 3) = 2
        test_diff_single(
            ufp256::new(DECIMAL_FACTOR * 5),
            ufp256::new(DECIMAL_FACTOR * 3),
            ufp256::new(DECIMAL_FACTOR * 2)
        );

        // diff(3, 5) = 2
        test_diff_single(
            ufp256::new(DECIMAL_FACTOR * 3),
            ufp256::new(DECIMAL_FACTOR * 5),
            ufp256::new(DECIMAL_FACTOR * 2)
        );

        // diff(4.5, 3.25) = 1.25
        test_diff_single(
            ufp256::new(DECIMAL_FACTOR * 45 / 10),
            ufp256::new(DECIMAL_FACTOR * 325 / 100),
            ufp256::new(DECIMAL_FACTOR * 125 / 100)
        );

        // diff(3.0, 2.5) = 0.5
        test_diff_single(
            ufp256::new(DECIMAL_FACTOR * 3),
            ufp256::new(DECIMAL_FACTOR * 25 / 10),
            ufp256::new(DECIMAL_FACTOR * 5 / 10)
        );

        // diff(6.75, 6.75) = 0
        test_diff_single(
            ufp256::new(DECIMAL_FACTOR * 675 / 100),
            ufp256::new(DECIMAL_FACTOR * 675 / 100),
            ufp256::new(0)
        );
    }

    #[test_only]
    fun test_pow_single(
        n: UFP256,
        power: u64,
        expected_result: UFP256
    ) {
        assert_eq(n.pow(power), expected_result);
    }

    #[test]
    fun test_pow() {
        // 2 ^ 2 = 4
        test_pow_single(
            ufp256::new(DECIMAL_FACTOR * 2),
            2,
            ufp256::new(DECIMAL_FACTOR * 4)
        );

        // 3 ^ 3 = 27
        test_pow_single(
            ufp256::new(DECIMAL_FACTOR * 3),
            3,
            ufp256::new(DECIMAL_FACTOR * 27)
        );

        // (1/2) ^ 3 = 1/8
        test_pow_single(
            ufp256::new(DECIMAL_FACTOR / 2),
            3,
            ufp256::new(DECIMAL_FACTOR / 8)
        );

        // 1.5 ^ 2 = 2.25
        test_pow_single(
            ufp256::new(DECIMAL_FACTOR * 15 / 10),
            2,
            ufp256::new(DECIMAL_FACTOR * 225 / 100)
        );
    }

    #[test_only]
    fun test_div_single(
        n: UFP256,
        other: UFP256,
        expected_result: UFP256
    ) {
        assert_eq(n.div(other), expected_result);
    }

    #[test]
    fun test_div() {
        // 1 / 2 = 0.5
        test_div_single(
            ufp256::new(DECIMAL_FACTOR),
            ufp256::new(DECIMAL_FACTOR * 2),
            ufp256::new(DECIMAL_FACTOR / 2)
        );

        // 10 / 10 = 1
        test_div_single(
            ufp256::new(DECIMAL_FACTOR * 10),
            ufp256::new(DECIMAL_FACTOR * 10),
            ufp256::new(DECIMAL_FACTOR)
        );        

        // MAX_U256 / 5 = MAX_U256 / 5
        test_div_single(
            ufp256::new(2u256.pow(127)),
            ufp256::new(DECIMAL_FACTOR * 5),
            ufp256::new(2u256.pow(127) / 5)
        );

        // 3 / 2 = 1.5
        test_div_single(
            ufp256::new(DECIMAL_FACTOR * 3),
            ufp256::new(DECIMAL_FACTOR * 2),
            ufp256::new(DECIMAL_FACTOR * 15 / 10)
        );

        // 7.5 / 2.5 = 3
        test_div_single(
            ufp256::new(DECIMAL_FACTOR * 75 / 10),
            ufp256::new(DECIMAL_FACTOR * 25 / 10),
            ufp256::new(DECIMAL_FACTOR * 3)
        );

        // 1 / 3 = DECIMAL_FACTOR / 3
        test_div_single(
            ufp256::new(DECIMAL_FACTOR),
            ufp256::new(DECIMAL_FACTOR * 3),
            ufp256::new(DECIMAL_FACTOR / 3)
        );
    }

    #[test_only]
    fun test_pow_neg_single(
        n: UFP256,
        power: u64,
        expected_result: UFP256
    ) {
        assert_eq(n.pow_neg(power), expected_result);
    }

    #[test]
    fun test_pow_neg() {
        // 5^-0 = 1
        test_pow_neg_single(
            ufp256::new(DECIMAL_FACTOR * 5),
            0,
            ufp256::new(DECIMAL_FACTOR)
        );

        // 4^-1 = 1/4
        test_pow_neg_single(
            ufp256::new(DECIMAL_FACTOR * 4),
            1,
            ufp256::new(DECIMAL_FACTOR / 4)
        );

        // 3^-2 = 1/9
        test_pow_neg_single(
            ufp256::new(DECIMAL_FACTOR * 3),
            2,
            ufp256::new(DECIMAL_FACTOR / 9)
        );

        // 10^-3 = 0.001
        test_pow_neg_single(
            ufp256::new(DECIMAL_FACTOR * 10),
            3,
            ufp256::new(DECIMAL_FACTOR / 1000)
        );

        // 2^-10 = 1/1024
        test_pow_neg_single(
            ufp256::new(DECIMAL_FACTOR * 2),
            10,
            ufp256::new(DECIMAL_FACTOR / 1024)
        );
    }

    #[test]
    fun test_mixed() {
        let unit = ufp256::new(DECIMAL_FACTOR);
        let five_fourths = ufp256::new(DECIMAL_FACTOR * 5 / 4);
        let two_half = ufp256::new(DECIMAL_FACTOR * 25 / 10);
        let three = ufp256::new(DECIMAL_FACTOR * 3);
        let four = ufp256::new(DECIMAL_FACTOR * 4);
        let five = ufp256::new(DECIMAL_FACTOR * 5);

        // ((((2.5^2 * 3) / 1) + 1.25) / 4) = 5
        assert_eq(
            two_half.pow(2)
            .mul(three)
            .div(unit)
            .add(five_fourths)
            .div(four),
            five);
    }
}
