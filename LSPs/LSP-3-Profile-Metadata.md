---
lip: 3
title: Profile Metadata
author: Fabian Vogelsteller <fabian@lukso.network>
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2019-07-12
requires: ERC165, ERC725Y, LSP1, LSP2, LSP5, LSP12
---

## Simple Summary

This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores that are useful to describe a smart contract based profile.

## Abstract

This standard, defines a set of data key-value pairs that are useful to create a public on-chain profile, based on an [ERC725Account](./LSP-0-ERC725Account.md).

## Motivation

This standard describes meta data that can be added to an [ERC725Account](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-0-ERC725Account.md), to give it a profile like character.

## Specification

Every contract that supports the Universal Profile standard SHOULD add the following [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data keys:

### ERC725Y Data Keys

#### SupportedStandards:LSP3Profile

The supported standard SHOULD be `LSP3Profile`

```json
{
  "name": "SupportedStandards:LSP3Profile",
  "key": "0xeafec4d89fa9619884b600005ef83ad9559033e6e941db7d7c495acdce616347",
  "keyType": "Mapping",
  "valueType": "bytes4",
  "valueContent": "0x5ef83ad9"
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
  "valueContent": "VerifiableURI"
}
```

For construction of the VerifiableURI value see: [ERC725Y VerifiableURI Schema](./LSP-2-ERC725YJSONSchema.md#VerifiableURI)

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
        "avatar": [ // a 3D file avatar mostly in FBX and/or OBJ format, multiple file formats of an avatar can be added
            { // example of a hash based avatar verification
                "verification": {
                    "method": 'keccak256(bytes)',
                    "data": 'string', // bytes32 hash of the file
                },
                "url": 'string',
                "fileType": 'string'
            },
            { // example of a signature based avatar verification
                "verification": {
                    "method": 'ecdsa',
                    "data": 'string', // signer that signed the bytes of the file
                    "source": 'string' // e.g url returning the signature of the signed file
                },
                "url": 'string',
                "fileType": 'string'
            },
            { // example of a NFT/smart contract based avatar
                "address": Address, // the address of an LSP7 or LSP8
                "tokenId": 32bytes  // (optional) if token contract is an LSP7
            }
        ]
        // below each image type SHOULD have different size of the same image, so that interfaces can choose which one to load for better loading performance
        "profileImage": [ // One image in different sizes, representing the profile.
            { // example of a hash based image verification
                "width": Number,
                "height": Number,
                "url": 'string',
                "verification": {
                    "method": 'keccak256(bytes)',
                    "data": 'string', // bytes32 hash of the image
                }
            },
            { // example of a signature based image verification
                "width": Number,
                "height": Number,
                "url": 'string',
                "verification": {
                    "method": 'ecdsa',
                    "data": 'string', // signer that signed the bytes of the image
                    "source": 'string' // e.g url returning the signature of the signed image
                }
            },
            { // example of a NFT/smart contract based image
                "address": Address, // the address of an LSP7 or LSP8
                "tokenId": 32bytes  // (optional) if token contract is an LSP7
            }
        ],
        "backgroundImage": [ // Image in different sizes, that can be used in conjunction with profile image to give a more personal look to a profile.
            { // example of a hash based image verification
                "width": Number,
                "height": Number,
                "url": 'string',
                "verification": {
                    "method": 'keccak256(bytes)',
                    "data": 'string', // bytes32 hash of the image
                }
            },
            { // example of a signature based image verification
                "width": Number,
                "height": Number,
                "url": 'string',
                "verification": {
                    "method": 'ecdsa',
                    "data": 'string', // signer that signed the bytes of the image
                    "source": 'string' // e.g url returning the signature of the signed image
                }
            },
            { // example of a NFT/smart contract based image
                "address": Address, // the address of an LSP7 or LSP8
                "tokenId": 32bytes  // (optional) if token contract is an LSP7
            }
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
        avatar: [
            {
              verification: {
                method: 'keccak256(bytes)',
                data: '0x98fe032f81c43426fbcfb21c780c879667a08e2a65e8ae38027d4d61cdfe6f55',
              },
              url: 'ifps://QmPJESHbVkPtSaHntNVY5F6JDLW8v69M2d6khXEYGUMn7N',
              fileType: 'fbx'
            }
        ],
        profileImage: [
            {
                width: 1800,
                height: 1013,
                url: 'ifps://QmPJESHbVkPtSaHntNVY5F6JDLW8v69M2d6khXEYGUMn7N',
                verification: {
                    method: 'keccak256(bytes)',
                    data: '0x98fe032f81c43426fbcfb21c780c879667a08e2a65e8ae38027d4d61cdfe6f55',
                }
            },
            // OR use an NFT as profile image
            {
                "address": 0x1231c7436a77a009a97e48e4e10c92e89fd95fe15, // the address of an LSP7 or LSP8
                "tokenId": 0xdDe1c7436a77a009a97e48e4e10c92e89fd95fe1556fc5c62ecef57cea51aa37  // (optional) if token contract is an LSP7
            },
        ],
        backgroundImage: [
            {
                width: 1800,
                height: 1013,
                url: 'ifps://QmPJESHbVkPtSaHntNVY5F6JDLW8v69M2d6khXEYGUMn7N',
                verification: {
                    method: 'keccak256(bytes)',
                    data: '0x98fe032f81c43426fbcfb21c780c879667a08e2a65e8ae38027d4d61cdfe6f55',
                }
            },
            {
                width: 1024,
                height: 576,
                url: 'ifps://QmZc9uMJxyUeUpuowJ7AD6MKoNTaWdVNcBj72iisRyM9Su',
                verification: {
                    method: 'keccak256(bytes)',
                    data: '0xfce1c7436a77a009a97e48e4e10c92e89fd95fe1556fc5c62ecef57cea51aa37',
                }
            }
        ]
    }
}
```

## Rationale

Profile's metadata is important for creating a verifiable public account that is the source of asset issuance,
or a verifiable public appearance. This metadata does not need to belong to a real world person, but gives the account a "recognisable face".

## Implementation

An implementation can be found in the [lukso-network/universalprofile-smart-contracts](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/main/contracts/UniversalProfile.sol);
The below defines the JSON interface of the `LSP3Profile`.

ERC725Y VerifiableURI Schema `LSP3Profile`:

```json
[
  {
    "name": "SupportedStandards:LSP3Profile",
    "key": "0xeafec4d89fa9619884b600005ef83ad9559033e6e941db7d7c495acdce616347",
    "keyType": "Mapping",
    "valueType": "bytes4",
    "valueContent": "0x5ef83ad9"
  },
  {
    "name": "LSP3Profile",
    "key": "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5",
    "keyType": "Singleton",
    "valueType": "bytes",
    "valueContent": "VerifiableURI"
  },
  // from LSP12 IssuedAssets
  {
    "name": "LSP12IssuedAssets[]",
    "key": "0x7c8c3416d6cda87cd42c71ea1843df28ac4850354f988d55ee2eaa47b6dc05cd",
    "keyType": "Array",
    "valueType": "address",
    "valueContent": "Address"
  },
  {
    "name": "LSP12IssuedAssetsMap:<address>",
    "key": "0x74ac2555c10b9349e78f0000<address>",
    "keyType": "Mapping",
    "valueType": "(bytes4,uint128)",
    "valueContent": "(Bytes4,Number)"
  },

  // from LSP5 ReceivedAssets
  {
    "name": "LSP5ReceivedAssets[]",
    "key": "0x6460ee3c0aac563ccbf76d6e1d07bada78e3a9514e6382b736ed3f478ab7b90b",
    "keyType": "Array",
    "valueType": "address",
    "valueContent": "Address"
  },
  {
    "name": "LSP5ReceivedAssetsMap:<address>",
    "key": "0x812c4334633eb816c80d0000<address>",
    "keyType": "Mapping",
    "valueType": "(bytes4,uint128)",
    "valueContent": "(Bytes4,Number)"
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
