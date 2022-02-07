---
lip: 3
title: Universal Profile Metadata
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2019-07-12
requires: ERC165, ERC725Y, LSP1, LSP2, LSP5
---


## Simple Summary

This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores that are useful to describe a smart contract based profile.
 
## Abstract

This standard, defines a set of key value stores that are useful to create a public on-chain profile, based on an [ERC725Account](./LSP-0-ERC725Account.md).

## Motivation

This standard describes meta data that can be added to an [ERC725Account](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-0-ERC725Account.md), to give it a profile like character.

## Specification

Every contract that supports the Universal Profile standard SHOULD add the following [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) keys:

### ERC725Y Keys


#### SupportedStandards:LSP3UniversalProfile

The supported standard SHOULD be `LSP3UniversalProfile`

```json
{
    "name": "SupportedStandards:LSP3UniversalProfile",
    "key": "0xeafec4d89fa9619884b6b89135626455000000000000000000000000abe425d6",
    "keyType": "Mapping",
    "valueType": "bytes4",
    "valueContent": "0xabe425d6"
}
```


#### LSP3Profile

A JSON file that describes the profile information, including profile image, background image, description and related links.

```json
{
    "name": "LSP3Profile",
    "key": "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5",
    "keyType": "Singleton",
    "valueType": "bytes",
    "valueContent": "JSONURL"
}
```

