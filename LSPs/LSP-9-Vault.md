---
lip: 9
title: Vault
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: LSP1, LSP2, ERC165, ERC173, ERC725X, ERC725Y
---


## Simple Summary

This standard describes a version of an [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract, that represents a blockchain vault.
 
## Abstract

This standard defines a vault that can hold assets and interact with other contracts. It has the ability to **attach information** via [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725y) to itself, **execute, deploy or transfer value** to any other smart contract or EOA via [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725x). It can be **notified of incoming assets** via the [LSP1-UniversalReceiver](./LSP-1-UniversalReceiver.md) function.


## Motivation


## Specification

[ERC165] interface id: `0xfd4d5c50`

_This interface id can be used to detect Vault contracts._

_This `bytes4` interface id is calculated as the XOR of the function selectors from the following interface standards: ERC725Y, ERC725X, LSP1-UniversalReceiver and ClaimOwnership._

### ERC725Y Data Keys

Every contract that supports the LSP9 standard SHOULD implement:

#### SupportedStandards:LSP9Vault

The supported standard SHOULD be `LSP9Vault`

```json
{
    "name": "SupportedStandards:LSP9Vault",
    "key": "0xeafec4d89fa9619884b600007c0334a14085fefa8b51ae5a40895018882bdb90",
    "keyType": "Mapping",
    "valueType": "bytes4",
    "valueContent": "0x7c0334a1"
}
```

#### LSP1UniversalReceiverDelegate

If the contract delegates its universal receiver to another smart contract,
this smart contract address MUST be stored under the following data key:

```json
{
    "name": "LSP1UniversalReceiverDelegate",
    "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
    "keyType": "Singleton",
    "valueContent": "Address",
    "valueType": "address"
}
```

Check [LSP1-UniversalReceiver] and [LSP2-ERC725YJSONSchema] for more information.

### Methods

See the [Interface Cheat Sheet](#interface-cheat-sheet) for details.

**Contains the methods from** [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#specification) (General data key-value store, and general executor) with overriding:

#### execute

```solidity
function execute(uint256 operationType, address to, uint256 value, bytes memory data) public payable returns(bytes memory)
```

Executes a call on any other smart contracts, transfers the blockchains native token, or deploys a new smart contract.
MUST only be called by the current owner of the contract.

The following `operationType` MUST exist:

- `0` for `CALL`
- `1` for `CREATE`
- `2` for `CREATE2`
- `3` for `STATICCALL`

The following `operationType` COULD exist:

- `4` for `DELEGATECALL` - **NOTE** This is a potentially dangerous operation

Check [`execute(...)`](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute) function of [ERC725X](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#erc725x) for more details.

**Contains the methods from:**

- [LSP1](./LSP-1-UniversalReceiver.md#specification)
- Claim Ownership, a modified version of [ERC173](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md#specification) (Ownable). *See below for details*

#### owner

```solidity
function owner() external view returns (address);
```

Returns the `address` of the current contract owner.

#### pendingOwner

```solidity
function pendingOwner() external view returns (address);
```

Return the `address` of the pending owner, of a ownership transfer, that was initiated with `transferOwnership(address)`. MUST be `address(0)` if no ownership transfer is in progress.

MUST be set when transferring ownership of the contract via `transferOwnership(address)` to a new `address`.

SHOULD be cleared once the [`pendingOwner`](#pendingowner) has claim ownership of the contract.


#### transferOwnership

```solidity
function transferOwnership(address newOwner) external;
```

Sets the `newOwner` as `pendingOwner`.

MUST be called only by `owner()`.

The `newOwner` MUST NOT be the contract itself `address(this)`

#### claimOwnership

```solidity
function claimOwnership() external;
```

Allow an `address` to become the new owner of the contract. MUST only be called by the pending owner.

MUST be called after `transferOwnership` by the current `pendingOwner` to finalize the ownership transfer.

MUST emit a [`OwnershipTransferred`](https://eips.ethereum.org/EIPS/eip-173#specification) event once the new owner has claimed ownership of the contract.

#### renounceOwnership

```solidity
function renounceOwnership() public;
```

Leaves the contract without an owner. Once ownership of the contract is renounced, it MUST NOT be possible to call the functions restricted to the owner only.

Since renouncing ownership is a sensitive operation, it SHOULD be done as a two step process by calling  `renounceOwnership(..)` twice. First to initiate the process, second as a confirmation.

*Requirements:*

- MUST be called only by the `owner()` only.
- The second call MUST happen AFTER the delay of 100 blocks and within the next 100 blocks from the first `renounceOwnership(..)` call.
- If the 200 block has passed, the `renounceOwnership(..)` call phase SHOULD reset the process, and a new one will be initated.

MUST emit a [`RenounceOwnershipInitiated`](#renounceownershipinitiated) event on the first `renounceOwnership(..)` call.
MUST emit [`OwnershipTransferred`](https://eips.ethereum.org/EIPS/eip-173#specification) event after successfully renouncing the ownership.

### Events

#### ValueReceived

```solidity
event ValueReceived(address indexed sender, uint256 indexed value);
```

MUST be emitted when a native token transfer was received.

#### RenounceOwnershipInitiated

```solidity
event RenounceOwnershipInitiated();
```

MUST be emitted when renouncing ownership of the contract is initiated.

### Hooks

Every contract that supports the LSP9 standard SHOULD implement these hooks:

#### _notifyVaultSender

Calls the `universalReceiver(..)` function on the old owner address when claiming ownership by the new owner, if the old owner address supports LSP1 InterfaceID, with the parameters below:

- `typeId`: keccak256('LSP9VaultSender')
- `data`: TBD

#### _notifyVaultReceiver

Calls the `universalReceiver(..)` function on the new owner address after claiming ownership, if it supports LSP1 InterfaceID, with the parameters below:

- `typeId`: keccak256('LSP9VaultRecipient')
- `data`: TBD


## Rationale

The ERC725Y general data key value store allows for the ability to add any kind of information to the contract, which allows future use cases. The general execution allows full interactability with any smart contract or address. And the universal receiver allows the reaction to any future asset.

## Implementation

An implementation can be found on the [lsp-universalprofile-smart-contracts](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/tree/main/contracts/LSP9Vault) repository;

ERC725Y JSON Schema:

```json
[
    {
        "name": "SupportedStandards:LSP9Vault",
        "key": "0xeafec4d89fa9619884b600007c0334a14085fefa8b51ae5a40895018882bdb90",
        "keyType": "Mapping",
        "valueType": "bytes4",
        "valueContent": "0x7c0334a1"
    },
    {
        "name": "LSP1UniversalReceiverDelegate",
        "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
        "keyType": "Singleton",
        "valueContent": "Address",
        "valueType": "address"
    }
]
```

## Interface Cheat Sheet

```solidity

interface ILSP9  /* is ERC165 */ {
       
    
    // Modified ERC173 (ClaimOwnership)
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() external view returns (address);
    
    function pendingOwner() external view returns (address);

    function transferOwnership(address newOwner) external; // onlyOwner

    function claimOwnership() external;
    
    function renounceOwnership() external; // onlyOwner
        

    
    // ERC725X

    event Executed(uint256 indexed operation, address indexed to, uint256 indexed  value, bytes4 selector);

    event ContractCreated(uint256 indexed operation, address indexed contractAddress, uint256 indexed value);
    
    
    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external payable returns (bytes memory); // onlyOwner
    
    
    // ERC725Y

    event DataChanged(bytes32 indexed dataKey);


    function getData(bytes32 dataKey) external view returns (bytes memory dataValue);
    
    function setData(bytes32 dataKey, bytes memory dataValue) external; // onlyOwner

    function getData(bytes32[] memory dataKeys) external view returns (bytes[] memory dataValues);

    function setData(bytes32[] memory dataKeys, bytes[] memory dataValues) external; // onlyOwner
        

    // LSP1

    event UniversalReceiver(address indexed from, uint256 indexed value, bytes32 indexed typeId, bytes receivedData, bytes returnedValue);
    

    function universalReceiver(bytes32 typeId, bytes memory data) external payable returns (bytes memory);


    // LSP9 
      
    event ValueReceived(address indexed sender, uint256 indexed value);

    fallback() external payable;

}


```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[LSP1-UniversalReceiver]: <./LSP-1-UniversalReceiver.md>
[LSP2-ERC725YJSONSchema]: <./LSP-2-ERC725YJSONSchema.md>
