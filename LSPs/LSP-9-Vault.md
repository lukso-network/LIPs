---
lip: 9
title: Vault
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: ERC165, ERC725X, ERC725Y, LSP1, LSP2, LSP14
---


## Simple Summary

This standard describes a version of an [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract, that represents a blockchain vault.
 
## Abstract

This standard defines a vault that can hold assets and interact with other contracts. It has the ability to **attach information** via [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725y) to itself, **execute, deploy or transfer value** to any other smart contract or EOA via [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725x). It can be **notified of incoming assets** via the [LSP1-UniversalReceiver](./LSP-1-UniversalReceiver.md) function.


## Motivation


## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

**LSP9-Vault** interface id according to [ERC165]: `0x7050cee9`.

_This `bytes4` interface id is calculated as the XOR of the interfaceId of the following standards: ERC725Y, ERC725X, LSP1-UniversalReceiver, LSP14Ownable2Step and LSP17ContractExtension._

Smart contracts implementing the LSP9 standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support the LSP9, ERC725X, ERC725Y, LSP1, LSP14 and LSP17 interface ids.

### Methods

Smart contracts implementing the LSP9 standard MUST implement all of the functions listed below:

#### receive

```solidity
receive() external payable;
```

The receive function allows for receiving native tokens.

MUST emit a [`ValueReceived`](#valuereceived) event when receiving native token.


#### fallback

```solidity
fallback() external payable;
```

This function is part of the LSP17 specification, with additional requirements as follows:

- MUST be payable.
- MUST emit a [`ValueReceived`](#valuereceived) event if value was present.


#### owner

```solidity
function owner() external view returns (address);
```

This function is part of the [LSP14]((./LSP-14-Ownable2Step.md#transferownership)) specification.


#### pendingOwner

```solidity
function pendingOwner() external view returns (address);
```

This function is part of the [LSP14]((./LSP-14-Ownable2Step.md#transferownership)) specification.


#### transferOwnership

```solidity
function transferOwnership(address newPendingOwner) external;
```

This function is part of the [LSP14]((./LSP-14-Ownable2Step.md#transferownership)) specification.

#### acceptOwnership

```solidity
function acceptOwnership() external;
```

This function is part of the [LSP14]((./LSP-14-Ownable2Step.md#transferownership)) specification.


#### renounceOwnership

```solidity
function renounceOwnership() external;
```

This function is part of the [LSP14]((./LSP-14-Ownable2Step.md#transferownership)) specification.


#### execute

```solidity
function execute(uint256 operationType, address target, uint256 value, bytes memory data) external payable returns (bytes memory);
```
This function is part of the [ERC725X](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute) specification, with additional requirements as follows:

- MUST revert when the operation type is DELEGATECALL.

- MUST emit a [`ValueReceived`](#valuereceived) event before external calls or contract creation if the function receives native tokens.


#### execute (Array)

```solidity
function execute(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns (bytes[] memory);
```
This function is part of the [ERC725X](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute-array) specification, with additional requirements as follows:

- MUST revert when the operation type is DELEGATECALL.

- MUST emit a [`ValueReceived`](#valuereceived) event before external calls or contract creation if the function receives native tokens.


#### getData

```solidity
function getData(bytes32 dataKey) external view returns (bytes memory);
```

This function is part of the [ERC725Y](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#getdata) specification.


#### getData

```solidity
function getData(bytes32[] memory dataKeys) external view returns (bytes[] memory);
```

This function is part of the [ERC725Y](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#getdata-array) specification.


#### setData

```solidity
function setData(bytes32 dataKey, bytes memory dataValue) external;
```
This function is part of the [ERC725Y](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#setdata) specification, with additional requirements as follows:

- MUST allow only the owner and the UniversalReceiverDelegate contracts to setData. 

- MUST emit only the first 256 bytes of the dataValue in the DataChanged Event.


#### setData (Array)

```solidity
function setData(bytes32[] memory dataKeys, bytes[] memory dataValues) external;
```

This function is part of the [ERC725Y](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#setdata-array) specification, with additional requirements as follows:

- MUST allow only the owner and the UniversalReceiverDelegate contracts to setData. 

- MUST emit only the first 256 bytes of the dataValue in the DataChanged Event.


#### universalReceiver

```solidity
function universalReceiver(bytes32 typeId, bytes memory receivedData) external payable returns (bytes memory);
```

This function is part of the [LSP1](./LSP-1-UniversalReceiver.md) specification, with additional requirements as follows:

- MUST emit a [`ValueReceived`](#valuereceived) event before external calls if the function receives native tokens.

- If an `address` is stored under the data key attached below and and this address is a contract that supports the [LSP1UniversalReceiverDelegate](#) interface id, forwards the call to the [`universalReceiverDelegate(..)`](#) function of the **UniversalReceiverDelegate** contract. If there is no address stored under this data key, execution continues normally. 

```json
{
  "name": "LSP1UniversalReceiverDelegate",
  "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
  "keyType": "Singleton",
  "valueType": "address",
  "valueContent": "Address"
}
```

- If an `address` is stored under the data key attached below and and this address is a contract that supports the [LSP1UniversalReceiverDelegate](#) interface id, forwards the call to the [`universalReceiverDelegate(..)`](#)` function of the **MappedUniversalReceiverDelegate** contract. If there is no address stored under this data key, execution continues normally. 
```json
{
  "name": "LSP1UniversalReceiverDelegate:<bytes32>",
  "key": "0x0cfc51aec37c55a4d0b10000<bytes32>",
  "keyType": "Mapping",
  "valueType": "address",
  "valueContent": "Address"
}
```

> <bytes32\> is the `typeId` passed to the `universalReceiver(..)` function. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.
- MUST return the returned value of both UniversalReceiverDelegate and MappedUniversalReceiverDelegate abi-encoded as bytes.

- MUST emit a [UniversalReceiver](./LSP-1-UniversalReceiver.md#events) event if the function was successful.

### Events

#### ValueReceived

```solidity
event ValueReceived(address indexed sender, uint256 indexed value);
```

MUST be emitted when a native token transfer was received.

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

    
    // ERC725X

    event Executed(uint256 indexed operation, address indexed to, uint256 indexed  value, bytes4 selector);

    event ContractCreated(uint256 indexed operation, address indexed contractAddress, uint256 indexed value);
    
    
    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external payable returns (bytes memory); // onlyOwner
    
    
    // ERC725Y

    event DataChanged(bytes32 indexed dataKey, bytes dataValue);


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


    // LSP14

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event RenounceOwnershipInitiated();

    event OwnershipRenounced();


    function owner() external view returns (address);
    
    function pendingOwner() external view returns (address);

    function transferOwnership(address newOwner) external; // onlyOwner

    function acceptOwnership() external;
    
    function renounceOwnership() external; // onlyOwner

}


```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[LSP1-UniversalReceiver]: <./LSP-1-UniversalReceiver.md>
[LSP2-ERC725YJSONSchema]: <./LSP-2-ERC725YJSONSchema.md>
