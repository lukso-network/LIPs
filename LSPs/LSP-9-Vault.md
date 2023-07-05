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

**LSP9-Vault** interface id according to [ERC165]: `0x28af17e6`.

_This `bytes4` interface id is calculated as the XOR of the selector of batchCalls function and the following standards: ERC725Y, ERC725X, LSP1-UniversalReceiver, LSP14Ownable2Step and LSP17Extendable._

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

> <bytes4\> is the `functionSelector` called on the vault contract. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

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


#### batchCalls

```solidity
function batchCalls(bytes[] calldata functionCalls) external returns (bytes[] memory results)
```

Enables the execution of a batch of encoded function calls on the current contract in a single transaction, provided as an array of bytes. 

MUST use the delegatecall opcode to execute each call in the same context of the current contract.


_Parameters:_

- `functionCalls`: an array of encoded function calls to be executed on the current contract.

The data field can be:

- an array of ABI-encoded function calls such as an array of ABI-encoded execute, setData, transferOwnership or any LSP9 functions.
- an array of bytes which will resolve to the fallback function to be checked for an extension. 


_Requirements:_

- MUST NOT be payable. 


_Returns:_ `results` , an array of bytes containing the return values of each executed function call.


#### execute

```solidity
function execute(uint256 operationType, address target, uint256 value, bytes memory data) external payable returns (bytes memory);
```
This function is part of the [ERC725X] specification, with additional requirements as follows:

- MUST revert when the operation type is DELEGATECALL.

- MUST emit a [`ValueReceived`] event before external calls or contract creation if the function receives native tokens.


#### executeBatch

```solidity
function executeBatch(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns (bytes[] memory);
```
This function is part of the [ERC725X] specification, with additional requirements as follows:

- MUST revert when one of the operations type is DELEGATECALL.

- MUST emit a [`ValueReceived`] event before external calls or contract creation if the function receives native tokens.


#### getData

```solidity
function getData(bytes32 dataKey) external view returns (bytes memory);
```

This function is part of the [ERC725Y] specification.


#### getDataBatch

```solidity
function getDataBatch(bytes32[] memory dataKeys) external view returns (bytes[] memory);
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


#### setDataBatch

```solidity
function setDataBatch(bytes32[] memory dataKeys, bytes[] memory dataValues) external;
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

- If an `address` is stored under the data key attached below and this address is a contract:
  - forwards the call to the [`universalReceiver(bytes32,bytes)`] function on the contract at this address **ONLY IF** this contract supports the [LSP1UniversalReceiver interface id].
  - if the contract at this address does not supports the [LSP1UniversalReceiver interface id], execution continues normally.
  
- If there is no `address` stored under this data key, execution continues normally. 

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

- If an `address` is stored under the data key attached below and this address is a contract:
  - forwards the call to the [`universalReceiver(bytes32,bytes)`] function on the contract at this address **ONLY IF** this contract supports the [LSP1UniversalReceiver interface id].
  - if the contract at this address does not supports the [LSP1UniversalReceiver interface id], execution continues normally.
  
- If there is no `address` stored under this data key, execution continues normally. 

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

The `<bytes32\>` in the data key name corresponds to the `typeId` passed to the `universalReceiver(..)` function. 

