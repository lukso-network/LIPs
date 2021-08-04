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

### Permissions Keys

The following keys can be used to get and set permissions on a ERC725 account.
These keys are based on the [LSP2-ERC725YJSONSchema](https://github.com/CJ42/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md) standard, and use the key type **[AddressMappingWithGrouping](https://github.com/CJ42/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#addressmappingwithgrouping)**

```
bytes12 internal constant KEY_PERMISSIONS      = 0x4b80742d0000000082ac0000; // AddressPermissions:Permissions:<address> --> bytes1
bytes12 internal constant KEY_ALLOWEDADDRESSES = 0x4b80742d00000000c6dd0000; // AddressPermissions:AllowedAddresses:<address> --> address[]
bytes12 internal constant KEY_ALLOWEDFUNCTIONS = 0x4b80742d000000008efe0000; // AddressPermissions:AllowedFunctions:<address> --> bytes4[]
bytes12 internal constant KEY_ALLOWEDSTANDARDS = 0x4b80742d000000003efa0000; // AddressPermissions:AllowedStandards:<address> --> bytes4[]
```

### Permissions Values

The KeyManager defines the following set of constants, representing permissions as `bytesN`.

```
// PERMISSIONS VALUES
bytes1 internal constant PERMISSION_CHANGEOWNER   = 0x01;   // 0000 0001
bytes1 internal constant PERMISSION_CHANGEKEYS    = 0x02;   // 0000 0010
bytes1 internal constant PERMISSION_SETDATA       = 0x04;   // 0000 0100
bytes1 internal constant PERMISSION_CALL          = 0x08;   // 0000 1000
bytes1 internal constant PERMISSION_DELEGATECALL  = 0x10;   // 0001 0000
bytes1 internal constant PERMISSION_DEPLOY        = 0x20;   // 0010 0000
bytes1 internal constant PERMISSION_TRANSFERVALUE = 0x40;   // 0100 0000
bytes1 internal constant PERMISSION_SIGN          = 0x80;   // 1000 0000
```

Such permissions can be assigned to specific addresses, under the key-value store of an ERC725 Account.

In order to set these permissions, [LSP2-ERC725YJSONSchema]() must be implemented, as permissioning on the ERC725 account is based on this structure.

### Methods

#### nonceStore and getNonce

Latest nonce of the caller. Used to prevent replay attacks.

```
mapping (address => uint256) internal _nonceStore;
function getNonce(address _address) public view returns (uint256) {
    return _nonceStore[_address];
}
```

#### execute

Execute the `_data` payload on a ERC725 account.

The first 4 bytes of the `_data` payload MUST correspond to one of the function selector in the ERC725 account, such as `setData(...)`, `execute(...)` or `transferOwnership(...)`.

***return:*** `true` if the call on ERC725 account succeeded, `false` otherwise.

```
function execute(bytes calldata _data) 
    external 
    payable 
    returns (bool success_);
```

#### executeRelayedCall

Allows anybody to execute `_data` payload on a ERC725 account, given they have a signed message from an executor.

`_signedFor`: MUST be the `KeyManager` contract.

`_nonce`: MUST be the nonce of the address that signed the message. This can be obtained via the `getNonce(address _address)` function.

`_signature`: bytes32 ethereum signature.

```
function executeRelayedCall(
    bytes calldata _data,
    address _signedFor,
    uint256 _nonce,
    bytes memory _signature
)
    external
    payable
    returns (bool success_);
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


## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
