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

![lsp-key-manager-flow-chart](https://user-images.githubusercontent.com/31145285/129573696-1e4ecfb6-9137-46b7-8ff6-59539b04cf56.png)

### Permission Keys on the ERC725Account

The following keys can be used to get and set permissions of certain addresses on a ERC725 account.   
These keys are based on the [LSP2-ERC725YJSONSchema](https://github.com/CJ42/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md) standard, and use the key type **[AddressMappingWithGrouping](https://github.com/CJ42/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#addressmappingwithgrouping)**

The KeyManager will read the permissions from the ERC725Account key value store, to determine if a key is allowed to perform certain actions.

#### AddressPermissions:Permissions:\<address\>

Holds the permissions for a key. See [Permission Values](#permissions-values-in-addresspermissions-Permissions-address) for details.

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

The following permissions are set in the [BitArray]() of the `AddressPermissions:Permissions:<address>` key in the following order:

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

![lsp6-key-manager-permissions-range](https://user-images.githubusercontent.com/31145285/129573621-33898637-80af-4937-884d-911372007c55.png)


### Methods



#### execute

Execute the a calldata payload on an ERC725 account.

The first 4 bytes of the `_data` payload MUST correspond to one of the function selector in the ERC725 account, such as `setData(...)`, `execute(...)` or `transferOwnership(...)`.

**returns:** `true` if the call on ERC725 account succeeded, `false` otherwise.

```solidity
function execute(bytes calldata _data) external payable returns (bool success_)
```

#### getNonce

Returns the current nonce to be used when using the [`executeRelayCall`](#executerelaycall)

```solidity
function getNonce(address _address) public view returns (uint256)
```

#### executeRelayCall

Allows anybody to execute `_data` payload on a ERC725 account, given they have a signed message from an executor.

`_signedFor`: MUST be the `KeyManager` contract.

`_nonce`: MUST be the nonce of the address that signed the message. This can be obtained via the `getNonce(address _address)` function.

`_signature`: bytes32 ethereum signature.


```solidity
function executeRelayCall(bytes calldata _data, address _signedFor, uint256 _nonce, bytes memory _signature) external payable returns (bool success_)
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

## Implementation

A implementation can be found in the [lukso-network/standards-scenarios](https://github.com/lukso-network/standards-scenarios/blob/master/contracts/Accounts/LSP3Account.sol);
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
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    event Executed(uint256 indexed _operation, address indexed _to, uint256 indexed  _value, bytes _data);
    
    event ValueReceived(address indexed sender, uint256 indexed value);
    
    event ContractCreated(address indexed contractAddress);
    
    event DataChanged(bytes32 indexed key, bytes value);
    
    event UniversalReceiver(address indexed from, bytes32 indexed typeId, bytes32 indexed returnedValue, bytes receivedData);
    
    
    // ERC173
    
    function owner() public view virtual returns (address);
    
    function transferOwnership(address newOwner) public virtual onlyOwner;
    
    
    // ERC725Account (ERC725X + ERC725Y)
    
    function execute(uint256 operationType, address to, uint256 value, bytes calldata data) external payable onlyOwner;
    
    function getData(bytes32 key) external view returns (bytes memory value);
    // LSP3 retrievable keys:
    // SupportedStandards:ERC725Account: 0xeafec4d89fa9619884b6b89135626455000000000000000000000000afdeb5d6
    // LSP3Profile: 0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5
    // LSP3IssuedAssets[]: 0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0
    // LSP1UniversalReceiverDelegate: 0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47
    
    function setData(bytes32 key, bytes calldata value) external onlyOwner;
    
    
    // ERC1271
    
    function isValidSignature(bytes32 _hash, bytes memory _signature) public view returns (bytes4 magicValue);
    
    
    // LSP1

    function universalReceiver(bytes32 typeId, bytes calldata data) external returns (bytes32);
    // IF `LSP1UniversalReceiverDelegate` key is set
    // THEN calls will be forwarded to the address given (UniversalReceiver even MUST still be fired)
}


```


## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
