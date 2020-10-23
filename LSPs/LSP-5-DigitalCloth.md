---
lip: 5
title: Digital Cloth
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2020-07-21
requires: LSP4
---

## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores that describe an asset of digital cloth.

## Abstract
This standard describes a digital cloth asset that can be owned and used within different virtual environments.
This standard requires [LSP4](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-4-DigitalCertificate.md)

## Motivation
Digital cloths are a new form for asset that allow creatives and designers to create a new type of digital asset,
that can live in different environments (games, social VR spaces, etc.) and also used as a new form of AR filter.

## Specification

Every contract that supports to the Digital Cloth standard SHOULD implement additional to [LSP4](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-4-DigitalCertificate.md)
the following keys:

### Keys

#### LSP4Type

The `LSP4Type` has to be set to `0x400823a66792632b83426dae64ca619a7b8ffcde4f406c2fb8fd5d0a62286b42` (`keccak256('LSP5DigitalCloth')`)

See [LSP4](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-4-DigitalCertificate.md) for details.

Example:
```solidity
LSP5DigitalCloth.getData(0x4cd61d42bec47e5be0fa92cb767c0a01f91af591cee430423287127fe58b66ca) // keccak256('LSP4Type') 
= 0x400823a66792632b83426dae64ca619a7b8ffcde4f406c2fb8fd5d0a62286b42 //keccak256('LSP5DigitalCloth')
```

#### LSP4Assets

Asset files that are attached should be a `zip` file of exported `glTF` assets.
The first asset SHOULD be seen as the main asset.

```json
{
    "name": "LSP4Assets",
    "key": "0x5fa8d8247112f88f035d746484935915caa778a049c0927c00bb1c2696497a95",
    "keyType": "Singleton",
    "valueContent": "URI",
    "valueType": "string"
}
```

Example:
```solidity
key: keccak256('LSP4Assets') = 0x5fa8d8247112f88f035d746484935915caa778a049c0927c00bb1c2696497a95
value: web3.utils.utf8ToHex('ipfs://QmQ2CN2VUdb5nVAz28R47aWP6BjDLPGNJaSBniBuZRs3Jt') = 0x697066733a2f2f516d5132434e3256556462356e56417a323852343761575036426a444c50474e4a6153426e6942755a5273334a74
```

The linked JSON file MUST have the following format:
```js
{
    "LSP4Assets": [
        {
            "title": "string", // (optional)
            "type": "gltf",
            "source": "URI",
            "hash": "keccak256(file)"
        },
        ...
    ]
}
```

## Rationale

## Implementation

A implementation can be found in the [lukso-network/standards-scenarios](https://github.com/lukso-network/standards-scenarios/blob/master/contracts/DigitalCertificate/LSP4DigitalCertificate.sol);
The below defines the JSON interface of the `LSP5DigitalCLoth`.

ERC725Y JSON Schema `LSP5DigitalCLoth`:
```json
[
    {
        "name": "LSP4Type",
        "key": "0x4cd61d42bec47e5be0fa92cb767c0a01f91af591cee430423287127fe58b66ca",
        "keyType": "Singleton",
        "valueContent": "0x400823a66792632b83426dae64ca619a7b8ffcde4f406c2fb8fd5d0a62286b42",
        "valueType": "bytes32"
    },
    {
        "name": "LSP4Description",
        "key": "0xfc5327884a7fb1912dcdd0d78d7e6753f03e61a8e0b845a4b62f5efde472d0a8",
        "keyType": "Singleton",
        "valueContent": "URI",
        "valueType": "string"
    },
    {
        "name": "LSP4Images",
        "key": "0x150834e6d4fd704dc914e5372942f0615863fd9d206030643c2a6391dc6ddbf1",
        "keyType": "Singleton",
        "valueContent": "URI",
        "valueType": "string"
    },
    {
        "name": "LSP4Assets",
        "key": "0x5fa8d8247112f88f035d746484935915caa778a049c0927c00bb1c2696497a95",
        "keyType": "Singleton",
        "valueContent": "URI",
        "valueType": "string"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
