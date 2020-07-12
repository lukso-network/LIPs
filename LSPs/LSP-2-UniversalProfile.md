---
lip: 2
title: Universal Profile
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2019-07-12
requires: ERC725Account, ERC1271, LSP1
---


## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores that are useful to describe a smart contract based profile.

## Abstract
ERC725Y allow smart contracts to store key value stores (`bytes32` > `bytes`). These keys need to be separately standardised.

This standard, defines a set of key value stores that are useful to create a public on-chain profile, based on an (ERC725Account)[https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md].
Additionally this standards expects (LSP1-UniversalReceiver)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md] to be implemented as well, to make the smart contract account future proof.

## Motivation
To make the usage of blockchain infrastructure easier and allow smart contractbased account to be more than just a store of assets.
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

### Keys

#### LSP2_links

```json
{
    "key": "0x2e3132fa655a0bf4164f7625f0ee4bf895a765a984dcc198dcfe1610d2bdc398", //keccak256('LSP2Links[]')
    "keyType": "Array",
    "value": "uint256",
    "valueType": "ArrayLength",
    "elementKey": "0x2e3132fa655a0bf4164f7625f0ee4bf800000000000000000000000000000000", //bytes16(keccak256('LSP2Links[]')) + uint128(element count)
    "elementKeyType": "ArrayElement",
    "elementValue": "String",
    "elementValueType": "Markdown"
}
```


```solidity
key: keccak256('LSP2Links[]') = 0x2e3132fa655a0bf4164f7625f0ee4bf895a765a984dcc198dcfe1610d2bdc398
value: uint256 (array length) e.g. 0x0000000000000000000000000000000000000000000000000000000000000002

// array items

// example link
key: 0x2e3132fa655a0bf4164f7625f0ee4bf800000000000000000000000000000000
value: web3.utils.utf8ToHex('https://twitter.com/myusername') = 0x68747470733a2f2f747769747465722e636f6d2f6d79757365726e616d65

// example markdown link
key: 0x2e3132fa655a0bf4164f7625f0ee4bf800000000000000000000000000000001
value: web3.utils.utf8ToHex('[My Twitter Page](https://twitter.com/myusername)') = 0x5b4d79205477697474657220506167655d2868747470733a2f2f747769747465722e636f6d2f6d79757365726e616d6529
```

## Rationale
The structure of the key value layout as JSON allows interfaces to auto decode these key values as they will know how to decode them.
`**Type` alwasy describes *how* a key/value pair can be treated.

In the above standard we define 4 types:
- **keyType** `Array`: Tells the interface to look for Array elements using the `bytes16(key)` + `uint128(element count)`
- **valueType** `ArrayLength`: Tells the interface how many array elements to expect
- **elementKeyType** `ArrayElement`: Tells the interface that the key is an array element and must be constructed using `bytes16(key)` + `uint128(element count)`
- **elementValueType** `Markdown`: Tells the interface to treat the value content as markdown


## Implementation

The below defines the JSON interface of the ERC725Y account:

```json
[{
     "key": "0x2e3132fa655a0bf4164f7625f0ee4bf895a765a984dcc198dcfe1610d2bdc398", //keccak256('LSP2Links[]')
     "keyType": "Array",
     "value": "uint256",
     "valueType": "ArrayLength",
     "elementKey": "0x2e3132fa655a0bf4164f7625f0ee4bf800000000000000000000000000000000", //bytes16(keccak256('LSP2Links[]')) + uint128(element count)
     "elementKeyType": "ArrayElement",
     "elementValue": "String",
     "elementValueType": "Markdown"
 }]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
