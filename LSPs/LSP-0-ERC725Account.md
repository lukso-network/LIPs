---
lip: 0
title: ERC725Account
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: ERC165, ERC725X, ERC725Y, ERC1271, LSP1, LSP2, LSP14
---


## Simple Summary

This standard describes a version of an [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract, that represents a blockchain account.
 
## Abstract

This standard, defines a blockchain account system to be used by humans, machines, or other smart contracts. It has the ability to **attach information** via [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725y) to itself, **execute, deploy or transfer value** to any other smart contract or EOA via [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725x), is able to **be notified and react on incoming assets and information** via the [LSP1-UniversalReceiver](./LSP-1-UniversalReceiver.md) function, and can **verify signatures** via [ERC1271](https://eips.ethereum.org/EIPS/eip-1271).


## Motivation

Using EOAs as accounts makes it hard to reason about the actor behind an address. Using EOAs have multiple disadvantages:
- The public key is the address that mostly holds assets, meaning if the private key leaks or get lost, all asstes are lost.
- No information can be easily attached to the address thats readable by interfaces or smart contracts.
- Security is not changeable, so proper precautions of securing the private key has to be taken from the generation of the EOA.
- Recevied assets can not be tracked in the state of the account, but can only be retrieved to external block explorers.

To make the usage of Blockchain infrastructures easier we need to use a smart contract account, rather that EOAs directly as account system.
This allows us to:

- Perform any action that an EOA can do, and even add the ability to use `staticcall`, `delegatecall` and `create2` through [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725x).
- Add information continuously to the account in the form of data key-value pairs through [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725y).
- Provide a secure ownership management and transfer through [LSP14].
- Make security upgradeable with owning the account via a key manager smart contract (e.g. [LSP6 KeyManager](./LSP-6-KeyManager.md))
- Allow the account to be informed and react to incoming and outgoing calls such as receiving assets through [LSP1 UniversalReceiver](./LSP-1-UniversalReceiver.md)
- Verify owner's signature through [ERC1271](https://eips.ethereum.org/EIPS/eip-1271).
- Define a number of data key-values pairs to attach profile and other information through additional standards like [LSP3 UniversalProfile-Metadata](./LSP-3-UniversalProfile-Metadata.md)
- can execute any smart contract and deploy smart contracts
- is highly extensible though additional standardisation of the key/value data stored.


## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

**LSP0-ERC725Account** interface id according to [ERC165]: `0xdca05671`.

_This `bytes4` interface id is calculated as the XOR of the function selectors from the following interface standards: ERC725Y, ERC725X, LSP1-UniversalReceiver, ERC1271-isValidSignature and LSP14Ownable2Step._

Smart contracts implementing the LSP0 standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support the LSP0, ERC725X, ERC725Y, ERC1271, LSP1 and LSP14 interface ids.

### Methods

Smart contracts implementing the LSP0 standard MUST implement all of the functions listed below:

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

The fallback function allows for receiving native tokens, as well as arbitrary calldata. The reasoning is that it allows for Graffiti with transactions, or protocols to be built for offchain parsing.

MUST emit a [`ValueReceived`](#valuereceived) event if value was present.


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

This function is part of the [LSP14]((./LSP-14-Ownable2Step.md#transferownership)) specification, with additional requirements as follows:

- The `newPendingOwner` MUST NOT be the contract itself `address(this)`.

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
This function is part of the [ERC725X](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute) specification with additional logic as follows:

MUST emit a [`ValueReceived`](#valuereceived) event before external calls or contract creation if the function receives native tokens.


#### execute (Array)

```solidity
function execute(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns (bytes[] memory);
```
This function is part of the [ERC725X](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute-array) specification with additional requirements as follows:

MUST emit a [`ValueReceived`](#valuereceived) event before external calls or contract creation if the function receives native tokens.


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
This function is part of the [ERC725Y](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#setdata) specification.


#### setData (Array)

```solidity
function setData(bytes32[] memory dataKeys, bytes[] memory dataValues) external;
```

This function is part of the [ERC725Y](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#setdata-array) specification.


#### isValidSignature

```solidity
function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4);
```

This function is part of the [ERC1271](https://eips.ethereum.org/EIPS/eip-1271) specification.

Checks if the signature is valid for the hash provided. 

When the owner is an EOA, the function MUST return the magic value if the address recovered from the hash and the signature is the owner of the contract, and the failure value otherwise. 

When the owner is a contract, the function MUST check whether the owner contract supports ERC1271 interface id through ERC165, if yes it calls `isValidSignature(..)` function on the owner contract and returns its value. If the owner does not support ERC1271 interface id or the function does not exist on the owner, the function MUST return the failure value.


#### universalReceiver

```solidity
function universalReceiver(bytes32 typeId, bytes memory receivedData) external payable returns (bytes memory);
```

This function is part of the [LSP1](./LSP-1-UniversalReceiver.md) specification.

Forwards the call to the `universalReceiverDelegate(..)` function of the UniversalReceiverDelegate contract and the MappedUniversalReceiverDelegate relevant for the typeId provided as argument.

If an `address` is stored under the data key attached below and and this address is a contract that supports the [LSP1UniversalReceiverDelegate](#) interface id, forwards the call to the `universalReceiverDelegate(..)` function of the **UniversalReceiverDelegate** contract. If there is no address stored under this data key, execution continues normally. 

```json
{
  "name": "LSP1UniversalReceiverDelegate",
  "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
  "keyType": "Singleton",
  "valueType": "address",
  "valueContent": "Address"
}
```

If an `address` is stored under the data key attached below and and this address is a contract that supports the [LSP1UniversalReceiverDelegate](#) interface id, forwards the call to the `universalReceiverDelegate(..)` function of the **MappedUniversalReceiverDelegate** contract. If there is no address stored under this data key, execution continues normally. 

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

This function MUST return the returned value of both UniversalReceiverDelegate and MappedUniversalReceiverDelegate abi-encoded as bytes. 

MUST emit a [UniversalReceiver](./LSP-1-UniversalReceiver.md#events) event if the function was successful.

MUST emit a [`ValueReceived`](#valuereceived) event before external calls if the function receives native tokens.


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

        
    // ERC1271
    
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
    
    
    // LSP0 (ERC725Account)
      
    event ValueReceived(address indexed sender, uint256 indexed value);

    fallback() external payable;
    

    // LSP1

    event UniversalReceiver(address indexed from, uint256 indexed value, bytes32 indexed typeId, bytes receivedData, bytes returnedValue);
    

    function universalReceiver(bytes32 typeId, bytes memory data) external payable returns (bytes memory);

    
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
[LSP14]: <./LSP-14-Ownable2Step.md>
