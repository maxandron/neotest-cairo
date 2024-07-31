#[cfg(test)]
mod tests {
    use snforge_std::{declare, ContractClass, ContractClassTrait, start_prank, stop_prank, CheatTarget, L1Handler, get_class_hash, spy_events, SpyOn};

    #[derive(Drop)]
    struct BridgeDeployedConfig {
        erc721_class: ClassHash,
    }

    fn not_a_test(
        bridge_admin: ContractAddress,
    ) -> ContractAddress {
        let mut calldata: Array<felt252> = array![];
    }

    #[test]
    fn first_test() {
        // Need to declare here to get the class hash before deploy anything.
        assert_eq!(timestamp, starknet::info::get_block_timestamp(), "Wrong timestamp key");
    }

    fn not_a_test_2(collection_l1: EthAddress) -> Request {
        let ids: Span<u256> = array![].span();
    }

    #[test]
    #[should_panic]
    fn second_test() {
        stop_prank(CheatTarget::One(bridge_address));
    }
}

