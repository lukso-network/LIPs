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

### TODO

## Specification

[ERC165] interface id: `0x5e38b596`

_This interface id is the XOR of ERC725Y, ERC725X, LSP1-UniversalReceiver, to allow detection of Vaults._

Every contract that supports the LSP9 standard SHOULD implement:

### ERC725Y Data Keys


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

### Methods

Contains the methods from [ERC173](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md) (Ownable), [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) (General value and execution) and [LSP1](./LSP-1-UniversalReceiver.md), 
See the [Interface Cheat Sheet](#interface-cheat-sheet) for details.

### Events

#### ValueReceived

```solidity
event ValueReceived(address indexed sender, uint256 indexed value);
```

MUST be emitted when a native token transfer was received.


## Rationale

The ERC725Y general data key value store allows for the ability to add any kind of information to the the contract, which allows future use cases. The general execution allows full interactability with any smart contract or address. And the universal receiver allows the reaction to any future asset.

## Implementation

An implementation can be found on the [lsp-universalprofile-smart-contracts](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/tree/main/contracts/LSP9Vault) repository;

ERC725Y JSON Schema:

```json
[
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

    event ValueReceived(address indexed sender, uint256 indexed value);
         
    
    // ERC173
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() external view returns (address);
    
    function transferOwnership(address newOwner) external; // onlyOwner

    
    // ERC725
      
    event Executed(uint256 indexed _operation, address indexed _to, uint256 indexed  _value, bytes _data);
        
    event ContractCreated(uint256 indexed _operation, address indexed contractAddress, uint256 indexed  _value);
    
    event DataChanged(bytes32 indexed dataKey, bytes value);
    
    
    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external payable returns (bytes memory); // onlyOwner

    function getData(bytes32 dataKey) external view returns (bytes memory value);
    
    function setData(bytes32 dataKey, bytes memory value) external; // onlyAllowed (UniversalReceiverDelegate and Owner)
    
    function getData(bytes32[] memory dataKeys) external view returns (bytes[] memory values);
    
    function setData(bytes32[] memory dataKeys, bytes[] memory values) external; // onlyAllowed (UniversalReceiverDelegate and Owner)
        
    // LSP0 possible data keys:
    // LSP1UniversalReceiverDelegate: 0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47
    
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