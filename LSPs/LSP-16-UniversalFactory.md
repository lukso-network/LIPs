---
lip: 0
title: UniversalFactory
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2022-11-19
requires: EIP155, EIP104, EIP1167
---


## Simple Summary

This standard defines a universal factory smart contract, that will allow to deploy different types of smart contract using CREATE2 opcode after being deployed with Nick's method in order to produce the same address on different chains.
 
## Abstract

This standard defines several function to be used to deploy different types of contracts using CREATE2 such as normal and initializable contracts. These functions take into consideration the need to initialize in the same transaction for initializable contracts. The initialize data is included in the salt to avoid squatting addresses on different chains.

The same bytecode and salt will produce the same contract address on different chains, if and only if, the UniversalFactory contract was deployed on the same address on each chain, using nick's method in our case.

## Motivation

Having the private key that controls an address makes it possible to control every address on different chains. This will allow people to check your address on a specific chain and send you an asset on the other chain assuming you can control the other address. 

With smart contract based accounts, having an account on a specific address on a chain doesn't mean that the same account is deployed on the same address address and controlled by you on the another chain.  



## Specification

### Methods

#### deployCreate2

```solidity
function deployCreate2(bytes calldata byteCode, bytes32 providedSalt) external payable returns (address);
```

Deploys a contract using CREATE2 with passed `byteCode` and a generated the salt with the msg.value sent to the function.

The salt generated is the keccak256 of an initializable boolean and the `provided salt` packed encoded. The initializable boolean is false in this function.

> `keccak256(abi.encodePacked(initializable, providedSalt))`

MUST emit the [ContractCreated] event after deploying the contract.


#### deployCreate2Init

```solidity
function deployCreate2Init(bytes calldata byteCode, bytes32 providedSalt, bytes calldata initializeCalldata, uint256 constructorMsgValue, uint256 initializeCalldataMsgValue) external payable returns (address);
```

Deploys a contract using CREATE2 with passed `byteCode` and a generated the salt with the `constructorMsgValue` as value. Perform an external call on the contract created with `initializeCalldata` as payload and `initializeCalldataMsgValue` as value.

The salt generated is the keccak256 of an initializable boolean, the initializeCallData, and the provided salt packed encoded. The initializable boolean is true in this function.

> `keccak256(abi.encodePacked(initializable, initializeCallData, providedSalt))`

Requirements:

- msg.value should be equal to the sum of `constructorMsgValue` and `initializeCalldataMsgValue`.
- `initializeCalldata` length should be higher than zero.

MUST emit the [ContractCreated] event after deploying the contract.

#### deployCreate2Proxy

```solidity
function deployCreate2Proxy(address baseContract, bytes32 providedSalt, bytes calldata initializeCalldata) external payable returns (address);
```

Deploys a minimal proxy using CREATE2 with passed `baseContract` and a generated the salt. 
If the initializeCalldata length is not zero, perform an external call on the contract created with `initializeCalldata` as payload and msg.value as value. initializeCalldata length is zero do not perform an external contract and the msg.value should be zero.

If the contract is initializable, the salt generated is the keccak256 of an initializable boolean, the initializeCallData, and the provided salt packed encoded. The initializable boolean is true in this case.

> `keccak256(abi.encodePacked(initializable, initializeCallData, providedSalt))`

If the contract is not initializable, the salt generated is the keccak256 of an initializable boolean and the provided salt packed encoded. The initializable boolean is false in this case.

> `keccak256(abi.encodePacked(initializable, providedSalt))`

Requirements:

- msg.value should be zero if initializeCalldata length is zero.

MUST emit the [ContractCreated] event after deploying the contract.

### Events

#### ContractCreated

```solidity
event ContractCreated(address indexed contractCreated, bytes32 indexed providedSalt, bool indexed initializable, bytes initializeCalldata);
```

MUST be emitted when a contract is created using the UniversalFactory contract.

### [LSP16] UniversalFactory Smart Contract

