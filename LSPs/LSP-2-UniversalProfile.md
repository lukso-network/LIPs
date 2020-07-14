---
lip: 2
title: Universal Profile
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2019-07-12
requires: ERC725Y
---


## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores that are useful to describe a smart contract based profile.

## Abstract
ERC725Y allow smart contracts to store key value stores (`bytes32` > `bytes`). These keys need to be separately standardised.

This standard, defines a set of key value stores that are useful to create a public on-chain profile, based on an (ERC725Account)[https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md].
Additionally this standards expects (LSP1-UniversalReceiver)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md] to be implemented as well, to make the smart contract account future proof.

## Motivation
To make the usage of blockchain infrastructure easier and allow smart contract based accounts to be more than just a store of assets.
We need to define standards that make these accounts easier to use and interactable. Therefore we need to define:

- Ways to make security and access to these accounts upgradeable through the use of ERC173 and ERC725X
- Allow these accounts to store information and reference other related systems through the use of ERC725Y
- Define a number of key values stores that any interface can expect to present through this standard (LSP2)  

On top of that many token standards (like ERC721, ERC223 and ERC777) do define their own way of calling contracts.
To rectify this, we propose the usage of [LSP1-UniversalReceiver](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md) and modified versions of ERC777 and other token standards,
to be used with this standard. This is obviously easier on EVM networks that have not yet an established ecosystem like LUKSO, than on the Ethereum mainnet.
Though we still think this addition is extremly necessary even on networks like Ethereum, as more standards are appearing that require to notify other smart contracts. 


## Specification

Every contract that supports to the Universal Profile standard SHOULD implement:

Every value has to be store as key `hash of bytes32` and value `bytes`, when we talk in the specification about other types for the value,
those need to be converted by and from the interface to `bytes` before stored in the smart contract.

### Keys

#### LSP2Name

The name of the profile, can be a username, company name, or other title.

```json
{
    "type": "LSP2Name",
    "key": "0xf9e26448acc9f20625c059a95279675b8f58ba4f06d262f83a32b4dd35dee019",
    "keyType": "Singleton",
    "value": "String",
    "valueType": "string"
}
```

Example:
```solidity
key: keccak256('LSP2Name') = 0xf9e26448acc9f20625c059a95279675b8f58ba4f06d262f83a32b4dd35dee019
value: web3.utils.utf8ToHex('myamazingname') = 0x6d79616d617a696e676e616d65
```

#### LSP2Profile

A JSON file that describes the profile information, like profile image, background image and description.

```json
{
    "type": "LSP2Profile",
    "key": "0x44367a5abdaa20de0422835e8abcbc096050530cc95916ff41e3341318b90853",
    "keyType": "Singleton",
    "value": "URI",
    "valueType": "string"
}
```

The linked JSON file MUST have the following format:
```json
{
    "profileImage": "URI", // The profile image represents one image representing the profile, like a person image, a company logo or avatar.
    "backgroundImage": "URI", // The background is an image that can be used in conjunction with profile image to give a more personal look to the profile.
                              // Websites displaying the profile have to choose how or if, to use this image.
    "description": "string" // A description, describing the person, company, organisation and/or creator of the profile.
}
```

#### LSP2Links

A JSON file describing a set of links related to this profile.

```json
{
    "type": "LSP2Links",
    "key": "0xb95a64d66e66f5c0cd985e2c3cc93fbea7f9259eadbe81c3ab0ff4e68df564d6",
    "keyType": "Singleton",
    "value": "URI",
    "valueType": "string"
}
```

The linked JSON file MUST have the following format:
```json
{
    "LSP2Links": [
        {
            "title": "string",
            "link": "URI"
        },
        ...
    ]
}
```

#### LSP2IssuedAssets[]

References issued smart contract assets, like tokens and NFTs.

```json
{
    "type": "LSP2IssuedAssets[]",
    "key": "0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9",
    "keyType": "Array",
    "value": "ArrayLength",
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

In the above standard we define 3 `key types`:
- `Singleton`: Tells the interface that the key is a hash of the key name `keccak256(keyName)`
- `Array`: Tells the interface to look for Array elements using the `bytes16(keccak256(keyName))` + `uint128(element count)`
- `ArrayElement`: Tells the interface that the key is constructed using the `bytes16(keccak256(keyName))` + `uint128(element count)`

In the above standard we define `values`:
- `Address`: The value content is an address.
- `URI`: The value content is a utf8 encoded URI.
- `Markdown`: The value content is a utf8 encoded string, that can contain Markdown elements.

### Multiple keys of the same type

If you require multiple keys of the same key type they MUST be defined as follows:

- The keytype name MUST have a `[]` add and then hashed
- The key hash MUST contain the number of all elements, and is required to be updated when a new key element is added.

For all other elements:
- The first 16 bytes are the first 16 bytes of the key hash
- The second 16 bytes is a `uint128` of the number of the element
- Elements start at number `0`

#### Example
This would looks as follows for `LSPXXXMyNewKeyType[]` (keccak256: `0x4f876465dbe22c8495f4e4f823d846957ddb8ce6006afe66ddc5bac4f0626767`): 
- element number: key: `0x4f876465dbe22c8495f4e4f823d846957ddb8ce6006afe66ddc5bac4f0626767`, value: `0x0000000000000000000000000000000000000000000000000000000000000002` (2 elements)
- element 1: key: `0x4f876465dbe22c8495f4e4f823d8469500000000000000000000000000000000`, value: `0x123...` (element 0)
- element 2: key: `0x4f876465dbe22c8495f4e4f823d8469500000000000000000000000000000001`, value: `0x321...` (element 1)
...


## Implementation

The below defines the JSON interface of the ERC725Y account.

ERC725Y JSON Interface:
```json
[
    {
        "type": "LSP2Name",
        "key": "0xf9e26448acc9f20625c059a95279675b8f58ba4f06d262f83a32b4dd35dee019",
        "keyType": "Singleton",
        "value": "String",
        "valueType": "string"
    },
    {
        "type": "LSP2Profile",
        "key": "0x44367a5abdaa20de0422835e8abcbc096050530cc95916ff41e3341318b90853",
        "keyType": "Singleton",
        "value": "URI",
        "valueType": "string"
    },
    {
        "type": "LSP2Links",
        "key": "0xb95a64d66e66f5c0cd985e2c3cc93fbea7f9259eadbe81c3ab0ff4e68df564d6",
        "keyType": "Singleton",
        "value": "URI",
        "valueType": "string"
    },
    {
        "type": "LSP2IssuedAssets[]",
        "key": "0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9",
        "keyType": "Array",
        "value": "ArrayLength",
        "valueType": "uint256",
        "elementKey": "0xb8c4a0b76ed8454e098b20a987a980e6",
        "elementKeyType": "ArrayElement",
        "elementValue": "Address",
        "elementValueType": "address"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
