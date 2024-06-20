// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts for Cairo ^0.13.0

#[starknet::contract]
mod DevDock {
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::token::erc20::ERC20Component;
    use openzeppelin::token::erc20::ERC20HooksEmptyImpl;
    use starknet::ContractAddress;
    use starknet::get_contract_address;
    use starknet::get_caller_address;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;

    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        balances: LegacyMap<ContractAddress, u256>,
        supply: u256
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.erc20.initializer("STARK", "STRK");
        // self.ownable.initializer(owner);
        self.ownable.initializer(get_caller_address())
        self.mint(get_contract_address(),1000000000000000000000);//1*10^21
        self.supply = 1000000000000000000000;//1*10^21
    }

    #[generate_trait]
    #[abi(per_item)]
    impl ExternalImpl of ExternalTrait {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self.ownable.assert_only_owner();
            self.erc20._mint(recipient, amount);
        }
        # [external(v0)]
        fn receive(ref self: ContractState,amount:u256){
            let caller =get_caller_address();
            let _balance = self.balances.read(caller);
           
            self.erc20._transfer_from(ref self,get_contract_address() , caller, amount);
            self.balances.write(caller,_balance - amount);
        }
        fn pow<T, +Sub<T>, +Mul<T>, +Div<T>, +Rem<T>, +PartialEq<T>, +Into<u8, T>, +Drop<T>, +Copy<T>>(
            base: T, exp: T
        ) -> T {
            if exp == 0_u8.into() {
                1_u8.into()
            } else if exp == 1_u8.into() {
                base
            } else if exp % 2_u8.into() == 0_u8.into() {
                pow(base * base, exp / 2_u8.into())
            } else {
                base * pow(base * base, exp / 2_u8.into())
            }
        }
        fn assign(ref self: ContractState,wallet_address : ContractAddress, score: u64){
            self.ownable.assert_only_owner();
            let value = pow(2.71,-score);
            let x = value/(value + 10);
            let _balance = self.balances.read(caller);
            self.balances.write(_balance + x);
            self.supply.write(self.supply  - x );
            
        }
    }
}