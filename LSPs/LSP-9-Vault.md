---
lip: 9
title: Vault
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: ERC165, ERC725X, ERC725Y, LSP1, LSP2, LSP14, LSP17
---


## Simple Summary

This standard describes a version of an [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract, that represents a blockchain vault.
 
## Abstract

This standard defines a vault that can hold assets and interact with other contracts. It has the ability to **attach information** via [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725y) to itself, **execute, deploy or transfer value** to any other smart contract or EOA via [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md#erc725x). It can be **notified of incoming assets** via the [LSP1-UniversalReceiver](./LSP-1-UniversalReceiver.md) function.


## Motivation


## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

**LSP9-Vault** interface id according to [ERC165]: `0x7050cee9`.

_This `bytes4` interface id is calculated as the XOR of the interfaceId of the following standards: ERC725Y, ERC725X, LSP1-UniversalReceiver, LSP14Ownable2Step and LSP17Extendable._

Smart contracts implementing the LSP9 standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support the LSP9, ERC725X, ERC725Y, LSP1, LSP14 and LSP17Extendable interface ids.

### Methods

Smart contracts implementing the LSP9 standard MUST implement all of the functions listed below:

#### receive

```solidity
receive() external payable;
```

The receive function allows for receiving native tokens.

MUST emit a [`ValueReceived`] event when receiving native token.


#### fallback

```solidity
fallback() external payable;
```

This function is part of the [LSP17] specification, with additional requirements as follows:

- MUST be payable.
- MUST emit a [`ValueReceived`] event if value was present.
- MUST return if the data sent to the contract is less than 4 bytes in length or if the first 4 bytes of the data are equal to 0.
- MUST check for address of the extension under the following ERC725Y Data Key:

```json
{
    "name": "LSP17Extension:<bytes4>",
    "key": "0xcee78b4094da860110960000<bytes4>",
    "keyType": "Mapping",
    "valueType": "address",
    "valueContent": "Address"
}
```

> <bytes4\> is the `functionSelector` called on the vault contract. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.


#### owner

```solidity
function owner() external view returns (address);
```

This function is part of the [LSP14] specification.


#### pendingOwner

```solidity
function pendingOwner() external view returns (address);
```

This function is part of the [LSP14] specification.


#### transferOwnership

```solidity
function transferOwnership(address newPendingOwner) external;
```

This function is part of the [LSP14] specification.

#### acceptOwnership

```solidity
function acceptOwnership() external;
```

This function is part of the [LSP14] specification.


#### renounceOwnership

```solidity
function renounceOwnership() external;
```

This function is part of the [LSP14] specification.


#### execute

```solidity
function execute(uint256 operationType, address target, uint256 value, bytes memory data) external payable returns (bytes memory);
```
This function is part of the [ERC725X] specification, with additional requirements as follows:

- MUST revert when the operation type is DELEGATECALL.

- MUST emit a [`ValueReceived`] event before external calls or contract creation if the function receives native tokens.


#### execute (Array)

```solidity
function execute(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns (bytes[] memory);
```
This function is part of the [ERC725X] specification, with additional requirements as follows:

- MUST revert when one of the operations type is DELEGATECALL.

- MUST emit a [`ValueReceived`] event before external calls or contract creation if the function receives native tokens.


#### getData

```solidity
function getData(bytes32 dataKey) external view returns (bytes memory);
```

This function is part of the [ERC725Y] specification.


#### getData

```solidity
function getData(bytes32[] memory dataKeys) external view returns (bytes[] memory);
```

This function is part of the [ERC725Y] specification.


#### setData

```solidity
function setData(bytes32 dataKey, bytes memory dataValue) external;
```
This function is part of the [ERC725Y] specification, with additional requirements as follows:

- MUST allow the owner to setData. 

- MUST allow the Universal Receiver Delegate contracts to setData only in reentrant calls of the `universalReceiver(..)` function of the LSP9Vault. 

- MUST emit only the first 256 bytes of the dataValue parameter in the [DataChanged] event.


#### setData (Array)

```solidity
function setData(bytes32[] memory dataKeys, bytes[] memory dataValues) external;
```

This function is part of the [ERC725Y] specification, with additional requirements as follows:

- MUST allow the owner to setData. 

- MUST allow the Universal Receiver Delegate contracts to setData only in reentrant calls of the `universalReceiver(..)` function of the LSP9Vault. 

- MUST emit only the first 256 bytes of the dataValue parameter in the [DataChanged] event.


#### universalReceiver

```solidity
function universalReceiver(bytes32 typeId, bytes memory receivedData) external payable returns (bytes memory);
```

This function is part of the [LSP1] specification, with additional requirements as follows:

- MUST emit a [`ValueReceived`] event before external calls if the function receives native tokens.

- If an `address` is stored under the data key attached below and and this address is a contract that supports the [LSP1UniversalReceiver interface id], forwards the call to the [`universalReceiver(bytes32,bytes)`] function on the address retreived. If there is no address stored under this data key, execution continues normally. 

The `msg.data` is appended with the caller address as bytes20 and the `msg.value` received as bytes32 before calling the external contract, allowing the receiving contract to know the initial caller and the value sent.

```json
{
  "name": "LSP1UniversalReceiverDelegate",
  "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
  "keyType": "Singleton",
  "valueType": "address",
  "valueContent": "Address"
}
```

- If an `address` is stored under the data key attached below and and this address is a contract that supports the [LSP1UniversalReceiver interface id], forwards the call to the [`universalReceiver(bytes32,bytes)`] function on the address retreived. If there is no address stored under this data key, execution continues normally. 

The `msg.data` is appended with the caller address as bytes20 and the `msg.value` received as bytes32 before calling the external contract, allowing the receiving contract to know the initial caller and the value sent.

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

- MUST return the returned value of the `universalReceiver(bytes32,bytes)` function on both retreived contract abi-encoded as bytes. If there is no addresses stored under the data keys above or the call was not forwarded to them, the return value is the two empty bytes abi-encoded as bytes. 

- MUST emit a [UniversalReceiver] event if the function was successful.

### Events

#### ValueReceived

```solidity
event ValueReceived(address indexed sender, uint256 indexed value);
```

MUST be emitted when a native token transfer was received.


### ERC725Y Data Keys


#### LSP1UniversalReceiverDelegate

```json
{
    "name": "LSP1UniversalReceiverDelegate",
    "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
    "keyType": "Singleton",
    "valueType": "address",
    "valueContent": "Address"
}
```

If the vault delegates its universal receiver functionality to another smart contract, this smart contract address MUST be stored under the data key attached above. This call to this contract is performed when the `universalReceiver(bytes32,bytes)` function of the vault is called and can react on the whole call regardless of typeId. 

Check [LSP1-UniversalReceiver] and [LSP2-ERC725YJSONSchema] for more information.

#### Mapped LSP1UniversalReceiverDelegate

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

If the vault delegates its universal receiver functionality to another smart contract, this smart contract address MUST be stored under the data key attached above. This call to this contract is performed when the `universalReceiver(bytes32,bytes)` function of the vault is called with a specific typeId that it can react on. 

Check [LSP1-UniversalReceiver] and [LSP2-ERC725YJSONSchema] for more information.

#### LSP17Extension

```json
{
    "name": "LSP17Extension:<bytes4>",
    "key": "0xcee78b4094da860110960000<bytes4>",
    "keyType": "Mapping",
    "valueType": "address",
    "valueContent": "Address"
}
```

> <bytes4\> is the `functionSelector` called on the vault contract. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

If there is a function called on the vault and the function does not exist, the fallback function lookup an address stored under the data key attached above and forwards the call to it with the value of the `msg.sender` and `msg.value` appended as extra calldata.

Check [LSP17-ContractExtension] and [LSP2-ERC725YJSONSchema] for more information.

## Rationale

The ERC725Y general data key value store allows for the ability to add any kind of information to the contract, which allows future use cases. The general execution allows full interactability with any smart contract or address. And the universal receiver allows the reaction to any future asset.

## Implementation

An implementation can be found on the [lsp-universalprofile-smart-contracts] repository;


## Interface Cheat Sheet

```solidity

interface ILSP9  /* is ERC165 */ {    
         
        
    // ERC725X
    
    event Executed(uint256 indexed operation, address indexed to, uint256 indexed  value, bytes4 selector);\
    
    event ContractCreated(uint256 indexed operation, address indexed contractAddress, uint256 indexed value);
    
    
    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external payable returns (bytes memory); // onlyOwner
    
    function execute(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns(bytes[] memory); // onlyOwner
    
    
    // ERC725Y
    
    event DataChanged(bytes32 indexed dataKey, bytes dataValue);
    
    
    function getData(bytes32 dataKey) external view returns (bytes memory dataValue);
    
    function setData(bytes32 dataKey, bytes memory dataValue) external; // onlyOwner
    
    function getData(bytes32[] memory dataKeys) external view returns (bytes[] memory dataValues);
    
    function setData(bytes32[] memory dataKeys, bytes[] memory dataValues) external; // onlyOwner
    
    
    // LSP9 (LSP9Vault)
      
    event ValueReceived(address indexed sender, uint256 indexed value);
    
    
    receive() external payable;
    
   
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
    
    
    // LSP17
    
    fallback() external payable;

}


```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[ERC725X]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#erc725x>
[ERC725Y]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#erc725y>
[LSP1-UniversalReceiver]: <./LSP-1-UniversalReceiver.md>
[LSP1]: <./LSP-1-UniversalReceiver.md>
[LSP2-ERC725YJSONSchema]: <./LSP-2-ERC725YJSONSchema.md>
[LSP14]: <./LSP-14-Ownable2Step.md>
[lukso-network/lsp-smart-contracts]: <https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP9Vault/LSP9VaultCore.sol>
[LSP17]: <./LSP-17-ContractExtension.md>
[LSP17-ContractExtension]: <./LSP-17-ContractExtension.md>
[UniversalReceiver]: <./LSP-1-UniversalReceiver.md#events>
[`universalReceiver(bytes32,bytes)`]: <./LSP-1-UniversalReceiver.md#universalreceiver>
[LSP1UniversalReceiver interface id]: <./LSP-1-UniversalReceiver.md#specification>
[`ValueReceived`]: <#valuereceived>
[DataChanged]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#datachanged>
