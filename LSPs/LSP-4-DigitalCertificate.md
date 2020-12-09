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


#### SupportedStandards

The supported standard SHOULD be `LSP4DigitalCertificate`

```solidity
key: '0xeafec4d89fa9619884b6b89135626455000000000000000000000000abf0613c'
value: '0xabf0613c'
```

#### LSP4Metadata

The description of the asset.

```json
{
    "name": "LSP4Metadata",
    "key": "0x9afb95cacc9f95858ec44aa8c3b685511002e30ae54415823f406128b85b238e",
    "keyType": "Singleton",
    "valueContent": "JSONURL",
    "valueType": "bytes"
}
```

For construction of the JSONURL value see: [ERC725Y JSON Schema](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#jsonurl-example)

The linked JSON file SHOULD have the following format:
```js
{
    "LSP4Metadata": {
        "description": "string",
        "links": [ // links related to DigitalCertificate
            {
                "title": "string", // a title for the link.
                "url": "string" // the link itself
            },
            ...
        ],  
        "images": [ // multiple images in different sizes, related to the DigitalCertificate, image 0, should be the main image
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
            hash: '0x98fe032f81c43426fbcfb21c780c879667a08e2a65e8ae38027d4d61cdfe6f55
            url: 'ifps://QmPJESHbVkPtSaHntNVY5F6JDLW8v69M2d6khXEYGUMn7N',
            fileType: 'fbx'
        }]  
    }
}
```

#### LSP4Creators[]

An array of (ERC725Account) addresses of creators, 

```json
{
    "name": "LSP4Creators[]",
    "key": "0x114bd03b3a46d48759680d81ebb2b414fda7d030a7105a851867accf1c2352e7",
    "keyType": "Array",
    "valueContent": "Number",
    "valueType": "uint256",
    "elementValueContent": "Address",
    "elementValueType": "address"
}
```

For construction of the Asset Keys see: [ERC725Y JSON Schema](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#array)


## Rationale

## Implementation

A implementation can be found in the [lukso-network/standards-scenarios](https://github.com/lukso-network/standards-scenarios/blob/master/contracts/DigitalCertificate/LSP4DigitalCertificate.sol);
The below defines the JSON interface of the `LSP4DigitalCertificate`.

ERC725Y JSON Schema `LSP4DigitalCertificate`:
```json
[
    {
        "name": "SupportedStandards:LSP4DigitalCertificate",
        "key": "0xeafec4d89fa9619884b6b89135626455000000000000000000000000abf0613c",
        "keyType": "Mapping",
        "valueContent": "0xabf0613c",
        "valueType": "bytes"
    },
    {
        "name": "LSP4Metadata",
        "key": "0x9afb95cacc9f95858ec44aa8c3b685511002e30ae54415823f406128b85b238e",
        "keyType": "Singleton",
        "valueContent": "JSONURL",
        "valueType": "bytes"
    },
    {
        "name": "LSP4Creators[]",
        "key": "0x114bd03b3a46d48759680d81ebb2b414fda7d030a7105a851867accf1c2352e7",
        "keyType": "Array",
        "valueContent": "Number",
        "valueType": "uint256",
        "elementValueContent": "Address",
        "elementValueType": "address"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
