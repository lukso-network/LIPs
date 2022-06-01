---
lip: 0
title: ERC725Account
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: ERC165, ERC173, ERC1271, ERC725X, ERC725Y, LSP1, LSP2
---


## Simple Summary

This standard describes a version of an [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract, that represents a blockchain account.
 
## Abstract

This standard, defines a blockchain account system to be used by humans, machines, or other smart contracts. It has the ability to **attach information** via [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725y) to itself, **execute, deploy or transfer value** to any other smart contract or EOA via [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725x), is able to **be notified of incoming assets** via the [LSP1-UniversalReceiver](./LSP-1-UniversalReceiver.md) function, and can **verify signatures** via [ERC1271](https://eips.ethereum.org/EIPS/eip-1271).


## Motivation

Using EOAs as accounts makes it hard to reason about the actor behind an address. Using EOAs have multiple disadvantages:
- The public key is the address that mostly holds assets, meaning if the private key leaks or get lost, all asstes are lost
- No information can be easily attached to the address thats readable by interfaces or smart contracts
- Security is not changeable, so proper precautions of securing the private key has to be taken from the generation of the EOA.
- Recevied assets can not be tracked in the state of the account, but can only be retrieved to external block explorers.

To make the usage of Blockchain infrastructures easier we need to use a smart contract account, rather that EOAs directly as account system.
This allows us to:

- Make security upgradeable via a key manager smart contract (e.g. [LSP6 KeyManager](./LSP-6-KeyManager.md))
- Allow any action that an EOA can do, and even add the ability to use `create2` through [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725x)
- Allow the account to be informed and react to receiving assets through [LSP1 UniversalReceiver](./LSP-1-UniversalReceiver.md)
- Define a number of data key-values pairs to attach profile and other information through additional standards like [LSP3 UniversalProfile-Metadata](./LSP-3-UniversalProfile-Metadata.md)
- Allow signature verification through [ERC1271](https://eips.ethereum.org/EIPS/eip-1271)


## Specification

[ERC165] interface id: `0x9a3bfe88`

_This interface id can be used to detect ERC725Account contracts._

_This `bytes4` interface id is calculated as the XOR of the function selectors from the following interface standards: ERC725Y, ERC725X, LSP1-UniversalReceiver, ERC1271-isValidSignature and ClaimOwnership._

Every contract that supports the LSP0 standard (ERC725Account) SHOULD implement:

### ERC725Y Data Keys


#### LSP1UniversalReceiverDelegate

If the account delegates its universal receiver to another smart contract,
this smart contract address MUST be stored under the following data key:

```json
{
    "name": "LSP1UniversalReceiverDelegate",
    "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
    "keyType": "Singleton",
    "valueType": "address",
    "valueContent": "Address"
}
```

### Methods

See the [Interface Cheat Sheet](#interface-cheat-sheet) for details.

Contains the methods from:
- [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#specification) (General data key-value store, and general executor)
- [ERC1271](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md#specification)
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

Return the `address` of the pending owner, of a ownership transfer, that was initiated with `transferOwnership(address)`. MUST be `0x0000000000000000000000000000000000000000` if no ownership transfer is in progress.

MUST be set when transferring ownership of the contract via `transferOwnership(address)` to a new `address`.

SHOULD be cleared once the [`pendingOwner`](#pendingowner) has claim ownership of the contract.


#### transferOwnership

```solidity
function transferOwnership(address newOwner) external;
```

Transfers ownership of the contract to a `newOwner`.

MUST set the `newOwner` as the `pendingOwner`.

#### claimOwnership

```solidity
function claimOwnership() external;
```

Allow an `address` to become the new owner of the contract. MUST only be called by the pending owner.

MUST be called after `transferOwnership` by the current `pendingOwner` to finalize the ownership transfer.

MUST emit a [`OwnershipTransferred`](https://eips.ethereum.org/EIPS/eip-173#specification) event once the new owner has claimed ownership of the contract.


### Events

#### ValueReceived

```solidity
event ValueReceived(address indexed sender, uint256 indexed value);
```

MUST be emitted when a native token transfer was received.


## Rationale

The ERC725Y general data key-value store allows for the ability to add any kind of information to the the account contract, which allows future use cases. The general executor allows full interactability with any smart contract or address. And the universal receiver allows reacting to any future asset received.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP0ERC725Account/LSP0ERC725AccountCore.sol) repository.

ERC725Y JSON Schema `ERC725Account`:

```json
[
    {
        "name": "LSP1UniversalReceiverDelegate",
        "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
        "keyType": "Singleton",
        "valueType": "address",
        "valueContent": "Address"
    }
]
```

## Interface Cheat Sheet

```solidity
interface ILSP0  /* is ERC165 */ {
         
    
    // Modified ERC173 (ClaimOwnership)
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() external view returns (address);
    
    function pendingOwner() external view returns (address);

    function transferOwnership(address newOwner) external; // onlyOwner

    function claimOwnership() external;
    
    function renounceOwnership() external; // onlyOwner
        


    // ERC1271
    
    function isValidSignature(bytes32 _hash, bytes memory _signature) external view returns (bytes4 magicValue);
    
    
    // ERC725X

    event Executed(uint256 indexed _operation, address indexed _to, uint256 indexed  _value, bytes4 _selector);

    event ContractCreated(uint256 indexed _operation, address indexed contractAddress, uint256 indexed  _value);
    
    
    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external payable returns (bytes memory); // onlyOwner
    
    
    // ERC725Y

    event DataChanged(bytes32 indexed dataKey);


    function getData(bytes32 dataKey) external view returns (bytes memory value);
    
    function setData(bytes32 dataKey, bytes memory value) external; // onlyOwner

    function getData(bytes32[] memory dataKeys) external view returns (bytes[] memory values);

    function setData(bytes32[] memory dataKeys, bytes[] memory values) external; // onlyOwner
    
    
    // LSP0 possible data keys:
    // LSP1UniversalReceiverDelegate: 0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47

    
    // LSP0 (ERC725Account)
      
    event ValueReceived(address indexed sender, uint256 indexed value);
    

    // LSP1

    event UniversalReceiver(address indexed from, bytes32 indexed typeId, bytes indexed returnedValue, bytes receivedData);
    

    function universalReceiver(bytes32 typeId, bytes memory data) external returns (bytes memory);
    
    // IF LSP1UniversalReceiverDelegate data key is set
    // THEN calls will be forwarded to the address given (UniversalReceiver even MUST still be fired)

}


```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>