> This is an exact copy of the code of the [LSP16 UniversalFactory smart contract].

``` solidity

// CODE TO SIT HERE ONCE IT'S FINALIZED

```

### Deployment Transaction

Below is the raw transaction which MUST be used to deploy the smart contract on any chain.

```
0x // RAW TRANSACTION TO SIT HERE ONCE ITS FINALIZED
```

The strings of `16`'s at the end of the transaction are the `r` and `s` of the signature. From this deterministic pattern (generated by a human), anyone can deduce that no one knows the private key for the deployment account.

### Deployment Method

This contract is going to be deployed using the keyless deployment method---also known as [Nick]'s method---which relies on a single-use address. (See [Nick's article] for more details). This method works as follows:

1. Generate a transaction which deploys the contract from a new random account.
  - This transaction MUST NOT use [EIP-155] in order to work on any chain.
  - This transaction MUST have a relatively high gas price to be deployed on any chain. In this case, it is going to be **X (To be Replaced)** Gwei.

2. Set the `v`, `r`, `s` of the transaction signature to the following values:

   ```
   v: 27
   r: 0x1616161616161616161616161616161616161616161616161616161616161616
   s: 0x1616161616161616161616161616161616161616161616161616161616161616
   ```

   Those `r` and `s` values---made of a repeating pattern of `16`'s---are predictable "random numbers" generated deterministically by a human.

3. We recover the sender of this transaction, i.e., the single-use deployment account.

    > Thus we obtain an account that can broadcast that transaction, but we also have the warranty that nobody knows the private key of that account.

4. Send exactly **X (To be Replaced)** native token to this single-use deployment account.

5. Broadcast the deployment transaction.

This operation can be done on any chain, guaranteeing that the contract address is always the same and nobody can use that address with a different contract.


### Single-use UniversalFactory Deployment Account

```
0x // ADDRESS TO SIT HERE ONCE ITS GENERTAED
```

This account is generated by reverse engineering it from its signature for the transaction. This way no one knows the private key, but it is known that it is the valid signer of the deployment transaction.

> To deploy the registry, **X (To be Replaced)** native token MUST be sent to this account *first*.

### Registry Contract Address

```
0x // ADDRESS TO SIT HERE ONCE ITS PREDICTED
```

The contract has the address above for every chain on which it is deployed.

<details>
<summary>Raw metadata of <code>./contracts/ERC820Registry.sol</code></summary>
<pre>
<code></code>
</pre>
</details>

## Rationale

The UniversalFactory is deployed using a keyless deployment method relying on a single-use deployment address to ensure no one controls the factory, thereby ensuring trust and to avoid maintaining a private key that control an address, were this address needs to deploy the same bytecode using the same nonce to produce the same address of the contract on each chain.

Minimal proxy contracts can be deployed with `deployCreate2Init(..)` function but another function was created to lower the barrier of possible errors when interacting with the contract. The clone library will handle deploying and generating the minimal proxy bytecode by passing the address of the base contract.

The initializable boolean was added before the arguments that generate the salt as if it was not used, and we are deploying initializable contracts on another chain, people can use the `deployCreate2(..)` function to deploy the same bytecode with the same salt to get the same address of the contract on another chain without applying the effect of initializing.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP16UniversalFactory/LSP16UniversalFactory.sol) repository.

## Security Consideration

Knowing that deploying a contract using the UniversalFactory will allow to deploy the same contract on other chains with the same address, people should be aware and watch out to use contracts that doesn't have a logic that protect against replay-attacks.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[EIP-155]: <./eip-155.md>
[Nick's article]: <https://medium.com/@weka/how-to-send-ether-to-11-440-people-187e332566b7>
[Nick]: <https://github.com/Arachnid/>
[ContractCreated]: <./LSP-16-UniversalFactory.md#contractcreated>
[LSP16]: <./LSP-16-UniversalFactory.md>
[LSP16 UniversalFactory smart contract]: <https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP16UniversalFactory/LSP16UniversalFactory.sol>

