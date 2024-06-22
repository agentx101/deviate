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
        trainer_balances: LegacyMap<ContractAddress, u256>,
        supply: u256,
        value: u8
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
    fn constructor(ref self: ContractState,owner: ContractAddress ) {
        self.erc20.initializer("STARK", "STRK");
        // let owner_address : ContractAddress = 0x05bf20a4CfcEF4918f3Bb4E53ea36a534Cd65Cbc88cbD13858fd9B9393b0E74B;
        self.ownable.initializer(owner);
        // self.ownable.initializer(get_caller_address()); //I commented out this line because here get_caller_address() is the contract_address itself because contract is calling it's constructor, not the deployer caller_address,so we need to explicityly say who is owner
        // self.mint(get_contract_address(),10000000000000000000000);//1*10^22
        self.erc20._mint(get_contract_address(), 10000000000000000000000); //1*10^22
        // self.supply.write = 1000000000000000000000;//1*10^21
        self.supply.write(10000000000000000000000);//1*10^22
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
            let _balance = self.trainer_balances.read(caller);
           
            self.erc20.transfer_from(get_contract_address() , caller, amount);
            self.trainer_balances.write(caller,_balance - amount);
        }
        # [external(v0)]
        fn receiveAll(ref self: ContractState){
            let caller =get_caller_address();
            let _balance = self.trainer_balances.read(caller);
           
            self.erc20.transfer_from(get_contract_address() , caller, _balance);
            self.trainer_balances.write(caller,0);
        }
    
        # [external(v0)]
        fn assign(ref self: ContractState,wallet_address : ContractAddress, score: u8){
            self.ownable.assert_only_owner();
            let value = pow(2,score);
            let x = 1000*value/(value + 10);
            let _balance = self.trainer_balances.read(wallet_address);
            self.trainer_balances.write(wallet_address, _balance + x);
            self.supply.write(self.supply.read()- x );
            
        }
        // # [external(v0)]
        // fn get_balance(self: @ContractState)-> u256 {
        //     let caller = get_caller_address();
        //     let balance = self.balances.read(caller);
        //     return balance;
        // }
        # [external(v0)]
        fn get_balance(self: @ContractState,caller:ContractAddress)-> u256 {
            // let caller = get_caller_address();
            let balance = self.trainer_balances.read(caller);
            return balance;
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