> **Warning**
> When constructing this data key for a specific `typeId`, unique elements of the typeId SHOULD NOT be on the right side because of trimming rules.
> 
> The `<bytes32>` is trimmed on the right side to keep only the first 20 bytes. Therefore, implementations SHOULD ensure that the first 20 bytes are unique to avoid clashes.
> For example, the `bytes32 typeId` below:
> 
> ```
> 0x1111222233334444555566667777888899990000aaaabbbbccccddddeeeeffff
> ```
> 
> will be trimmed to `0x1111222233334444555566667777888899990000`.
> 
> See the section about the trimming rules for the key type [`Mapping`](./LSP-2-ERC725YJSONSchema.md#mapping) in [LSP2-ERC725YJSONSchema] to learn how to encode this data key.

- MUST return the returned value of the `universalReceiver(bytes32,bytes)` function on both retreived contract abi-encoded as bytes. If there is no addresses stored under the data keys above or the call was not forwarded to them, the return value is the two empty bytes abi-encoded as bytes. 

- MUST emit a [UniversalReceiver] event if the function was successful.

Check the [**UniversalReceiver Delegation > Specification** section in LSP1-UniversalReceiver](./LSP-1-UniversalReceiver.md#universalreceiver-delegation) and [LSP2-ERC725YJSONSchema] for more information.

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

### Graffiti 

Graffiti refers to the arbitrary messages or data sent to an **LSP9-Vault** contract that do not match any existing function selectors, such as `execute(..)`, `setData(..)`, etc. These bytes, often carrying a message or additional information, are usually not intended to invoke specific functions within the contract. 

When the vault is called with specific bytes that do not match any function selector, it will first check its storage to see if there are any extensions set for these function selectors (bytes). If no extension is found, the call will typically revert. However, to emulate the behavior of calling an Externally Owned Account (EOA) with random bytes (which always passes), an exception has been made for the `0x00000000` selector.

When the vault is called with data that starts with `0x00000000`, it will first check for extensions. If none are found, the call will still pass, allowing it to match the behavior of calling an EOA and enabling the ability to send arbitrary messages to the vault. For example, one might receive a message like "This is a gift" while sending native tokens. 

Additionally, it is possible to set an extension for the `0x00000000` selector. With this custom extension, you can define specific logic that runs when someone sends graffiti to your vault. For instance, you may choose to disallow sending graffiti by reverting the transaction, impose a fee for sending graffiti, or emit the graffiti on an external contract. This flexibility allows for various use cases and interactions with graffiti in the LSP9Vaults contracts.

## Rationale

The ERC725Y general data key value store allows for the ability to add any kind of information to the contract, which allows future use cases. The general execution allows full interactability with any smart contract or address. And the universal receiver allows the reaction to any future asset.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/main/contracts/LSP9Vault/LSP9VaultCore.sol) repository.
The below defines the JSON interface of the `LSP9Vault`.

ERC725Y JSON Schema `LSP9Vault`:

```json
[
  // From LSP1
  {
    "name":"LSP1UniversalReceiverDelegate",
    "key":"0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
    "keyType":"Singleton",
    "valueType":"address",
    "valueContent":"Address"
  },
  {
    "name":"LSP1UniversalReceiverDelegate:<bytes32>",
    "key":"0x0cfc51aec37c55a4d0b10000<bytes32>",
    "keyType":"Mapping",
    "valueType":"address",
    "valueContent":"Address"
  },
  // From LSP17
  {
    "name":"LSP17Extension:<bytes4>",
    "key":"0xcee78b4094da860110960000<bytes4>",
    "keyType":"Mapping",
    "valueType":"address",
    "valueContent":"Address"
  }
]
```

## Interface Cheat Sheet

```solidity

interface ILSP9  /* is ERC165 */ {    
         
        
    // ERC725X
    
    event Executed(uint256 indexed operation, address indexed to, uint256 indexed  value, bytes4 selector);\
    
    event ContractCreated(uint256 indexed operation, address indexed contractAddress, uint256 indexed value);
    
    
    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external payable returns (bytes memory); // onlyOwner
    
    function executeBatch(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns(bytes[] memory); // onlyOwner
    
    
    // ERC725Y
    
    event DataChanged(bytes32 indexed dataKey, bytes dataValue);
    
    
    function getData(bytes32 dataKey) external view returns (bytes memory dataValue);
    
    function setData(bytes32 dataKey, bytes memory dataValue) external; // onlyOwner
    
    function getDataBatch(bytes32[] memory dataKeys) external view returns (bytes[] memory dataValues);
    
    function setDataBatch(bytes32[] memory dataKeys, bytes[] memory dataValues) external; // onlyOwner
    
    
    // LSP9 (LSP9Vault)
      
    event ValueReceived(address indexed sender, uint256 indexed value);
    
    
    receive() external payable;
    
    fallback() external payable;
    
    function batchCalls(bytes[] calldata data) external returns (bytes[] memory results);
    
   
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
