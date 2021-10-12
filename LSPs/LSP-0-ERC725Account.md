---
lip: 0
title: ERC725Account
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: LSP1, LSP2, ERC165, ERC173, ERC725X, ERC725Y, ERC1271
---


## Simple Summary

This standard describes a version of an [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract, that represents a blockchain account.
 
## Abstract

This standard, defines a blockchain account system to be used by humans, machines, or other smart contracts. It has the ability to **attach information** via [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725y) to itself, **execute, deploy or transfer value** to any other smart contract or EOA via [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725x), is able to **be notified of incoming assets** via the [LSP1-UniversalReceiver](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md) function, and can **verify signatures** via [ERC1271](https://eips.ethereum.org/EIPS/eip-1271).


## Motivation

Using EOAs as accounts makes it hard to reason about the actor behind an address. Using EOAs have multiple disadvantages:
- The public key is the address that mostly holds assets, meaning if the private key leaks or get lost, all asstes are lost
- No information can be easily attached to the address thats readable by interfaces or smart contracts
- Security is not changeable, so proper precautions of securing the private key has to be taken from the generation of the EOA.
- Recevied assets can not be tracked in the state of the account, but can only be retrieved to external block explorers.

To make the usage of Blockchain infrastructures easier we need to use a smart contract account, rather that EOAs directly as account system.
This allows us to:

- Make security upgradeable via a key manager smart contract (e.g. [LSP6 KeyManager](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-6-KeyManager.md))
- Allow any action that an EOA can do, and even add the ability to use `create2` through [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725x)
- Allow the account to be informed and react to receiving assets through [LSP1 UniversalReciever](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md)
- Define a number of key values stores to attach profile and other information through additional standards like [LSP3 UniversalProfile](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-3-UniversalProfile.md)
- Allow signature verification through [ERC1271](https://eips.ethereum.org/EIPS/eip-1271)


## Specification

ERC165 interface id: `0x63cb749b`

_This interface id is the XOR of ERC725Y, ERC725X, LSP1-UniversalReceiver, ERC1271-isValidSignature, to allow detection of ERC725Accounts._

Every contract that supports to the ERC725Account SHOULD implement:

### ERC725Y Keys


#### LSP1UniversalReceiverDelegate

If the account delegates its universal receiver to another smart contract,
this smart contract address MUST be stored under the following key:

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

Contains the methods from [ERC173](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md) (Ownable), [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) (General value and execution), [ERC1271](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md) and [LSP1](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md), 
See the [Interface Cheat Sheet](#interface-cheat-sheet) for details.

### Events

#### ValueReceived

```solidity
event ValueReceived(address indexed sender, uint256 indexed value);
```

MUST be fired when a native token transfer was received.


## Rationale

The ERC725 general key value store allows for the ability to add any kind of information to the the account contract, which allows future use cases. The general execution allows full interactebility with any smart contract or address. And the universal receiver allows the reaction to any future asset.

## Implementation

A implementation can be found in the [ERC725Alliance/ERC725](https://github.com/ERC725Alliance/ERC725/blob/master/implementations/contracts/ERC725/ERC725Account.sol) repository;

ERC725Y JSON Schema `ERC725Account`:

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

interface ILSP0  /* is ERC165 */ {
         
    
    // ERC173
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() external view returns (address);
    
    function transferOwnership(address newOwner) external; // onlyOwner
    
    
    // ERC725Account (ERC725X + ERC725Y)
      
    event Executed(uint256 indexed _operation, address indexed _to, uint256 indexed  _value, bytes _data);
    
    event ValueReceived(address indexed sender, uint256 indexed value);
    
    event ContractCreated(uint256 indexed _operation, address indexed contractAddress, uint256 indexed  _value);
    
    event DataChanged(bytes32 indexed key, bytes value);
    
    
    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external payable returns (bytes memory); // onlyOwner
    
    function getData(bytes32[] memory key) external view returns (bytes[] memory value);
    
    // LSP0 possible keys:
    // LSP1UniversalReceiverDelegate: 0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47
    
    function setData(bytes32[] memory key, bytes[] memory value) external; // onlyOwner
    
    
    // ERC1271
    
    function isValidSignature(bytes32 _hash, bytes memory _signature) external view returns (bytes4 magicValue);
    
    
    // LSP1

    event UniversalReceiver(address indexed from, bytes32 indexed typeId, bytes indexed returnedValue, bytes receivedData);

    function universalReceiver(bytes32 typeId, bytes memory data) external returns (bytes memory);
    
    // IF LSP1UniversalReceiverDelegate key is set
    // THEN calls will be forwarded to the address given (UniversalReceiver even MUST still be fired)
}


```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
