---
lip: 4
title: Digital Asset Metadata
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2020-07-21
requires: ERC725Y, LSP2
---
 
## Simple Summary

This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores that describe a digital asset.

## Abstract

This standard, defines a set of key value stores that are useful to create digital asset.

## Motivation

This standard aims to create a better version of tokens and NFTs to allow more functionality to be attached to those assets, and the ability for those assets to change over time.
As NFTs mostly have a creator, those creators should be able to improve the assets (link better 3D files, as 3D file standards improve), or change attributes.
One could even think of a smart contract system that can increase attributes based on certain inputs automatically.

An LSP4 asset is controlled by a single `owner`, expected to be a ERC725 smart contract. This owner is able to `setData`, and therefore change values of keys, and can potentially mint new items.
 

## Specification

### ERC725Y Keys

#### SupportedStandards:LSP4DigitalAsset

The supported standard SHOULD be `LSP4DigitalAsset`

```json
{
    "name": "SupportedStandards:LSP4DigitalAsset",
    "key": "0xeafec4d89fa9619884b6b89135626455000000000000000000000000a4d96624",
    "keyType": "Mapping",
    "valueType": "bytes4",
    "valueContent": "0xa4d96624"
}
```

#### LSP4TokenName

A string representing the name for the token collection.

```json
  {
      "name": "LSP4TokenName",
      "key": "0xdeba1e292f8ba88238e10ab3c7f88bd4be4fac56cad5194b6ecceaf653468af1",
      "keyType": "Singleton",
      "valueType": "string",
      "valueContent": "String"
  }
```

This MUST NOT be changeable, and set only during initialization of the token.

#### LSP4TokenSymbol

A string representing the symbol for the token collection. Symbols should be UPPERCASE, without spaces and contain only ASCII.

```json
  {
      "name": "LSP4TokenSymbol",
      "key": "0x2f0a68ab07768e01943a599e73362a0e17a63a72e94dd2e384d2c1d4db932756",
      "keyType": "Singleton",
      "valueType": "string",
      "valueContent": "String"
  }
```

This MUST NOT be changeable, and set only during initialization of the token.


#### LSP4Metadata

The description of the asset.

```json
{
    "name": "LSP4Metadata",
    "key": "0x9afb95cacc9f95858ec44aa8c3b685511002e30ae54415823f406128b85b238e",
    "keyType": "Singleton",
    "valueType": "bytes",
    "valueContent": "JSONURL"
}
```