For construction of the JSONURL value see: [ERC725Y JSON Schema](./LSP-2-ERC725YJSONSchema.md#JSONURL)

The linked JSON file SHOULD have the following format:

```js
{
    "LSP3Profile": {
        "name": "string", // a self chosen username (will likely be replaced by an ENS name)
        "description": "string" // A description, describing the person, company, organisation or creator of the profile.
        "links": [ // links related to the profile
            {
                "title": "string", // a title for the link.
                "url": "string" // the link itself
            },
            ...
        ],
        "tags": [ "string", "string", ... ], // tags related to the profile
        // below each image type SHOULD have different size of the same image, so that interfaces can choose which one to load for better loading performance
        "profileImage": [ // One image in different sizes, representing the profile.
            {  
                "width": Number,
                "height": Number,
                "hashFunction": 'keccak256(bytes)',
                "hash": 'string', // bytes32 hex string of the image hash
                "url": 'string'
            },
            ...
        ],
        "backgroundImage": [ // Image in different sizes, that can be used in conjunction with profile image to give a more personal look to a profile.
            { 
                "width": Number,
                "height": Number,
                "hashFunction": 'keccak256(bytes)',
                "hash": 'string', // bytes32 hex string of the image hash
                "url": 'string'
            },
            ...
        ]
    }
}
```

Example:

```js
{
    LSP3Profile: {
        name: 'frozeman',
        description: 'The inventor of ERC725 and ERC20...',
        links: [
            { title: 'Twitter', url: 'https://twitter.com/feindura' },
            { title: 'lukso.network', url: 'https://lukso.network' }
        ],
        tags: [ 'brand', 'public profile' ],
        profileImage: [
            {
                width: 1024,
                height: 974,
                hashFunction: 'keccak256(bytes)',
                hash: '0xa9399df007997de92a820c6c2ec1cb2d3f5aa5fc1adf294157de563eba39bb6e',
                url: 'ifps://QmW4wM4r9yWeY1gUCtt7c6v3ve7Fzdg8CKvTS96NU9Uiwr'
            },
            {
                width: 640,
                height: 609,
                hashFunction: 'keccak256(bytes)',
                hash: '0xb316a695125cb0566da252266cfc9d5750a740bbdffa86712bb17508e70e6a31',
                url: 'ifps://QmXGELsqGidAHMwYRsEv6Z4emzMggtc5GXZYGFK7r6zFBg'
            }
        ],
        backgroundImage: [
            {
                width: 1800,
                height: 1013,
                hashFunction: 'keccak256(bytes)',
                hash: '0x98fe032f81c43426fbcfb21c780c879667a08e2a65e8ae38027d4d61cdfe6f55',
                url: 'ifps://QmPJESHbVkPtSaHntNVY5F6JDLW8v69M2d6khXEYGUMn7N'
            },
            {
                width: 1024,
                height: 576,
                hashFunction: 'keccak256(bytes)',
                hash: '0xfce1c7436a77a009a97e48e4e10c92e89fd95fe1556fc5c62ecef57cea51aa37',
                url: 'ifps://QmZc9uMJxyUeUpuowJ7AD6MKoNTaWdVNcBj72iisRyM9Su'
            }
        ]
    }
}
```

#### LSP3IssuedAssets[]

An array of smart contract assets issued by the Universal Profile, like tokens (_e.g.: [LSP7 Digital Assets](./LSP-7-DigitalAsset)_) and NFTs (_e.g.: [LSP8 Identifiable Digital Assets](./LSP-8-IdentifiableDigitalAsset)_).

```json
{
    "name": "LSP3IssuedAssets[]",
    "key": "0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0",
    "keyType": "Array",
    "valueContent": "Address",
    "valueType": "address"
}
```

For more info about how to access each index of the `LSP3IssuedAssets[]` array, see: [ERC725Y JSON Schema > `keyType`: `Array`](./LSP-2-ERC725YJSONSchema.md#Array)

#### LSP3IssuedAssetsMap

References issued smart contract assets, like tokens (_e.g.: [LSP7 Digital Assets](./LSP-7-DigitalAsset)_) and NFTs (_e.g.: [LSP8 Identifiable Digital Assets](./LSP-8-IdentifiableDigitalAsset)_).

The `valueContent` MUST be constructed as follows: `bytes8(indexNumber) + bytes4(standardInterfaceId)`. Where:
- `indexNumber` = the index in the [`LSP3IssuedAssets[]` Array](#lsp3issuedassets)
- `standardInterfaceId` = the [ERC165 interface ID](https://eips.ethereum.org/EIPS/eip-165) of the standard that the token or asset smart contract implements (if the ERC165 interface ID is unknown, `standardInterfaceId = 0x00000000`).

```json
{
    "name": "LSP3IssuedAssetsMap:<address>",
    "key": "0x83f5e77bfb14241600000000<address>",
    "keyType": "Mapping",
    "valueType": "bytes",
    "valueContent": "Mixed"
}
```

For more infos about how to access each index of the `LSP3IssuedAssets[]` array, see [ERC725Y JSON Schema > `keyType`: `Array`](./LSP-2-ERC725YJSONSchema.md#Array)

## Rationale

Universal Profile's metadata is important for creating a verifiable public account that is the source of asset issuance,
or a verifiable public appearance. This metadata does not need to belong to a real world person, but gives the account a "recognisable face".

## Implementation

A implementation can be found in the [lukso-network/universalprofile-smart-contracts](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/main/contracts/UniversalProfile.sol);
The below defines the JSON interface of the `LSP3UniversalProfile`.

ERC725Y JSON Schema `LSP3UniversalProfile`:

```json
[
    {
        "name": "SupportedStandards:LSP3UniversalProfile",
        "key": "0xeafec4d89fa9619884b6b89135626455000000000000000000000000abe425d6",
        "keyType": "Mapping",
        "valueType": "bytes4",
        "valueContent": "0xabe425d6"
    },
    {
        "name": "LSP3Profile",
        "key": "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5",
        "keyType": "Singleton",
        "valueType": "bytes",
        "valueContent": "JSONURL"
    },
    {
        "name": "LSP3IssuedAssetsMap:<address>",
        "key": "0x83f5e77bfb14241600000000<address>",
        "keyType": "Mapping",
        "valueType": "bytes",
        "valueContent": "Mixed"
    },
    {
        "name": "LSP3IssuedAssets[]",
        "key": "0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0",
        "keyType": "Array",
        "valueType": "address",
        "valueContent": "Address"
    },

    // from LSP5 ReceivedAssets
    {
        "name": "LSP5ReceivedAssetsMap:<address>",
        "key": "0x812c4334633eb81600000000<address>",
        "keyType": "Mapping",
        "valueType": "bytes",
        "valueContent": "Mixed"
    },
    {
        "name": "LSP5ReceivedAssets[]",
        "key": "0x6460ee3c0aac563ccbf76d6e1d07bada78e3a9514e6382b736ed3f478ab7b90b",
        "keyType": "Array",
        "valueType": "address",
        "valueContent": "Address"
    },

    // from ERC725Account
    {
        "name": "LSP1UniversalReceiverDelegate",
        "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
        "keyType": "Singleton",
        "valueType": "address",
        "valueContent": "Address"
    }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
