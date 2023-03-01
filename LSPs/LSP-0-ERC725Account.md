---
lip: 0
title: ERC725 Account
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: ERC165, ERC725X, ERC725Y, ERC1271, LSP1, LSP2, LSP14, LSP17
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
- can execute any smart contract and deploy smart contracts
- is highly extensible though additional standardisation of the key/value data stored.


## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

**LSP0-ERC725Account** interface id according to [ERC165]: `0x66767497`.

_This `bytes4` interface id is calculated as the XOR of the interfaceId of the following standards: ERC725Y, ERC725X, LSP1-UniversalReceiver, ERC1271-isValidSignature, LSP14Ownable2Step and LSP17Extendable._

Smart contracts implementing the LSP0 standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support the LSP0, ERC725X, ERC725Y, ERC1271, LSP1, LSP14 and LSP17Extendable interface ids.

### Methods

Smart contracts implementing the LSP0 standard MUST implement all of the functions listed below:

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
- MUST emit a [`ValueReceived`] event if value was sent alongside some calldata.
- MUST return if the data sent to the contract is less than 4 bytes in length.
- MUST check for address of the extension under the following ERC725Y Data Key, and call the extension.

```json
{
    "name": "LSP17Extension:<bytes4>",
    "key": "0xcee78b4094da860110960000<bytes4>",
    "keyType": "Mapping",
    "valueType": "address",
    "valueContent": "Address"
}
```

> <bytes4\> is the `functionSelector` called on the account contract. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

- MUST NOT revert when there is no extension set for `0x00000000`.

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

This function is part of the [LSP14] specification, with additional requirements as follows:

- MUST override the LSP14 Type ID triggered by using `transferOwnership(..)` to the one below:

    - `keccak256('LSP0OwnershipTransferStarted')` > `0xe17117c9d2665d1dbeb479ed8058bbebde3c50ac50e2e65619f60006caac6926`

#### acceptOwnership

```solidity
function acceptOwnership() external;
```

This function is part of the [LSP14] specification, with additional requirements as follows:

- MUST override the LSP14 Type IDs triggered by using `accceptOwnership(..)` to the ones below:

    - `keccak256('LSP0OwnershipTransferred_SenderNotification')` > `0xa4e59c931d14f7c8a7a35027f92ee40b5f2886b9fdcdb78f30bc5ecce5a2f814`
    
    - `keccak256('LSP0OwnershipTransferred_RecipientNotification')` > `0xceca317f109c43507871523e82dc2a3cc64dfa18f12da0b6db14f6e23f995538`

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

- MUST emit a [`ValueReceived`] event before external calls or contract creation if the function receives native tokens.


#### execute (Array)

```solidity
function execute(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns (bytes[] memory);
```
This function is part of the [ERC725X] specification, with additional requirements as follows:

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

- MUST emit only the first 256 bytes of the dataValue parameter in the [DataChanged] event.


#### setData (Array)

```solidity
function setData(bytes32[] memory dataKeys, bytes[] memory dataValues) external;
```

This function is part of the [ERC725Y] specification, with additional requirements as follows:

- MUST emit only the first 256 bytes of the dataValue parameter in the [DataChanged] event.


#### isValidSignature

```solidity
function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4);
```

This function is part of the [ERC1271](https://eips.ethereum.org/EIPS/eip-1271) specification, with additional requirements as follows:

- When the owner is an EOA, the function MUST return the [magic value](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md#specification) if the address recovered from the hash and the signature via [ecrecover](https://docs.soliditylang.org/en/v0.8.17/solidity-by-example.html?highlight=ecrecover#recovering-the-message-signer-in-solidity) is the owner of the contract, and MUST return the [failure value](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md#specification) otherwise. 

- When the owner is a contract, the function MUST check whether the owner contract supports [ERC1271 interface id](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md#specification) (magic value) through [ERC165](https://eips.ethereum.org/EIPS/eip-165), if **Yes** it calls `isValidSignature(bytes32,bytes)` function on the owner contract and returns its value. If the owner does not support ERC1271 interface id or the function does not exist on the owner contract, the function MUST return the [failure value](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md#specification).


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

If the account delegates its universal receiver functionality to another smart contract, this smart contract address MUST be stored under the data key attached above. This call to this contract is performed when the `universalReceiver(bytes32,bytes)` function of the account is called and can react on the whole call regardless of typeId. 

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

If the account delegates its universal receiver functionality to another smart contract, this smart contract address MUST be stored under the data key attached above. This call to this contract is performed when the `universalReceiver(bytes32,bytes)` function of the account is called with a specific typeId that it can react on. 

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

> <bytes4\> is the `functionSelector` called on the account contract. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

If there is a function called on the account and the function does not exist, the fallback function lookup an address stored under the data key attached above and forwards the call to it with the value of the `msg.sender` and `msg.value` appended as extra calldata.

Check [LSP17-ContractExtension] and [LSP2-ERC725YJSONSchema] for more information.


## Rationale

The ERC725Y general data key-value store allows for the ability to add any kind of information to the the account contract, which allows future use cases. The general executor allows full interactability with any smart contract or address. And the universal receiver allows reacting to any future asset received.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts] repository.

## Interface Cheat Sheet

```solidity
interface ILSP0  /* is ERC165 */ {
         
        
    // ERC725X

    event Executed(uint256 indexed operation, address indexed to, uint256 indexed  value, bytes4 selector);

    event ContractCreated(uint256 indexed operation, address indexed contractAddress, uint256 indexed value);
    
    
    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external payable returns (bytes memory); // onlyOwner
    
    function execute(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns(bytes[] memory); // onlyOwner
    
    
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
[lukso-network/lsp-smart-contracts]: <https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP0ERC725Account/LSP0ERC725AccountCore.sol>
[LSP17]: <./LSP-17-ContractExtension.md>
[LSP17-ContractExtension]: <./LSP-17-ContractExtension.md>
[UniversalReceiver]: <./LSP-1-UniversalReceiver.md#events>
[`universalReceiver(bytes32,bytes)`]: <./LSP-1-UniversalReceiver.md#universalreceiver>
[LSP1UniversalReceiver interface id]: <./LSP-1-UniversalReceiver.md#specification>
[`ValueReceived`]: <#valuereceived>
[DataChanged]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#datachanged>