For construction of the JSONURL value see: [ERC725Y JSON Schema](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#jsonurl-example)

The linked JSON file SHOULD have the following format:

```js
{
    "LSP4Metadata": {
        "description": "string",
        "links": [ // links related to DigitalAsset
            {
                "title": "string", // a title for the link.
                "url": "string" // the link itself
            },
            ...
        ],  
        "images": [ // multiple images in different sizes, related to the DigitalAsset, image 0, should be the main image
            [
                {
                    "width": Number,
                    "height": Number,
                    "hashFunction": 'keccak256(bytes)',
                    "hash": 'string', // bytes32 hex string of the image hash
                    "url": 'string'
                },
                ...
            ],
            [...]
        ],
        "assets": [{
            "hashFunction": 'keccak256(bytes)',
            "hash": 'string',
            "url": 'string',
            "fileType": 'string'
        }]  
    }
}
```

Example:

```js
{
    LSP4Metadata: {
        description: 'The first digial golden pig.',
        links: [
            { title: 'Twitter', url: 'https://twitter.com/goldenpig123' },
            { title: 'goldenpig.org', url: 'https://goldenpig.org' }
        ],
        images: [
            [
                {
                    width: 1024,
                    height: 974,
                    hashFunction: 'keccak256(bytes)',
                    hash: '0xa9399df007997de92a820c6c2ec1cb2d3f5aa5fc1adf294157de563eba39bb6e',
                    url: 'ifps://QmW4wM4r9yWeY1gUCtt7c6v3ve7Fzdg8CKvTS96NU9Uiwr'
                }, 
                ... // more image sizes
            ],
            ... // more images
        ],
        assets: [{
            hashFunction: 'keccak256(bytes)',
            hash: '0x98fe032f81c43426fbcfb21c780c879667a08e2a65e8ae38027d4d61cdfe6f55',
            url: 'ifps://QmPJESHbVkPtSaHntNVY5F6JDLW8v69M2d6khXEYGUMn7N',
            fileType: 'fbx'
        }]  
    }
}
```

#### LSP4Creators[]

An array of ([ERC725Account](./LSP-0-ERC725Account.md)) addresses that defines the creators of the digital asset.

```json
{
    "name": "LSP4Creators[]",
    "key": "0x114bd03b3a46d48759680d81ebb2b414fda7d030a7105a851867accf1c2352e7",
    "keyType": "Array",
    "valueType": "uint256",
    "valueContent": "Number"
}
```

For more infos about how to access each index of the `LSP4Creators[]` array, see [ERC725Y JSON Schema > `keyType`: `Array`](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#array)

#### LSP4CreatorsMap

References the creator addresses for this asset.

The `valueContent` MUST be constructed as follows: `bytes8(indexNumber) + bytes4(standardInterfaceId)`. 
Where:
- `indexNumber` = the index in the [`LSP4Creators[]` Array](#lsp3issuedassets)
- `standardInterfaceId` = if the creator address is a smart contract, the [ERC165 interface ID](https://eips.ethereum.org/EIPS/eip-165) of the standard that the smart contract implements. Otherwise `0x00000000` in the case where the creator address is:
  - an Externally Owned Account, or 
  - a contract implementing an unknown ERC165 interface ID.

```json
{
    "name": "LSP4CreatorsMap:<address>",
    "key": "0x6de85eaf5d982b4e00000000<address>",
    "keyType": "Mapping",
    "valueType": "bytes",
    "valueContent": "Mixed"
}
```

## Rationale

There can be many token implementations, and this standard fills a need for common metadata describing issuers, creators and the token itself.

## Implementation

A implementation can be found in the [lukso-network/universalprofile-smart-contracts](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/main/contracts/LSP4DigitalAssetMetadata/LSP4DigitalAssetMetadata.sol);
The below defines the JSON interface of the `LSP4DigitalAsset`.

ERC725Y JSON Schema `LSP4DigitalAsset`:

```json
[
    {
        "name": "SupportedStandards:LSP4DigitalAsset",
        "key": "0xeafec4d89fa9619884b6b89135626455000000000000000000000000a4d96624",
        "keyType": "Mapping",
        "valueType": "bytes4",
        "valueContent": "0xa4d96624"
    },
    {
        "name": "LSP4TokenName",
        "key": "0xdeba1e292f8ba88238e10ab3c7f88bd4be4fac56cad5194b6ecceaf653468af1",
        "keyType": "Singleton",
        "valueType": "string",
        "valueContent": "String"
    },
    {
        "name": "LSP4TokenSymbol",
        "key": "0x2f0a68ab07768e01943a599e73362a0e17a63a72e94dd2e384d2c1d4db932756",
        "keyType": "Singleton",
        "valueType": "string",
        "valueContent": "String"
    }
    {
        "name": "LSP4Metadata",
        "key": "0x9afb95cacc9f95858ec44aa8c3b685511002e30ae54415823f406128b85b238e",
        "keyType": "Singleton",
        "valueType": "bytes",
        "valueContent": "JSONURL"
    },
    {
        "name": "LSP4CreatorsMap:<address>",
        "key": "0x6de85eaf5d982b4e00000000<address>",
        "keyType": "Mapping",
        "valueType": "bytes",
        "valueContent": "Mixed"
    },
    {
        "name": "LSP4Creators[]",
        "key": "0x114bd03b3a46d48759680d81ebb2b414fda7d030a7105a851867accf1c2352e7",
        "keyType": "Array",
        "valueType": "uint256",
        "valueContent": "Number"
    }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
