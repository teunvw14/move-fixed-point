// Copyright (c) 2024 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

#[test_only]
module iota::coin_manager_tests {

    use iota::coin_manager;
    use iota::coin::{Self, CoinMetadata};
    use iota::test_scenario;
    use iota::url::{Self, Url};
    use std::ascii::{string};

    public struct COIN_MANAGER_TESTS has drop {}
    
    public struct BonusMetadata has store {
        website: Url,
        is_amazing: bool
    }

    #[test]
    fun test_coin_manager() {
        let sender = @0xA;
        let mut scenario = test_scenario::begin(sender);
        let witness = COIN_MANAGER_TESTS{};

        // Create a `Coin`.
        let (cap, meta) = coin::create_currency(
            witness,
            0, 
            b"TEST",
            b"TEST",
            b"TEST",
            option::none(),
            scenario.ctx(),
        );

        let (cmcap, metacap, mut wrapper) = coin_manager::new(cap, meta, scenario.ctx());
        
        assert!(wrapper.decimals() == 0);

        // We should start out with a Supply of 0.
        assert!(wrapper.total_supply() == 0);
        
        // Mint some coin!
        cmcap.mint_and_transfer(&mut wrapper, 10, sender, scenario.ctx());
        
        // We should now have a Supply of 10.
        assert!(wrapper.total_supply() == 10);
        
        // No maximum supply set, so we can do this again!
        cmcap.mint_and_transfer(&mut wrapper, 10, sender, scenario.ctx());

        transfer::public_transfer(cmcap, scenario.ctx().sender());
        metacap.renounce_metadata_ownership(&mut wrapper);
        transfer::public_share_object(wrapper);

        scenario.end();
    }
    
