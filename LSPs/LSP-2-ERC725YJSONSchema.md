---
lip: 2
title: ERC725Y JSON Schema
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2020-07-01
requires: ERC725Y
---


## Simple Summary
This schema describes how a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores can be described.

## Abstract
ERC725Y allow smart contracts to store key value stores (`bytes32` > `bytes`). These keys need to be separately standardised.

## Motivation
This schema, defines a way to make those key vale stores automatically parsable. 

This is of importance for (ERC725)[https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md] based smart contracts like
(LSP3-UniversalProfile)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-3-UniversalProfile.md] and (LSP4-DigitalCertificate)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-4-DigitalCertificate.md].


## Specification

To make ERC725Y keys readable we define the following data types:

- `type`: Describes the name of the key, SHOULD compromise of the Standards name + sub type. e.g: `LSP2Name`
- `key`: the keccak256 hash of the type name. This is the actual key that MUST be retrievable via `ERC725Y.getData(bytes32 key)`. e.g: `keccack256('LSP2Name') = 0xf9e26448acc9f20625c059a95279675b8f58ba4f06d262f83a32b4dd35dee019`
- `keyType`: Types that determine how the values should be interpreted. Valid types are:
    - `Singleton`: A single key value store.
    - `Array`: Determines that the value of this key is the array length, and subsequent keys exist consisting of `bytes16(keyHash) + uint128(arrayElementIndex)`.
- `valueContent`: The content in the returned value. Valid values are:
    - `String`: The content is a generic UTF8 string.
    - `Address`: The content is an address.
    - `Keccak256`: The content is an keccak256 32 bytes hash.
    - `URI`: The content is an URI mostly encoded as UTF8 string.
    - `Markdown`: The content is structured Markdown mostly encoded as UTF8 string.
    - `0x134...`: If the value type is a specific hash than the return value is expected to equal that hash (This is used for specific e.g. `LSP4Type`).
- `valueType`: The type the content MUST be decoded with.
    - `string`: The bytes are a UTF8 encoded string
    - `address`: The bytes are an 20 bytes address
    - `uint256`: The bytes are a 32 bytes uint256
    - `bytes32`: The bytes are a 32 bytes
    
Special key types exist for array elements:

- `elementKey`: The first 16 bytes of the `key` hash of the root key.
- `elementKeyType`: The type of the element, MUST be `ArrayElement` for an array element.
- `elementValueContent`: Same as `valueContent` above.
- `elementValueType`: Same as `valueType` above.


### Singleton

Below is an example of a Singleton key type:

```js
{
    "type": "LSPXyz",
    "key": "0x259e3e88c900103c8f1c9153b97074c18f74c5e4f27873f3a3ac6060dea44422", //keccak256(LSPXyz)
    "keyType": "Singleton",
    "valueContent": "String",
    "valueType": "string"
}
```

### Array

If you require multiple keys of the same key type they MUST be defined as follows:

- The keytype name MUST have a `[]` add and then hashed
- The key hash MUST contain the number of all elements, and is required to be updated when a new key element is added.

For all other elements:
- The first 16 bytes are the first 16 bytes of the key hash
- The second 16 bytes is a `uint128` of the number of the element
- Elements start at number `0`

#### Example
This would looks as follows for `LSP2IssuedAssets[]`:
- element number: key: `0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9`, value: `0x0000000000000000000000000000000000000000000000000000000000000002` (2 elements)
- element 1: key: `0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000000`, value: `0x123...` (element 0)
- element 2: key: `0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000001`, value: `0x321...` (element 1)
...


Below is an example of an Array key type:

```js
{
    "type": "LSP2IssuedAssets[]",
    "key": "0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9",
    "keyType": "Array",
    "valueContent": "ArrayLength",
    "valueType": "uint256",
    "elementKey": "0xb8c4a0b76ed8454e098b20a987a980e6",
    "elementKeyType": "ArrayElement",
    "elementValue": "Address",
    "elementValueType": "address"
}
```

Example:
```solidity
key: keccak256('LSP2IssuedAssets[]') = 0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9
value: uint256 (array length) e.g. 0x0000000000000000000000000000000000000000000000000000000000000002

// array items

// element 0
key: 0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000000
value: 0xcafecafecafecafecafecafecafecafecafecafe

// element 1
key: 0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000001
value: 0xcafecafecafecafecafecafecafecafecafecafe
```

## Rationale
The structure of the key value layout as JSON allows interfaces to auto decode these key values as they will know how to decode them.   
`keyType` always describes *how* a key MUST be treated.    
and `valueType` describes how the value MUST be decoded. And `value` always describes *how* a value SHOULD be treated.


## Implementation

To allow interfaces to auto decode an ERC725Y key value store and ERC725Y JSON Interface as the following can ge given:

Example ERC725Y JSON Interface:
```json
[
    {
        "type": "LSP2Name",
        "key": "0xf9e26448acc9f20625c059a95279675b8f58ba4f06d262f83a32b4dd35dee019",
        "keyType": "Singleton",
        "valueContent": "String",
        "valueType": "string"
    },
    {
        "type": "LSP2Links",
        "key": "0xb95a64d66e66f5c0cd985e2c3cc93fbea7f9259eadbe81c3ab0ff4e68df564d6",
        "keyType": "Singleton",
        "valueContent": "URI",
        "valueType": "string"
    },
    {
        "type": "LSP2IssuedAssets[]",
        "key": "0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9",
        "keyType": "Array",
        "valueContent": "ArrayLength",
        "valueType": "uint256",
        "elementKey": "0xb8c4a0b76ed8454e098b20a987a980e6",
        "elementKeyType": "ArrayElement",
        "elementValueContent": "Address",
        "elementValueType": "address"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
