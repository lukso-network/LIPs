---
lip: 6
title: Key Manager
author: Fabian Vogelsteller <fabian@lukso.network>, Jean Cavallera <contact.cj42@protonmail.com>
discussions-to:
status: Draft
type: LSP
created: 2021-08-03
requires: LSP2, ERC165, ERC1271
---


## Simple Summary

This standard describes a `KeyManager` contract with a set of pre-defined permissions for addresses. A KeyManager contract can control an [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md) like account, or any other [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract.


## Abstract

This standard allows for controlling addresses to be restricted through multiple permissions, to act on and through this KeyManager on a controlled smart contract (for example an [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md)).

The KeyManager functions as a gateway for the [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md) restricting an address actions based on set permissions.

Permissions are described in the [Permissions values section](#permission-values-in-addresspermissionspermissionsaddress). Furthermore addresses can be restricted to only talk to certain other smart contracts or address, specific functions or smart contracts supporting only specifc standard interfaces.

The Permissions are stored at [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md) ERC725Y key value store, and can therefore survive an upgrade to a new KeyManager contract.

The flow of a transactions is as follows:

![lsp6-key-manager-flow-chart](https://user-images.githubusercontent.com/31145285/129574099-9eba52d4-4f82-4f11-8ac5-8bfa18ce97d6.jpeg)




## Motivation

The benefit of a KeyManager is to externalise permission logic from [ERC725Y and X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) contracts (such as an [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md)). This allows for such an logic to be upgraded without needing to change the core [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md) contract.

Storing the permissions at the core [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md) itself, allows it to survive KeyManager upgrades and opens the door to add additional KeyManager logic in the future, without loosing already set address permissions.


## Specification


### ERC725Y Keys

**The permissions that the KeyManager reads, are stored on the controlled-contracts ERC725Y key value store (for example an [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md))**

The following ERC725Y keys are used to read permissions of certain addresses.
These keys are based on the [LSP2-ERC725YJSONSchema](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md) standard, and use the key type **[Bytes20MappingWithGrouping](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md#bytes20mappingwithgrouping)**


#### AddressPermissions[]

Contains an array of addresses, that have some permission set.
This is mainly useful for interfaces to know which address hold permissions.

```json
{
    "name": "AddressPermissions[]",
    "key": "0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3",
    "keyType": "Array",
    "valueContent": "Address",
    "valueType": "address"
}
```

#### AddressPermissions:Permissions:\<address\>

Contains [the permissions](#permission-values-in-addresspermissionspermissionsaddress) for an address.

```json
{
    "name": "AddressPermissions:Permissions:<address>",
    "key": "0x4b80742d0000000082ac0000<address>",
    "keyType": "Bytes20MappingWithGrouping",
    "valueContent": "BitArray",
    "valueType": "byte32"
}
```
    
#### AddressPermissions:AllowedAddresses:\<address\>

Contains an array of allowed address a controlling address is allowed to interact with.
IF no addresses are set, interacting with ALL addresses is allowed. IF one or more addresses is set, the controlling address, is only allowed to interacti with those addresses.

```json
{
    "name": "AddressPermissions:AllowedAddresses:<address>",
    "key": "0x4b80742d00000000c6dd0000<address>",
    "keyType": "Bytes20MappingWithGrouping",
    "valueContent": "Address",
    "valueType": "address[]"
}
```

#### AddressPermissions:AllowedFunctions:\<address\>

Contains an array of bytes4 function signatures, the controlling address is allowed to call on other smart contracts.

```json
{
    "name": "AddressPermissions:AllowedFunctions:<address>",
    "key": "0x4b80742d000000008efe0000<address>",
    "keyType": "Bytes20MappingWithGrouping",
    "valueContent": "Bytes4",
    "valueType": "bytes4[]"
}
```

#### AddressPermissions:AllowedStandards:\<address\>

Contains an array of bytes4 ERC165 interface Ids, other smart contracts MUST support, for the controlling address to be allowed to interact with.

```json
{
    "name": "AddressPermissions:AllowedStandards:<address>",
    "key": "0x4b80742d000000003efa0000<address>",
    "keyType": "Bytes20MappingWithGrouping",
    "valueContent": "Bytes4",
    "valueType": "bytes4[]"
}
```

### Permission Values in AddressPermissions:Permissions:\<address\>

The following permissions are allowed in the BitArray of the `AddressPermissions:Permissions:<address>` key for an address. The order can not be changed:

```js
CHANGEOWNER        = 0x0000000000000000000000000000000000000000000000000000000000000001;   // 0000 0000 0000 0001 // Allows changing the owner of the controlled contract
CHANGEPERMISSIONS  = 0x0000000000000000000000000000000000000000000000000000000000000002;   // .... .... .... 0010 // Allows changing the permissions (adding + removing) of addresses
ADDPERMISSIONS     = 0x0000000000000000000000000000000000000000000000000000000000000004;   // .... .... .... 0100 // Allows adding new permissions to addresses (removing permission disallowed) 
SETDATA            = 0x0000000000000000000000000000000000000000000000000000000000000008;   // .... .... .... 1000 // Allows setting data on the controlled contract
CALL               = 0x0000000000000000000000000000000000000000000000000000000000000010;   // .... .... 0001 .... // Allows calling other contracts through the controlled contract
STATICCALL         = 0x0000000000000000000000000000000000000000000000000000000000000020;   // .... .... 0010 .... // Allows calling other contracts through the controlled contract
DELEGATECALL       = 0x0000000000000000000000000000000000000000000000000000000000000040;   // .... .... 0100 .... // Allows delegate calling other contracts through the controlled contract
DEPLOY             = 0x0000000000000000000000000000000000000000000000000000000000000080;   // .... .... 1000 .... // Allows deploying other contracts through the controlled contract
TRANSFERVALUE      = 0x0000000000000000000000000000000000000000000000000000000000000100;   // .... 0001 .... .... // Allows transfering value to other contracts from the controlled contract
SIGN               = 0x0000000000000000000000000000000000000000000000000000000000000200;   // .... 0010 .... .... // Allows signing on behalf of the controlled account, for example for login purposes
```


![LSP6 - KeyManager-permissions-examples](https://user-images.githubusercontent.com/31145285/141792716-ccebaff5-9d06-4e2d-9c34-6cda51b0dc16.jpeg)


### Methods


#### getNonce

```solidity
function getNonce(address _address, uint256 _channel) public view returns (uint256)
```

Returns the nonce that needs to be signed by a allowed key to be passed into the [executeRelayCall](#executeRelayCall) function. A signer can choose his channel number arbitrarily.

If multiple transactions should be signed, nonces in the same channel can simply be increased by increasing the returned nonce.

Read [what are multi-channel nonces](#what-are-multi-channel-nonces)

_Parameters:_

- `_address`: the address of the signer of the transaction.
- `_channel` :  the channel which the signer wants to use for executing the transaction.

_Returns:_ `uint256` , the current nonce.

#### execute

```solidity
function execute(bytes memory _data) public payable returns (bytes memory)
```

Execute a payload on an ERC725 account.

MUST fire the [Executed event](#executed).

_Parameters:_

- `_data`: The call data to be executed. The first 4 bytes of the `_data` payload MUST correspond to one of the function selector in the ERC725 account, such as `setData(...)`, `execute(...)` or `transferOwnership(...)`.

_Returns:_ `bytes` , the returned data as abi-encoded bytes if the call on ERC725 account succeeded, otherwise revert with a reason-string. 







#### executeRelayCall

```solidity
function executeRelayCall(address _signedFor, uint256 _nonce, bytes memory _data, bytes memory _signature) public payable returns (bytes memory)
```

Allows anybody to execute `_data` payload on a ERC725 account, given they have a signed message from an executor.

MUST fire the [Executed event](#executed).

_Parameters:_

- `_signedFor`: MUST be the `KeyManager` contract.
- `_nonce`: MUST be the nonce of the address that signed the message. This can be obtained via the `getNonce(address _address, uint256 _channel)` function.
- `_data`: The call data to be executed.
- `_signature`: bytes32 ethereum signature.

_Returns:_ `bytes` , the returned data as abi-encoded bytes if the call on ERC725 account succeeded, otherwise revert with a reason-string. 

**Important:** the message to sign MUST be of the following format: `<KeyManager address>` + `<signer nonce>` + `<_data payload>` .
These 3 parameters MUST be:

- packed encoded (not zero padded, leading `0`s are removed)
- hashed with `keccak256`

The final message MUST be signed using ethereum specific signature, based on [EIP712](https://eips.ethereum.org/EIPS/eip-712).


### Events

#### Executed

```solidity
event Executed(uint256 indexed  _value, bytes _data);
```

MUST be fired when a transaction was successfully executed.


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

A implementation can be found in the [lukso-network/universalprofile-smart-contracts](https://github.com/lukso-network/universalprofile-smart-contracts/blob/main/contracts/LSP3Account.sol);
The below defines the JSON interface of the `LSP3Account`.

ERC725Y JSON Schema `LSP6KeyManager`, set at the `LSP3Account`:

```json
[
    {
        "name": "AddressPermissions[]",
        "key": "0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3",
        "keyType": "Array",
        "valueContent": "Address",
        "valueType": "address"
    },
    {
        "name": "AddressPermissions:Permissions:<address>",
        "key": "0x4b80742d0000000082ac0000<address>",
        "keyType": "Bytes20MappingWithGrouping",
        "valueContent": "BitArray",
        "valueType": "byte32"
    },
    {
        "name": "AddressPermissions:AllowedAddresses:<address>",
        "key": "0x4b80742d00000000c6dd0000<address>",
        "keyType": "Bytes20MappingWithGrouping",
        "valueContent": "Address",
        "valueType": "address[]"
    },
    {
        "name": "AddressPermissions:AllowedFunctions:<address>",
        "key": "0x4b80742d000000008efe0000<address>",
        "keyType": "Bytes20MappingWithGrouping",
        "valueContent": "Bytes4",
        "valueType": "bytes4[]"
    },
    {
        "name": "AddressPermissions:AllowedStandards:<address>",
        "key": "0x4b80742d000000003efa0000<address>",
        "keyType": "Bytes20MappingWithGrouping",
        "valueContent": "Bytes4",
        "valueType": "bytes4[]"
    }
]
```

## Interface Cheat Sheet

```solidity

interface ILSP6  /* is ERC165 */ {
        
    event Executed(uint256 indexed  _value, bytes _data); 
    
    
    function getNonce(address _address, uint256 _channel) external view returns (uint256);
    
    function execute(bytes memory _data) external payable returns (bytes memory);
    
    function executeRelayCall(address _signedFor, uint256 _nonce, bytes memory _data, bytes memory _signature) external payable returns (bytes memory);
 
        
    // ERC1271
    
    function isValidSignature(bytes32 _hash, bytes memory _signature) external view returns (bytes4 magicValue);
    
}

```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
