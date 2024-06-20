// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts for Cairo ^0.13.0

#[starknet::contract]
pub mod DevDock {
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
    fn constructor(ref self: ContractState) {
        self.erc20.initializer("STARK", "STRK");
        // self.ownable.initializer(owner);
        self.ownable.initializer(get_caller_address());
        self.mint(get_contract_address(),1000000000000000000000);//1*10^21
        // self.supply.write = 1000000000000000000000;//1*10^21
        self.supply.write(1000000000000000000000);//1*10^21
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
           
            self.erc20.transfer_from(get_contract_address() , caller, amount);
            self.balances.write(caller,_balance - amount);
        }
    
        
        fn assign(ref self: ContractState,wallet_address : ContractAddress, score: u8){
            self.ownable.assert_only_owner();
            let value = pow(2,score);
            let x = value/(value + 10);
            let _balance = self.balances.read(wallet_address);
            self.balances.write(wallet_address, _balance + x);
            self.supply.write(self.supply.read()- x );
            
        }
    }
    fn pow(x: u256, n: u8) -> u256 {
        let y = x;
        if n == 0 {
            return 1;
        }
        if n == 1 {
            return x;
        }
        let double = pow(y * x, n / 2);
        if (n % 2) == 1 {
            return x * double;
        }
        return double;
    }
}