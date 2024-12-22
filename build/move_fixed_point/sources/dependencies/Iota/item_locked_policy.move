// Copyright (c) Mysten Labs, Inc.
// Modifications Copyright (c) 2024 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

#[test_only]
/// A Policy that makes sure an item is placed into the `Kiosk` after `purchase`.
/// `Kiosk` can be any.
module iota::item_locked_policy {
    use iota::kiosk::{Self, Kiosk};
    use iota::transfer_policy::{
        Self as policy,
        TransferPolicy,
        TransferPolicyCap,
        TransferRequest
    };

    /// Item is not in the `Kiosk`.
    const ENotInKiosk: u64 = 0;

    /// A unique confirmation for the Rule
    public struct Rule has drop {}

    public fun set<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        policy::add_rule(Rule {}, policy, cap, true)
    }

    /// Prove that an item a
    public fun prove<T>(request: &mut TransferRequest<T>, kiosk: &Kiosk) {
        let item = request.item();
        assert!(kiosk::has_item(kiosk, item) && kiosk::is_locked(kiosk, item), ENotInKiosk);
        policy::add_receipt(Rule {}, request)
    }
}
