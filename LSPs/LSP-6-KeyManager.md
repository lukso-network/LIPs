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
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->

This standard describes a `KeyManager` contract with a set of pre-defined permissions that can be used as a controller for a ERC725 account.
Such permissions are useful to control actions performed by other addresses when interacting with an [ERC725Account](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md).

## Abstract

<!--A short (~200 word) description of the technical issue being addressed.-->

This standard allows for a controller and permissioning layer to be set on an ERC725 account.

It provides functionalities to allow / disallow third parties to perform actions on an ERC725 account, on behalf of its owner.

Such actions are represented as permissions that can be assigned to any third party address.

![lsp6-key-manager-flow-chart](https://user-images.githubusercontent.com/31145285/129574099-9eba52d4-4f82-4f11-8ac5-8bfa18ce97d6.jpeg)




## Motivation

ERC725Accounts enable to own a universal profile, that:
* can hold multiple assets (tokens, NFTs...).
* many addresses (whether users or contracts) can interact with.

However, data stored in a ERC725 account (under the JSON schema) can be easily updated by any address, using the function `setData(...)`. 
Currently, ERC725 accounts do not implement any form of delegate access control, so to grant or restrict third parties to perform action on their behalf.

What is required is a contract design that enable ERC725 account owners to:

* control who can interact with their profile.
* grant permissions, so to allow third parties to act on their behalf. 


## Specification


### Permission Keys on the ERC725Account

The following keys can be used to get and set permissions of certain addresses on a ERC725 account.   
These keys are based on the [LSP2-ERC725YJSONSchema](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md) standard, and use the key type **[Bytes20MappingWithGrouping](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md#bytes20mappingwithgrouping)**

The KeyManager will read the permissions from the ERC725Account key value store, to determine if a key is allowed to perform certain actions.

#### AddressPermissions[]

Holds an array of address, that have permission some permission sets to interact with the ERC725Account.

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

Holds the permissions for a key. See [Permission Values](#permission-values-in-addresspermissionspermissionsaddress) for details.

```json
{
    "name": "AddressPermissions:Permissions:<address>",
    "key": "0x4b80742d0000000082ac0000<address>",
    "keyType": "Bytes20MappingWithGrouping",
    "valueContent": "BitArray",
    "valueType": "bytes4"
}
```
    
#### AddressPermissions:AllowedAddresses:\<address\>

Holds an array of address, the key is allowed to talk to.

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

Holds an array of bytes4 function signatures, the key is allowed to call on other smart contracts.

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

Holds an array of bytes4 ERC165 standards signatures, other smart contracts should support, for the key to be allowed to talk to the smart contract.

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

The following permissions are set in the BitArray of the `AddressPermissions:Permissions:<address>` key in the following order:

```solidity
CHANGEOWNER   = 0x01;   // 0000 0001
CHANGEKEYS    = 0x02;   // 0000 0010
SETDATA       = 0x04;   // 0000 0100
CALL          = 0x08;   // 0000 1000
DELEGATECALL  = 0x10;   // 0001 0000
DEPLOY        = 0x20;   // 0010 0000
TRANSFERVALUE = 0x40;   // 0100 0000
SIGN          = 0x80;   // 1000 0000
```


![lsp6-key-manager-permissions-range](https://user-images.githubusercontent.com/31145285/129574070-8aceb32c-edf1-4134-b7c8-ca242a14c9c3.jpeg)



### Methods



#### execute

```solidity
function execute(bytes memory _data) public payable returns (bool)
```

Execute a calldata payload on an ERC725 account.

MUST fire the [Executed event](#executed).

_Parameters:_

- `_data`: The call data to be executed. The first 4 bytes of the `_data` payload MUST correspond to one of the function selector in the ERC725 account, such as `setData(...)`, `execute(...)` or `transferOwnership(...)`.

_Returns:_ `bool` , `true` if the call on ERC725 account succeeded, `false` otherwise.




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



#### executeRelayCall

```solidity
function executeRelayCall(address _signedFor, uint256 _nonce, bytes memory _data, bytes memory _signature) public payable returns (bool)
```

Allows anybody to execute `_data` payload on a ERC725 account, given they have a signed message from an executor.

MUST fire the [Executed event](#executed).

_Parameters:_

- `_signedFor`: MUST be the `KeyManager` contract.
- `_nonce`: MUST be the nonce of the address that signed the message. This can be obtained via the `getNonce(address _address, uint256 _channel)` function.
- `_data`: The call data to be executed.
- `_signature`: bytes32 ethereum signature.

_Returns:_ `bool` , true if the call on ERC725 account succeeded, false otherwise.

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
        "name": "AddressPermissions:Permissions:<address>",
        "key": "0x4b80742d0000000082ac0000<address>",
        "keyType": "Bytes20MappingWithGrouping",
        "valueContent": "BitArray",
        "valueType": "bytes4"
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
    
    function execute(bytes memory _data) external payable returns (bool);
    
    function executeRelayCall(address _signedFor, uint256 _nonce, bytes memory _data, bytes memory _signature) external payable returns (bool);
 
        
    // ERC1271
    
    function isValidSignature(bytes32 _hash, bytes memory _signature) external view returns (bytes4 magicValue);
    
}

```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
