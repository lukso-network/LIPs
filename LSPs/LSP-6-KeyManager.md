---
lip: 6
title: Key Manager
author: Fabian Vogelsteller <fabian@lukso.network>, Jean Cavallera <contact.cj42@protonmail.com>
discussions-to:
status: Draft
type: LSP
created: 2021-08-03
requires: ERC725Y, LSP2, ERC165, ERC1271
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
<!--The motivation is critical for LIPs that want to change the Lukso protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.--> 

ERC725 accounts enable to own a universal profile, that:
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
These keys are based on the [LSP2-ERC725YJSONSchema](https://github.com/CJ42/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md) standard, and use the key type **[AddressMappingWithGrouping](https://github.com/CJ42/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#addressmappingwithgrouping)**

The KeyManager will read the permissions from the ERC725Account key value store, to determine if a key is allowed to perform certain actions.

#### AddressPermissions:Permissions:\<address\>

Holds the permissions for a key. See [Permission Values](#permission-values-in-addresspermissionspermissionsaddress) for details.

```json
{
    "name": "AddressPermissions:Permissions:<address>",
    "key": "0x4b80742d0000000082ac0000<address>",
    "keyType": "Singleton",
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
    "keyType": "Singleton",
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
    "keyType": "Singleton",
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
    "keyType": "Singleton",
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

Execute the a calldata payload on an ERC725 account.

The first 4 bytes of the `_data` payload MUST correspond to one of the function selector in the ERC725 account, such as `setData(...)`, `execute(...)` or `transferOwnership(...)`.

**returns:** `true` if the call on ERC725 account succeeded, `false` otherwise.

```solidity
function execute(bytes calldata _data) external payable returns (bool)
```

#### getNonce

Returns the current nonce to be used when using the [`executeRelayCall`](#relayCall)

```solidity
function getNonce(address _address) public view returns (uint256)
```

#### executeRelayCall

Allows anybody to execute `_data` payload on a ERC725 account, given they have a signed message from an executor.

**Parameters**

- `_data`: The call data to be executed.
- `_signedFor`: MUST be the `KeyManager` contract.
- `_nonce`: MUST be the nonce of the address that signed the message. This can be obtained via the `getNonce(address _address)` function.
- `_signature`: bytes32 ethereum signature.

**returns:** true if the call on ERC725 account succeeded, false otherwise.


```solidity
function executeRelayCall(bytes calldata _data, address _signedFor, uint256 _nonce, bytes memory _signature) external payable returns (bool)
```

**Important:** the message to sign MUST be of the following format: `<KeyManager address>` + `<_data payload>` + `<signer nonce>`.


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
        "keyType": "Singleton",
        "valueContent": "BitArray",
        "valueType": "bytes4"
    },
    {
        "name": "AddressPermissions:AllowedAddresses:<address>",
        "key": "0x4b80742d00000000c6dd0000<address>",
        "keyType": "Singleton",
        "valueContent": "Address",
        "valueType": "address[]"
    },
    {
        "name": "AddressPermissions:AllowedFunctions:<address>",
        "key": "0x4b80742d000000008efe0000<address>",
        "keyType": "Singleton",
        "valueContent": "Bytes4",
        "valueType": "bytes4[]"
    },
    {
        "name": "AddressPermissions:AllowedStandards:<address>",
        "key": "0x4b80742d000000003efa0000<address>",
        "keyType": "Singleton",
        "valueContent": "Bytes4",
        "valueType": "bytes4[]"
    }
]
```

## Interface Cheat Sheet

```solidity

interface ILSP6  /* is ERC165 */ {
        
    event Executed(uint256 indexed  _value, bytes _data); 
    
    
    function getNonce(address _address) public view returns (uint256);
    
    function execute(bytes calldata _data) external payable returns (bool);
    
    function executeRelayCall(bytes calldata _data, address _signedFor, uint256 _nonce, bytes memory _signature) external payable returns (bool);
 
        
    // ERC1271
    
    function isValidSignature(bytes32 _hash, bytes memory _signature) public view returns (bytes4 magicValue);
    
}

```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
