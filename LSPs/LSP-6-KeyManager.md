---
lip: 6
title: Key Manager
author: Fabian Vogelsteller <fabian@lukso.network>, Jean Cavallera <contact.cj42@protonmail.com>
discussions-to:
status: Draft
type: LSP
created: 2021-08-03
requires: ERC165, ERC1271, LSP2
---


## Simple Summary

This standard describes a `KeyManager` contract with a set of pre-defined permissions for addresses. A KeyManager contract can control an [ERC725Account] like account, or any other [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract.

## Abstract

This standard allows for controlling addresses to be restricted through multiple permissions, to act on and through this KeyManager on a controlled smart contract (for example an [ERC725Account]).

The KeyManager functions as a gateway for the [ERC725Account] restricting an address actions based on set permissions.

Permissions are described in the [Permissions section](#permissions). Furthermore addresses can be restricted to only talk to certain other smart contracts or address, specific functions or smart contracts supporting only specifc standard interfaces.

The Permissions are stored under the ERC725Y data key-value store of the linked [ERC725Account], and can therefore survive an upgrade to a new KeyManager contract.

The flow of a transactions is as follows:

![lsp6-key-manager-flow-chart](https://user-images.githubusercontent.com/31145285/129574099-9eba52d4-4f82-4f11-8ac5-8bfa18ce97d6.jpeg)

## Motivation

The benefit of a KeyManager is to externalise the permission logic from [ERC725Y and X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) contracts (such as an [ERC725Account]). This allows for such logic to be upgraded without needing to change the core [ERC725Account] contract.

Storing the permissions at the core [ERC725Account] itself, allows it to survive KeyManager upgrades and opens the door to add additional KeyManager logic in the future, without loosing already set address permissions.


## Specification

**LSP6-KeyManager** interface id according to [ERC165]: `0x38bb3cdb`.

Smart contracts implementing the LSP6 standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support the [ERC165], [ERC1271], [LSP20-CallVerification] and the LSP6 interface ids.

Every contract that supports the LSP6 standard SHOULD implement:

### Methods

#### target

```solidity
function target() external view returns (address)
```

Returns the `address` of the target smart contract controlled by this Key Manager. The controlled smart contract can be one of the following:
- ERC725X contract
- ERC725Y contract
- an ERC725 contract, implementing both ERC725X and ERC725Y (e.g: an [ERC725Account]).

#### isValidSignature

```solidity
function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4);
```

This function is part of the [ERC1271] specification, with additional requirements as follows:

- MUST recover the address from the hash and the signature and return the [ERC1721 magic value] if the address recovered have the [**SIGN Permission**](#sign), if not, MUST return the [ERC1271 fail value].


#### lsp20VerifyCall

```solidity
function lsp20VerifyCall(address caller, uint256 value, bytes memory receivedCalldata) external returns (bytes4 magicValue);
```

This function is part of the [LSP20-CallVerification] specification, with additional requirements as follows:

- MUST be called only by the linked [target](#target).

- MUST verify the permission of the **`caller`** based on the **`receivedCalldata`** as defined in the [permission](#permissions) section.

- MUST emit the [VerifiedCall](#verifiedcall) event after verifying permissions. 

- MUST set the reentrancy guard to true if the first 4 bytes of `receivedCalldata` are any function other than `setData(..)`/`setDataBatch(..)` and check for reentrancy permission if the call was reentrant.

- MUST return the magic value with the `0x01` bytes that indicates that `lsp20VerifyCallResult(..)` MUST be invoked.


#### lsp20VerifyCallResult

```solidity
function lsp20VerifyCallResult(bytes32 callHash, bytes memory callResult) external returns (bytes4 magicValue);
```

This function is part of the [LSP20-CallVerification] specification, with additional requirements as follows:

- MUST be called only by the linked [target](#target).

- MUST set the reentrancy guard to false if it's set to true. 

- MUST return the magic value.

#### getNonce

```solidity
function getNonce(address signer, uint128 channel) external view returns (uint256)
```

Returns the latest nonce for a signer on a specific channel. A signer can choose a channel number arbitrarily and use this nonce to sign a payload that can be executed as a meta-transaction by any address via [executeRelayCall](#executeRelayCall)  function.

_Parameters:_

- `signer`: the address of the signer of the transaction.
- `channel` :  the channel which the signer wants to use for executing the transaction.

_Returns:_ `uint256` , the current nonce.

Payloads signed with incremental nonces on the same channel for the same signer are executed in order. e.g, in channel X, the payload nb two signed with the second nonce will not be successfully executed until the payload nb one signed with the first nonce has been executed.

Payloads signed with nonces on different channels are executed independently from each other, regardless of when they got executed or if they got executed successfully or not. e.g, the payload signed with the fourth nonce on channel X can be successfully executed even if the payload signed with the first nonce of channel Y:
- was executed before.
- was executed and reverted.

> X and Y can be any arbitrary number between 0 and 2^128.

Read [what are multi-channel nonces](#what-are-multi-channel-nonces).

#### execute

```solidity
function execute(bytes memory payload) external payable returns (bytes memory)
```

Execute a payload on the linked [target](#target) contract.

MUST fire the [VerifiedCall event](#verifiedcall).

_Parameters:_

- `payload`: The abi-encoded function call to be executed on the linked target contract.

_Returns:_ `bytes` , the returned data as abi-decoded bytes of the call on ERC725 smart contract, if the call succeeded, otherwise revert with a reason-string.

_Requirements:_

- The first 4 bytes of the `payload` payload MUST correspond to one of the function selector on the ERC725 smart contract such as:

    - [`setData(bytes32,bytes)`](./LSP-0-ERC725Account.md#setdata)
    - [`setDataBatch(bytes32[],bytes[])`](./LSP-0-ERC725Account.md#setdatabatch)
    - [`execute(uint256,address,uint256,bytes)`](./LSP-0-ERC725Account.md#execute)
    - [`transferOwnership(address)`](./LSP-0-ERC725Account.md#transferownership)
    - [`acceptOwnership()`](./LSP-0-ERC725Account.md#acceptownership)

- MUST send the value passed by the caller to the call on the linked target.

> Non payable functions will revert in case of calling them and passing value along the call.

- The caller MUST have **permission** for the action being executed. Check [Permissions](#permissions) to know more.


#### executeBatch

```solidity
function executeBatch(uint256[] memory values, bytes memory payloads[]) external payable returns (bytes[] memory)
```

Execute a batch of payloads on the linked [target](#target) contract.

MUST fire the [VerifiedCall event](#verifiedcall) on each iteration.

_Parameters:_

- `values`: The array of values to be sent to the target contract along the call on each iteration.
- `payloads`: The array of calldata payloads to be executed on the target contract on each iteration.

_Returns:_ `bytes[]` , an array of returned data as abi-decoded array of `bytes[]` of the call on ERC725 smart contract, if the calls succeeded, otherwise revert with a reason-string.

_Requirements:_

- The parameters length MUST be equal.

- The sum of each element of the `values` array MUST be equal to the value sent to the function.

- MUST comply to the requirements of the [`execute(bytes)`](#execute) function.

#### executeRelayCall

```solidity
function executeRelayCall(bytes memory signature, uint256 nonce, uint256 validityTimestamps, bytes memory payload) external payable returns (bytes memory)
```

Allows anybody to execute a `payload` on the linked [target](#target) contract, given they have a valid signature, specific to the payload passed, from a permissioned controller.

MUST fire the [VerifiedCall event](#verifiedcall).

_Parameters:_
- `signature`: bytes65 ethereum signature.
- `nonce`: MUST be the nonce of the address that signed the message. This can be obtained via the `getNonce(address address, uint256 channel)` function.
- `validityTimestamps`:	Two `uint128` timestamps concatenated together. The first timestamp determines from when the payload can be executed, the second timestamp determines a deadlines after which the payload is not valid anymore. If validityTimestamps is `0`, the payload is valid at indefinitely at any point in time and the checks for the timestamps are skipped.
- `payload`: The abi-encoded function call to be executed on the linked target contract.


_Returns:_ `bytes` , the returned data as abi-decoded bytes of the call on ERC725 smart contract, if the call succeeded, otherwise revert with a reason-string.

_Requirements:_

- The address recovered from the signature and the digest signed MUST have **permission(s)** for the action(s) being executed. Check [Permissions](#permissions) to know more.

The digest signed MUST be constructed according to the [version 0 of EIP-191] with the following format:

```
0x19 <0x00> <KeyManager address> <LSP6_VERSION> <chainId> <nonce> <validityTimestamps> <value> <payload>
```

    - `0x19`: byte intended to ensure that the `signed_data` is not valid RLP.
    - `0x00`: version 0 of the EIP191.
    - `KeyManager address`: The address of the Key Manager executing the payload.
    - `LSP6_VERSION`: Version relative to the LSP6KeyManager defined as a uint256 equal to 6.
    - `chainId`: The chainId of the blockchain where the Key Manager is deployed, as a uint256.
    - `nonce`: The nonce to sign the payload with, as a uint256.
    - `validityTimestamps`: Two uint128 timestamps concatenated, the first timestamp determines from when the payload can be executed, the second timestamp delimits the end of the validity of the payload. If validityTimestamps is 0, the checks of the timestamps are skipped.
    - `value`: The amount of native token to transfer to the linked target contract alongside the call.
    - `payload`: The payload to be executed.

These parameters MUST be packed encoded (not zero padded, leading `0`s are removed), then hashed with keccak256 to produce the digest.

For signing, permissioned users should apply the same steps and sign the final hash got at the end.

- The nonce passed to the function MUST be a valid nonce according to the [multi-channel nonce](#what-are-multi-channel-nonces) section.

- MUST send the value passed by the caller to the call on the linked target contract.

> Non payable functions will revert in case of calling them and passing value along the call.


#### executeRelayCallBatch

```solidity
function executeRelayCallBatch(bytes[] memory signatures, uint256[] memory nonces, uint256[] memory validityTimestamps, uint256[] memory values, bytes[] memory payloads) external payable returns (bytes[] memory)
```


Allows anybody to execute a batch of `payloads` on the linked [target](#target) contract, given they have valid signatures specific to the payloads signed by permissioned controllers.

MUST fire the [VerifiedCall event](#verifiedcall) on each iteration.

_Parameters:_

- `signatures`: An array of bytes65 ethereum signature.
- `nonce`: An array of nonces from the address/es that signed the digests. This can be obtained via the `getNonce(address address, uint256 channel)` function.
- `values`: An array of native token amounts to transfer to the linked [target](#target) contract alongside the call on each iteration.
- `validityTimestamps`:	An array of `uint256` formed of Two `uint128` timestamps concatenated, the first timestamp determines from when the payload can be executed, the second timestamp delimits the end of the validity of the payload. If validityTimestamps is `0`, the checks of the timestamps are skipped.
- `payloads`: An array of calldata payloads to be executed on the linked [target](#target) contract on each iteration.

_Returns:_ `bytes[]` , an array of returned as abi-decoded array of `bytes[]` of the linked target contract, if the calls succeeded, otherwise revert with a reason-string.

_Requirements:_

- MUST comply to the requirements of the [`executeRelayCall(bytes,uint256,bytes)`](#executerelaycall) function.

- The parameters length MUST be equal.

- The sum of each element of the `values` array MUST be equal to the total value sent to the function.


### Events

#### VerifiedCall

```solidity
event VerifiedCall(address indexed signer, uint256 indexed value, bytes4 indexed selector);
```

MUST be fired when the permissions of a call was successfully verified.

### Permissions

The permissions MUST be checked against the following address, depending on 
the function/method being called:

- against the **caller** parameter in the cases of [`lsp20VerifyCall(address,uint256,bytes)`](#lsp20verifycall).

- against the **caller** in the cases of [`execute(bytes)`](#execute) and [`executeBatch(uint256[],bytes[])`](#executebatch).

- against the **signer address**, recovered from the signature and the digest, in the cases of [`executeRelayCall(bytes,uint256,bytes)`](#executerelaycall) and [`executeRelayCallBatch(bytes[],uint256[],uint256[],bytes[])`](#executerelaycallbatch).

The permissions MUST be stored as [BitArray] under the [`AddressPermissions:Permissions:<address>`](#addresspermissionspermissionsaddress) data key on the target.

> In the descriptions of each permissions below, the term _controller address_ refers to an address that has some permissions set under the target contract linked to this Key Manager.

#### `CHANGEOWNER`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000001`

- Allows changing the owner of the target contract by calling [`transferOwnership(address)`](./LSP-0-ERC725Account.md#transferownership) and [`acceptOwnership()`](./LSP-0-ERC725Account.md#acceptownership).

#### `ADDCONTROLLER`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000002`

- Allows incrementing the length of the [`AddressPermissions[]`](#addresspermissions) data key and adding an address at a new index of the array.

- Allows adding permissions for a new controller address under the [`AddressPermissions:Permissions:<address>`](#addresspermissionspermissionsaddress) data key.

- Allows adding the restrictions for the call operations such as [CALL](#call), [STATICCALL](#staticcall), and [DELEGATECALL](#delegatecall) and [SETDATA](#setdata) permissions stored respectively under the [`AddressPermissions:AllowedCalls:<address>`](#addresspermissionsallowedcallsaddress) and [`AddressPermissions:AllowedERC725YDataKeys:<address>`](#addresspermissionsallowederc725ydatakeysaddress).

The value of these data keys SHOULD be validated before being set to avoid edge cases.

> All the actions above are done using the setData function

#### `EDITPERMISSIONS`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000004`

- Allows decrementing the length of the [`AddressPermissions[]`](#addresspermissions) data key and changing the address at an existing index of the array.

- Allows changing permissions for an existing controller address under the [`AddressPermissions:Permissions:<address>`](#addresspermissionspermissionsaddress) data key.

- Allows changing existing restrictions for the call operations such as [CALL](#call), [STATICCALL](#staticcall), and [DELEGATECALL](#delegatecall) and [SETDATA](#setdata) permissions stored respectively under the [`AddressPermissions:AllowedCalls:<address>`](#addresspermissionsallowedcallsaddress)  and [`AddressPermissions:AllowedERC725YDataKeys:<address>`](#addresspermissionsallowederc725ydatakeysaddress).

The value of these data keys SHOULD be validated before being set to avoid edge cases.

> All the actions above are done using the setData function

#### `ADDEXTENSIONS`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000008`

- Allows adding new extension address/es for new function selectors stored under [LSP17Extension](./LSP-0-ERC725Account.md#lsp17extension) data key.


#### `CHANGEEXTENSIONS`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000010`

- Allows changing existing extension address/es for function selectors stored under [LSP17Extension](./LSP-0-ERC725Account.md#lsp17extension) data key.

#### `ADDUNIVERSALRECEIVERDELEGATE`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000020`

- Allows adding new UniversalReceiverDelegate address/es stored under new [LSP1UniversalReceiverDelegate](./LSP-0-ERC725Account.md#lsp1universalreceiverdelegate) and [Mapped LSP1UniversalReceiverDelegate](./LSP-0-ERC725Account.md#mapped-lsp1universalreceiverdelegate) data keys.

#### `CHANGEUNIVERSALRECEIVERDELEGATE`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000040`

- Allows changing existing UniversalReceiverDelegate address/es stored under [LSP1UniversalReceiverDelegate](./LSP-0-ERC725Account.md#lsp1universalreceiverdelegate) and [Mapped LSP1UniversalReceiverDelegate](./LSP-0-ERC725Account.md#mapped-lsp1universalreceiverdelegate) data keys.


#### `REENTRANCY`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000080`

- Allows reentering the public [`execute(bytes)`](#execute), [`executeBatch(uint256[],bytes[])`](#executebatch), [`executeRelayCall(bytes,uint256,bytes)`](#executerelaycall) and [`executeRelayCallBatch(bytes[],uint256[],uint256[],bytes[])`](#executerelaycallbatch) functions.


#### `SUPER_TRANSFERVALUE`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000100`

- Allows transferring value from the target contract through [`execute(..)`](./LSP-0-ERC725Account.md#execute) function of the target without any restrictions.


#### `TRANSFERVALUE`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000200`

- Allows transferring value from the target contract through [`execute(..)`](./LSP-0-ERC725Account.md#execute) function of the target with restricting to specific standards, addresses or functions.

> Check [`AddressPermissions:AllowedCalls:<address>`](#addresspermissionsallowedcallsaddress) for more information about the restrictions.

#### `SUPER_CALL`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000400`

- Allows executing a payload with [CALL] operation from the target contract through [`execute(..)`](./LSP-0-ERC725Account.md#execute) function of the target without any restrictions.


#### `CALL`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000000800`

- Allows executing a payload with [CALL] operation from the target contract through [`execute(..)`](./LSP-0-ERC725Account.md#execute) function of the target with restricting to specific standards, addresses or functions.

> Check [`AddressPermissions:AllowedCalls:<address>`](#addresspermissionsallowedcallsaddress) to know more about the restrictions.

#### `SUPER_STATICCALL`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000001000`

- Allows executing a payload with [STATICCALL] operation from the target contract through [`execute(..)`](./LSP-0-ERC725Account.md#execute) function of the target without any restrictions.


#### `STATICCALL`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000002000`

- Allows executing a payload with [STATICCALL] operation from the target contract through [`execute(..)`](./LSP-0-ERC725Account.md#execute) function of the target with restricting to specific standards, addresses or functions.

> Check [`AddressPermissions:AllowedCalls:<address>`](#addresspermissionsallowedcallsaddress) for more information about the restrictions.

#### `SUPER_DELEGATECALL`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000004000`

- Allows executing a payload with [DELEGATECALL] operation from the target contract through [`execute(..)`](./LSP-0-ERC725Account.md#execute) function of the target without any restrictions.


#### `DELEGATECALL`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000008000`

- Allows executing a payload with [DELEGATECALL] operation from the target contract through [`execute(..)`](./LSP-0-ERC725Account.md#execute) function of the target with restricting to specific standards, addresses or functions.

> Check [`AddressPermissions:AllowedCalls:<address>`](#addresspermissionsallowedcallsaddress) for more information about the restrictions.


#### `DEPLOY`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000010000`

- Allows creating a contract with [CREATE] and [CREATE2] operations from the target contract through [`execute(..)`](./LSP-0-ERC725Account.md#execute) function of the target. 

The permission `SUPER_TRANSFERVALUE` is REQUIRED to fund the contract with some native tokens while deploying it.

#### `SUPER_SETDATA`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000020000`

- Allows setting data keys on the target contract through [`setData(bytes32,bytes)`](./LSP-0-ERC725Account.md#execute) and [`setData(bytes32[],bytes[])`](#) functions without any restrictions on the data keys to set.

The data keys related to permissions, extensions, UniversalReceiverDelegate MUST be checked with their own permission.

#### `SETDATA`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000040000`

- Allows setting data keys on the target contract through [`setData(bytes32,bytes)`](./LSP-0-ERC725Account.md#execute) and [`setData(bytes32[],bytes[])`](#) functions with restricting to specific data keys to set.

The data keys related to permissions, extensions, UniversalReceiverDelegate MUST be checked with their own permission.

> Check [`AddressPermissions:AllowedERC725YDataKeys:<address>`](#addresspermissionsallowederc725ydatakeysaddress) for more information about the restrictions.

#### `ENCRYPT`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000080000`

- Allows encrypting data to be used for on/off-chain purposes.

#### `DECRYPT`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000100000`

- Allows decrypting data to be used for on/off-chain purposes.

#### `SIGN`

BitArray representation: `0x0000000000000000000000000000000000000000000000000000000000200000`

- Validates the signed messages by the target contract to be used for on/off-chain purposes.

### ERC725Y Data Keys

**The permissions that the KeyManager reads, are stored on the controlled-contracts ERC725Y data key value store (for example an [ERC725Account](./LSP-0-ERC725Account.md))**

The following ERC725Y data keys are used to read permissions and restrictions of certain addresses.

These data keys are based on the [LSP2-ERC725YJSONSchema](./LSP-2-ERC725YJSONSchema.md) standard, and use the key type **[`MappingWithGrouping`](./LSP-2-ERC725YJSONSchema.md#mappingwithgrouping)**


#### AddressPermissions[]

```json
{
    "name": "AddressPermissions[]",
    "key": "0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3",
    "keyType": "Array",
    "valueType": "address",
    "valueContent": "Address"
}
```

Contains an array of addresses, that have some permission set.
This is mainly useful for interfaces to know which address holds which permissions.

For more information about how to access each index of the `AddressPermissions[]` array, see: [ERC725Y JSON Schema > `keyType` `Array`](./LSP-2-ERC725YJSONSchema.md#array)

#### AddressPermissions:Permissions:\<address\>

```json
{
    "name": "AddressPermissions:Permissions:<address>",
    "key": "0x4b80742de2bf82acb3630000<address>",
    "keyType": "MappingWithGrouping",
    "valueType": "bytes32",
    "valueContent": "BitArray"
}
```


Contains a set of permissions for an address. Permissions defines what an address **can do on** the target contract (*eg: edit the data key-value store via SETDATA*), or **can perform on behalf of** the target.

Since the `valueType` of this data key is `bytes32`, up to 255 different permissions can be defined. This includes the [default permissions](#permissions) defined. Custom permissions can be defined on top of the default one.


#### AddressPermissions:AllowedCalls:\<address\>

```json
{
    "name": "AddressPermissions:AllowedCalls:<address>",
    "key": "0x4b80742de2bf393a64c70000<address>",
    "keyType": "MappingWithGrouping",
    "valueType": "(bytes4,address,bytes4,bytes4)[CompactBytesArray]",
    "valueContent": "(BitArray,Address,Bytes4,Bytes4)"
}
```

Contains a compact bytes array of call restrictions, addresses, interfaceIds and function selectors a controller address is allowed to execute and interact with.

Each allowed call is made of four elements concatenated together as a tuple that forms a final `bytes32` long value.

The full list of allowed calls MUST be constructed as a [CompactBytesArray](./LSP-2-ERC725YJSONSchema.md#bytescompactbytesarray) according to [LSP2-ERC725YJSONSchema] as follow:

```js
<0020> <bytes4 restrictionOperations> <bytes20 allowedAddress> <bytes4 allowedInterfaceId> <bytes4 allowedFunction> <0020> ... <0020> ...
```

> **NB:** the three dots `...` are placeholders for `<bytes4 callRestrictions> <bytes20 allowedAddress> <bytes4 allowedInterfaceId> <bytes4 allowedFunction>` and used for brevity.

- `0020`: **0020** in decimals is **32**, the total number of bytes of the four elements below concatenated together.
- `callRestrictions`: A bitArray that represents the list of restricted call types applied for this allowed call (address - interfaceId - function).

    The call restrictions are defined with specific bits, starting from the least significant bit (the rightmost bit): 

    - transferValue `00000001`
    - call `00000010`
    - staticcall `00000100`
    - delegatecall `00001000` 

    Custom implementations of the LSP6 Standard can add more operations as needed.

- `allowedAddress`: The address called by the target contract.
- `allowedInterfaceId`: The ERC165 interface id being supported by the contract called from the target.
- `allowedFunction`: The function selector being called on the contract called by the target contract.

- If the value of the data key is **empty**, execution is disallowed.

- `restrictionOperations` MUST NOT discarded. 

- Check is discarded for an element if the value is full `ff` bytes. e.g, `0xffffffff` for interfaceIds and function selectors and `0xffffffffffffffffffffffffffffffffffffffff` for addresses. There MUST be at most 2 discarded checks, meaning `0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff` data key is disallowed. 



**Example 1:**

If controller A has [CALL](#permissions) permission, and have the following value for AllowedCalls:

```
0x002000000002cafecafecafecafecafecafecafecafecafecafe11223344bb11bb11
```

The `restrictionOperations` is **`0x00000002`**, meaning that the restrictions above only applies when the operation **[CALL](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute)** is being executed.

The controller A is allowed to interact via the **CALL** operation with the function selector **`0xbb11bb11`** on the **`0xcafecafecafecafecafecafecafecafecafecafe`** address as long as the address supports **`0x11223344`** interfaceId through [ERC165]. 

<br>

**Example 2:**

If controller B has [DELEGATECALL](#permissions) permission, and have the following value for AllowedCalls:

```
0x002000000004cafecafecafecafecafecafecafecafecafecafeffffffffffffff002000000004ffffffffffffffffffffffffffffffffffffffff68686868ffffffff
```

The `restrictionOperations` on both elements is **`0x00000004`**, it means that the restrictions above only applies when the operation **[DELEGATECALL](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute)** is being executed.

The controller B is allowed to interact with:
- the address **`0xcafecafecafecafecafecafecafecafecafecafe`** **only via DELEGATECALL** without any restriction on the interfaceId or the function selector.
- **any address** supporting the **`0x68686868`** interfaceId without any restriction on the function.

<br>

**Example 3:**

If controller B has [DELEGATECALL](#permissions) permission, and have the following value for AllowedCalls:

```
0x002000000002cafecafecafecafecafecafecafecafecafecafe11223344bb11bb11
```

The `restrictionOperations` is **`0x00000002`**, it means that the restrictions above only applies when the operation **[CALL](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute)** is being executed.

Given that the controller B have the **DELEGATECALL** Permission and the restrictions only applies for the **CALL** operation, any execution of **DELEGATECALL** operation will fail even to the function **`0xbb11bb11`** on **`0xcafecafecafecafecafecafecafecafecafecafe`** address.


<br>

**Example 4:**

If controller B has [TRANSFERVALUE](#permissions) and [CALL](#permissions) permissions, and have the following value for AllowedCalls:

```
0x002000000003cafecafecafecafecafecafecafecafecafecafe11223344bb11bb11
```

The `callRestrictions` is **`0x00000003`**, it means that the restrictions above applies when the operation **[CALL](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute)** or **[TRANSFERVALUE](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute)** is being executed.

The controller B is allowed to **CALL** or **TransferValue** to:
- the contract deployed at address **`0xcafecafecafecafecafecafecafecafecafecafe`** as long as this contract supports the interfaceId **`0x11223344`** through [ERC165]. 
- only the function with selector **`0xbb11bb11`** on this contract.
- this function on this contract with or without transferring value at the same time (because of the additional **TransferValue** in the `callRestrictions`).

<br>


**Example 5:**

If controller B has [TRANSFERVALUE](#permissions) and [CALL](#permissions) permissions, and have the following value for AllowedCalls:

```
0x002000000001cafecafecafecafecafecafecafecafecafecafe11223344bb11bb11002000000002ffffffffffffffffffffffffffffffffffffffff68686868ffffffff
```

Each element of the compact bytes array have a different `restrictionOperations`:

- **`0x000000001`** for the first element allowing the controller B to only **TransferValue** to the function **`0xbb11bb11`** on **`0xcafecafecafecafecafecafecafecafecafecafe`** address as long as the address supports **`0x11223344`** interfaceId through [ERC165].

- **`0x000000002`** for the second element allowing the controller B to only **Call** any function on any contract that support the interface ID **`0x68686868`** through [ERC165].

<br>
 

#### AddressPermissions:AllowedERC725YDataKeys:\<address\>

```json
{
    "name": "AddressPermissions:AllowedERC725YDataKeys:<address>",
    "key": "0x4b80742de2bf866c29110000<address>",
    "keyType": "MappingWithGrouping",
    "valueType": "bytes[CompactBytesArray]",
    "valueContent": "Bytes"
}
```

Contains a compact bytes array of dynamic ERC725Y data keys that the `address` is restricted to modify in case of setting normal data with [SETDATA](#setdata) permission.

- If the value of the data key is **empty**, setting data is disallowed.

The compact bytes array MUST be constructed in this format according to [LSP2-ERC725YJSONSchema]:

```js
<length of the data key prefix> <data key prefix>
```

- `length of the data key prefix`: The length of the prefix of the data key which the rest is dynamic. MUST be a number between `1` and `32`.
- `data key prefix`: The prefix of the data key to be checked against the data keys being set.

Below is an example based on a [LSP2 Mapping](./LSP-2-ERC725YJSONSchema.md#Mapping) key type, where first word = `SupportedStandards`, and second word = `LSP3UniversalProfile`.

```js
name: "SupportedStandards:LSP3UniversalProfile"
key: 0xeafec4d89fa9619884b60000abe425d64acd861a49b8ddf5c0b6962110481f38
```

<br>

**Example 1:**


- If address A has [SETDATA](#setdata) permission, and have the following value for AllowedERC725YDataKeys:

```
> 0x 0020 eafec4d89fa9619884b60000abe425d64acd861a49b8ddf5c0b6962110481f38
> 0x0020eafec4d89fa9619884b60000abe425d64acd861a49b8ddf5c0b6962110481f38
```
> 0020 (32 in decimals) is the length of the data key to be set.

Resolve to:

Address A is only allowed to set the value for the data key attached above.

<br>

**Example 2:**

- If address B has [SETDATA](#setdata) permission, and have the following value for AllowedERC725YDataKeys:

```
> 0x 000a eafec4d89fa9619884b6 0020 beefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeef
> 0x000aeafec4d89fa9619884b60020beefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeef
```
> 000a (10 in decimals) is the length of the `eafec4d89fa9619884b6` prefix

Resolve to:

Address B is only allowed to set the value for the data `0xbeefbeef..beef` data key and any data key that starts with `0xeafec4d89fa9619884b6`.

By setting the value to `0xeafec4d89fa9619884b6` in the list of allowed ERC725Y data keys, one address can set any data key **starting with the first word `SupportedStandards:...`**.

<br>

### What are multi-channel nonces

This concept was taken from <https://github.com/amxx/permit#out-of-order-execution>.

Using nonces prevent old signed transactions from being replayed again (replay attacks). A nonce is an arbitrary number that can be used just once in a transaction.

#### Problem of Sequential Nonces

With native transactions, nonces are strictly sequential. This means that messages with sequential nonces must be executed in order. For instance, in order for message number 4 to be executed, it must wait for message number 3 to complete.

However, **sequential nonces come with the following limitation**:

Some users may want to sign multiple message, allowing the transfer of different assets to different recipients. In that case, the recipient want to be able to use / transfer their assets whenever they want, and will certainly not want to wait on anyone before signing another transaction.

 This is where **out-of-order execution** comes in.

#### Introducing multi-channel nonces

Out-of-order execution is achieved by using multiple independent channels. Each channel's nonce behaves as expected, but different channels are independent. This means that messages 2, 3, and 4 of `channel 0` must be executed sequentially, but message 3 of channel 1 is independent, and only depends on message 2 of `channel 1`.

The benefit is that the signer key can determine for which channel to sign the nonces. Relay services will have to understand the channel the signer choose and execute the transactions of each channel in the right order, to prevent failing transactions.

#### Nonces in the KeyManager

The Key Manager allows out-of-order execution of messages by using nonces through multiple channels.

 Nonces are represented as `uint256` from the concatenation of two `uint128` : the `channelId` and the `nonceId`.

 - left most 128 bits : `channelId`
 - right most 128 bits: `nonceId`


![multi-channel-nonce](https://user-images.githubusercontent.com/31145285/133292580-42817340-104e-48c5-832b-533842b98d26.jpg)

<p align="center"><i> Example of multi channel nonce, where channelId = 5 and nonceId = 1 </i></p>


The current nonce can be queried using:

```solidity
function getNonce(address _address, uint256 _channel) public view returns (uint256)
```
Since the `channelId` represents the left-most 128 bits, using a minimal value like 1 will return a huge `nonce` number: `2**128` equal to 3402823669209384634633746074317682114**56**.

After the signed transaction is executed the `nonceId` will be incremented by 1, this will increment the `nonce` by 1 as well because the nonceId represents the first 128 bits of the nonce so it will be 3402823669209384634633746074317682114**57**.

```solidity

_nonces[signer][nonce >> 128]++

```
`nonce >> 128` represents the channel which the signer chose for executing the transaction. After looking up the nonce of the signer at that specific channel it will be incremented by 1 `++`.<br>

For sequential messages, users could use channel `0` and for out-of-order messages they could use channel `n`.

**Important:** It's up to the user to choose the channel that he wants to sign multiple sequential orders on it, not necessary `0`.

## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
This standard was inspired by how files permissions are designed in UNIX based file systems.

Files are assigned permissions as a 3 digit numbers, where each of the 3 digits is an octal value representing a set of permissions.
The octal value is calculated as the sum of permissions, where *read* = **4**, *write* = **2**, and *execute* = **1**

To illustrate, for a file set with permission `755`, the group permission (second digit) would be *read* and *execute* (See figure below). Each number is simply a **three binary placeholder, each one holding the number that correspond to the access level in r, w, x order**.


## Implementation
<!--The implementations must be completed before any LIP is given status "Final", but it need not be completed before the LIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->

A implementation can be found in the [lukso-network/universalprofile-smart-contracts](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/main/contracts/LSP6KeyManager/LSP6KeyManager.sol);
The below defines the JSON interface of the target(#target) contract.

ERC725Y JSON Schema `LSP6KeyManager`, set at the target(#target) contract:

```json
[
    {
        "name": "AddressPermissions[]",
        "key": "0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3",
        "keyType": "Array",
        "valueType": "address",
        "valueContent": "Address"
    },
    {
        "name": "AddressPermissions:Permissions:<address>",
        "key": "0x4b80742de2bf82acb3630000<address>",
        "keyType": "MappingWithGrouping",
        "valueType": "bytes32",
        "valueContent": "BitArray"
    },
    {
        "name": "AddressPermissions:AllowedCalls:<address>",
        "key": "0x4b80742de2bf393a64c70000<address>",
        "keyType": "MappingWithGrouping",
        "valueType": "(bytes4,address,bytes4,bytes4)[CompactBytesArray]",
        "valueContent": "(BitArray,Address,Bytes4,Bytes4)"
    },
    {
        "name": "AddressPermissions:AllowedERC725YDataKeys:<address>",
        "key": "0x4b80742de2bf866c29110000<address>",
        "keyType": "MappingWithGrouping",
        "valueType": "bytes[CompactBytesArray]",
        "valueContent": "Bytes"
    }
]
```

## Interface Cheat Sheet

```solidity

interface ILSP6  /* is ERC165 */ {

    // ERC1271

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);


    // LSP6

    event VerifiedCall(address indexed signer, uint256 indexed value, bytes4 indexed selector);


    function target() external view returns (address);

    function getNonce(address from, uint128 channelId) external view returns (uint256);


    function execute(bytes calldata payload) external payable returns (bytes memory);

    function executeBatch(uint256[] calldata values, bytes[] calldata payloads) external payable returns (bytes[] memory);


    function executeRelayCall(bytes calldata signature, uint256 nonce, uint256 validityTimestamps, bytes calldata payload) external payable returns (bytes memory);

    function executeRelayCallBatch(bytes[] calldata signatures, uint256[] calldata nonces, uint256[] calldata validityTimestamps, uint256[] calldata values, bytes[] calldata payloads) external payable returns (bytes[] memory);

}
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).


[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[version 0 of EIP-191]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-191.md#version-0x00>
[ERC725 X or Y smart contract]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md>
[ERC1271]: <https://eips.ethereum.org/EIPS/eip-1271>
[ERC1721 magic value]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md#specification>
[ERC1271 fail value]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md#specification>
[ERC725Account]: <./LSP-0-ERC725Account.md>
[BitArray]: <./LSP-2-ERC725YJSONSchema.md#bitarray>
[EIP191]: <https://eips.ethereum.org/EIPS/eip-191>
[CALL]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute>
[STATICCALL]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute>
[DELEGATECALL]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute>
[CREATE]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute>
[CREATE2]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#execute>
[LSP20-CallVerification]: <./LSP-20-CallVerification.md>
