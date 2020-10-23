---
lip: 4
title: Digital Certificate
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2020-07-21
requires: LSP2, LSP1, ERC165, ERC725Y, ERC777
---

## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores that describe a digital asset.

## Abstract
This standard, defines a set of key value stores that are useful to create digital asset, based on an (ERC777)[https://github.com/ethereum/EIPs/blob/master/EIPS/eip-777.md].

Additionally this standards modifies ERC777 `decimals` return value. It is suggested to modify ERC777 to work (LSP1-UniversalReceiver)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md]
to allow the asset to be received by any smart contract implementing (LSP1)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md], including an (LSP2 Account)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-3-UniversalProfile.md].


## Motivation
This standard aims to create a better version of NFTs (NFT 2.0) to allow more functionality to be attached to those assets, and the ability for those assets to change over time.
As NFTs mostly have a creator, those creators should be able to improve the assets (link better 3D files, as 3D file standards improve), or change attributes.
One could even think of a smart contract system that can increase attributes based on certain inputs automatically.

An LSP4 asset is controlled by a single `owner`, like an ERC725 smart contract. This owner is able to `setData`, and therefore change values of keys, and can potentially mint new items.
 

## Specification

Every contract that supports to the Digital Certificate standard SHOULD implement:

### ERC777 modifications

To be compliant with this standard the required ERC777 needs to be modified as follows:

#### decmials

 ```solidity
 decmials() external returns (uint8)
 ```

MUST return `0`.

NFTs are non-fungible and therefore the smallest unit is 1.

#### Asset names

To define the Assets name and Symbol, ERC777 default `name` and `symbol` are used.

Symbols should be UPPERCASE, without spaces and contain only ASCII. 

Example:
```js
name() => 'My Amazing Asset'
symbol() => 'MYASSET01'
```

#### universalReceiver

Instead of relying on 1820, the ERC777 smart contract COULD expect receivers to implement LSP1.
This is especially recommended for the LUKSO network, to improve the overall compatibility and future proofness of assets and universal profiles based on (LSP1)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-3-UniversalProfile.md]. 


### Keys

#### LSP4Type

The type of asset, as defined in sub standards. These sub standards can define specifc asset formats,
or other extra keys to be present in the digital certificate. 

```json
{
    "name": "LSP4Type",
    "key": "0x4cd61d42bec47e5be0fa92cb767c0a01f91af591cee430423287127fe58b66ca",
    "keyType": "Singleton",
    "valueContent": "Keccak256",
    "valueType": "bytes32"
}
```

Example:
```solidity
key: keccak256('LSP4Type') = 0x4cd61d42bec47e5be0fa92cb767c0a01f91af591cee430423287127fe58b66ca
value: keccak256('LSP5DigitalCloth') = 0x400823a66792632b83426dae64ca619a7b8ffcde4f406c2fb8fd5d0a62286b42
```

#### LSP4Description (Optional)

The description of the asset.

```json
{
    "name": "LSP4Description",
    "key": "0xfc5327884a7fb1912dcdd0d78d7e6753f03e61a8e0b845a4b62f5efde472d0a8",
    "keyType": "Singleton",
    "valueContent": "URI",
    "valueType": "string"
}
```

Example:
```solidity
key: keccak256('LSP4Description') = 0xfc5327884a7fb1912dcdd0d78d7e6753f03e61a8e0b845a4b62f5efde472d0a8
value: web3.utils.utf8ToHex('ipfs://QmQ2CN2VUdb5nVAz28R47aWP6BjDLPGNJaSBniBuZRs3Jt') = 0x697066733a2f2f516d5132434e3256556462356e56417a323852343761575036426a444c50474e4a6153426e6942755a5273334a74
```

The linked JSON file MUST have the following format:
```js
{
    "LSP4Description": "Some description text..."
}
```

#### LSP4Images (Optional)

Images that are related to the NFT. This can be one or multiple.
The first image SHOULD be seen as the main image.

```json
{
    "name": "LSP4Images",
    "key": "0x150834e6d4fd704dc914e5372942f0615863fd9d206030643c2a6391dc6ddbf1",
    "keyType": "Singleton",
    "valueContent": "URI",
    "valueType": "string"
}
```

Example:
```solidity
key: keccak256('LSP4Images') = 0x150834e6d4fd704dc914e5372942f0615863fd9d206030643c2a6391dc6ddbf1
value: web3.utils.utf8ToHex('ipfs://QmQ2CN2VUdb5nVAz28R47aWP6BjDLPGNJaSBniBuZRs3Jt') = 0x697066733a2f2f516d5132434e3256556462356e56417a323852343761575036426a444c50474e4a6153426e6942755a5273334a74
```

The linked JSON file MUST have the following format:
```js
{
    "LSP4Images": [
        {
            "title": "string", // (optional)
            "source": "URI",
            "hash": "keccak256(file)"
        },
        ...
    ]
}
```

#### LSP4Assets (Optional)

Asset files that are attached related to the NFT. This can be one or multiple.
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
            "type": "fileTypeName",
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
The below defines the JSON interface of the `LSP4DigitalCertificate`.

ERC725Y JSON Schema `LSP4DigitalCertificate`:
```json
[
    {
        "name": "LSP4Type",
        "key": "0x4cd61d42bec47e5be0fa92cb767c0a01f91af591cee430423287127fe58b66ca",
        "keyType": "Singleton",
        "valueContent": "Keccak256",
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