    #[test]
    fun test_coin_manager_helper() {
        let sender = @0xA;
        let mut scenario = test_scenario::begin(sender);
        let witness = COIN_MANAGER_TESTS{};

        // Create a `Coin`.
        let (cmcap, metacap, mut wrapper) = coin_manager::create(
            witness,
            0, 
            b"TEST",
            b"TEST",
            b"TEST",
            option::none(),
            scenario.ctx(),
        );

        assert!(wrapper.decimals() == 0);

        // We should start out with a Supply of 0.
        assert!(wrapper.total_supply() == 0);
        
        // Mint some coin!
        cmcap.mint_and_transfer(&mut wrapper, 10, sender, scenario.ctx());
        
        // We should now have a Supply of 10.
        assert!(wrapper.total_supply() == 10);
        
        // No maximum supply set, so we can do this again!
        cmcap.mint_and_transfer(&mut wrapper, 10, sender, scenario.ctx());

        transfer::public_transfer(cmcap, scenario.ctx().sender());
        metacap.renounce_metadata_ownership(&mut wrapper);
        transfer::public_share_object(wrapper);

        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = coin_manager::EMaximumSupplyReached)]
    fun test_max_supply_higher_that_total() {
        let sender = @0xA;
        let mut scenario = test_scenario::begin(sender);
        let witness = COIN_MANAGER_TESTS{};

        // Create a `Coin`.
        let (cap, meta) = coin::create_currency(
            witness,
            0, 
            b"TEST",
            b"TEST",
            b"TEST",
            option::none(),
            scenario.ctx(),
        );

        let (cmcap, metacap, mut wrapper) = coin_manager::new(cap, meta, scenario.ctx());
        
        // We should start out with a Supply of 0.
        assert!(wrapper.total_supply() == 0);

        // Enforce a Max Supply.
        cmcap.enforce_maximum_supply(&mut wrapper, 10);
        
        // Mint some coin!
        cmcap.mint_and_transfer(&mut wrapper, 10, sender, scenario.ctx());
        
        // We should now have a Supply of 10.
        assert!(wrapper.total_supply() == 10);
        
        // This should fail.
        cmcap.mint_and_transfer(&mut wrapper, 1, sender, scenario.ctx());

        transfer::public_transfer(cmcap, scenario.ctx().sender());
        metacap.renounce_metadata_ownership(&mut wrapper);

        transfer::public_share_object(wrapper);

        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = coin_manager::EMaximumSupplyReached)]
    fun test_max_supply_equals_total() {
        let sender = @0xA;
        let mut scenario = test_scenario::begin(sender);
        let witness = COIN_MANAGER_TESTS{};

        // Create a `Coin`.
        let (cap, meta) = coin::create_currency(
            witness,
            0, 
            b"TEST",
            b"TEST",
            b"TEST",
            option::none(),
            scenario.ctx(),
        );

        let (cmcap, metacap, mut wrapper) = coin_manager::new(cap, meta, scenario.ctx());
        
        // We should start out with a Supply of 0.
        assert!(wrapper.total_supply() == 0);
        
        // Mint some coin!
        cmcap.mint_and_transfer(&mut wrapper, 10, sender, scenario.ctx());

        // We should now have a Supply of 10.
        assert!(wrapper.total_supply() == 10);

        // Enforce a Max Supply.
        cmcap.enforce_maximum_supply(&mut wrapper, 10);
        
        // This should fail.
        cmcap.mint_and_transfer(&mut wrapper, 1, sender, scenario.ctx());

        transfer::public_transfer(cmcap, scenario.ctx().sender());
        metacap.renounce_metadata_ownership(&mut wrapper);

        transfer::public_share_object(wrapper);

        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = coin_manager::EMaximumSupplyLowerThanTotalSupply)]
    fun test_max_supply_lower_than_total() {
        let sender = @0xA;
        let mut scenario = test_scenario::begin(sender);
        let witness = COIN_MANAGER_TESTS{};

        // Create a `Coin`.
        let (cap, meta) = coin::create_currency(
            witness,
            0, 
            b"TEST",
            b"TEST",
            b"TEST",
            option::none(),
            scenario.ctx(),
        );

        let (cmcap, metacap, mut wrapper) = coin_manager::new(cap, meta, scenario.ctx());

        // We should start out with a Supply of 0.
        assert!(wrapper.total_supply() == 0);

        // Mint some coin!
        cmcap.mint_and_transfer(&mut wrapper, 10, sender, scenario.ctx());
        
        // We should now have a Supply of 10.
        assert!(wrapper.total_supply() == 10);

        // Update the maximum supply to be lower than the total supply, this should not be allowed.
        cmcap.enforce_maximum_supply(&mut wrapper, 9);
        
        transfer::public_transfer(cmcap, scenario.ctx().sender());
        metacap.renounce_metadata_ownership(&mut wrapper);

        transfer::public_share_object(wrapper);

        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = coin_manager::EMaximumSupplyAlreadySet)]
    fun test_max_supply_once() {
        let sender = @0xA;
        let mut scenario = test_scenario::begin(sender);
        let witness = COIN_MANAGER_TESTS{};

        // Create a `Coin`.
        let (cap, meta) = coin::create_currency(
            witness,
            0, 
            b"TEST",
            b"TEST",
            b"TEST",
            option::none(),
            scenario.ctx(),
        );

        let (cmcap, metacap, mut wrapper) = coin_manager::new(cap, meta, scenario.ctx());
        
        // Enforce a Max Supply.
        cmcap.enforce_maximum_supply(&mut wrapper, 10);

        // Update it, this should not be allowed.
        cmcap.enforce_maximum_supply(&mut wrapper, 20);
        
        transfer::public_transfer(cmcap, scenario.ctx().sender());
        metacap.renounce_metadata_ownership(&mut wrapper);

        transfer::public_share_object(wrapper);

        scenario.end();
    }
    
    #[test]
    fun test_renounce_ownership() {
        let sender = @0xA;
        let mut scenario = test_scenario::begin(sender);
        let witness = COIN_MANAGER_TESTS{};

        // Create a `Coin`.
        let (cap, meta) = coin::create_currency(
            witness,
            0, 
            b"TEST",
            b"TEST",
            b"TEST",
            option::none(),
            scenario.ctx(),
        );

        let (cmcap, metacap, mut wrapper) = coin_manager::new(cap, meta, scenario.ctx());
        
        // We should start out with a Supply of 0.
        assert!(wrapper.total_supply() == 0);

        // Enforce a Max Supply.
        cmcap.enforce_maximum_supply(&mut wrapper, 10);
        
        // Mint some coin!
        cmcap.mint_and_transfer(&mut wrapper, 5, sender, scenario.ctx());
        
        // We should now have a Supply of 5.
        assert!(wrapper.total_supply() == 5);
        
        // We should now have a Max Supply of 10.
        assert!(wrapper.maximum_supply() == 10);

        // The coin is not immutable right now, we still have a `CoinManagerCap`.
        assert!(!wrapper.supply_is_immutable());
        assert!(!wrapper.metadata_is_immutable());
        
        // Lets turn it immutable!
        cmcap.renounce_treasury_ownership(&mut wrapper);

        // The coin should be immutable right now.
        assert!(wrapper.supply_is_immutable());
        // But metadata should still be mutable.
        assert!(!wrapper.metadata_is_immutable());
        
        // We should now have a Max Supply of 5, due to renouncing of ownership.
        assert!(wrapper.maximum_supply() == 5);

        metacap.renounce_metadata_ownership(&mut wrapper);
        assert!(wrapper.metadata_is_immutable());

        transfer::public_share_object(wrapper);
        scenario.end();
    }
    
    #[test]
    fun test_additional_metadata() {
        let sender = @0xA;
        let mut scenario = test_scenario::begin(sender);
        let witness = COIN_MANAGER_TESTS{};

        // Create a `Coin`.
        let (cap, meta) = coin::create_currency(
            witness,
            0, 
            b"TEST",
            b"TEST",
            b"TEST",
            option::none(),
            scenario.ctx(),
        );

        let (cmcap, metacap, mut wrapper) = coin_manager::new(cap, meta, scenario.ctx());

        let bonus = BonusMetadata {
            website: url::new_unsafe(string(b"https://example.com")),
            is_amazing: false
        };

        metacap.add_additional_metadata(&mut wrapper, bonus);

        assert!(!wrapper.additional_metadata<COIN_MANAGER_TESTS, BonusMetadata>().is_amazing);
        
        let bonus2 = BonusMetadata {
            website: url::new_unsafe(string(b"https://iota.org")),
            is_amazing: true
        };

        let oldmeta = metacap.replace_additional_metadata<COIN_MANAGER_TESTS, BonusMetadata, BonusMetadata>(&mut wrapper, bonus2);

        let BonusMetadata { website: _, is_amazing: _ } = oldmeta;
        
        assert!(wrapper.additional_metadata<COIN_MANAGER_TESTS, BonusMetadata>().is_amazing);
        
        cmcap.renounce_treasury_ownership(&mut wrapper);
        metacap.renounce_metadata_ownership(&mut wrapper);
        transfer::public_share_object(wrapper);

        scenario.end();
    }
    
    #[test]
    fun test_coin_manager_immutable() {
        let sender = @0xA;
        let mut scenario = test_scenario::begin(sender);
        let witness = COIN_MANAGER_TESTS{};

        // Create a `Coin`.
        let (cap, meta) = coin::create_currency(
            witness,
            0, 
            b"TEST",
            b"TEST",
            b"TEST",
            option::none(),
            scenario.ctx(),
        );

        transfer::public_freeze_object(meta);
        test_scenario::next_tx(&mut scenario, sender);

        let immeta = test_scenario::take_immutable<CoinMetadata<COIN_MANAGER_TESTS>>(&scenario);
        let (cmcap, mut wrapper) = coin_manager::new_with_immutable_metadata(cap, &immeta, scenario.ctx());
        
        assert!(wrapper.metadata_is_immutable());
        
        assert!(wrapper.decimals() == 0);

        // We should start out with a Supply of 0.
        assert!(wrapper.total_supply() == 0);
        
        // Mint some coin!
        cmcap.mint_and_transfer(&mut wrapper, 10, sender, scenario.ctx());

        transfer::public_transfer(cmcap, scenario.ctx().sender());
        transfer::public_share_object(wrapper);
        test_scenario::return_immutable(immeta);

        scenario.end();
    }
}
