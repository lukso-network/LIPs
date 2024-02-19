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

This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data key-value pairs that describe a digital asset.

## Abstract

This standard defines a set of data key-value pairs. These pairs are standardized for storing metadata about a digital asset. The metadata can point to the asset's appearance, name, symbol, and other relevant information. The purpose is to provide a consistent and comprehensive method for representing digital assets.

These data key-value pairs are defined according to the [LSP2-ERC725YJSONSchema](./LSP-2-ERC725YJSONSchema.md) standard and can be stored and retreived from any ERC725Y based contract.

## Motivation

The existing metadata representation in popular token standards such as ERC20, ERC721, and ERC1155 is both limited and lacking in standardization. This lack of uniformity becomes increasingly problematic with the emergence of new token standards. As we witness the rise of new token standards, the need for a standardized approach to metadata becomes increasingly crucial.

Currently, these standards are limited to basic metadata functions such as `name()`, `symbol()`, and `tokenURI(tokenId)`. However, the essential metadata for a token that should be stored on-chain encompasses much more. It can include a URI for the entire collection instead of individual tokenIds, the addresses of the creators, the community supporting the token, its representation, and other significant aspects. Standardization is essential for ensuring interfaces and websites can uniformly interpret and display the diverse types of digital assets.

By having a flexible storage to store any kind of information for the asset and defining relevant metadata keys for it, we can enrich these assets with more comprehensive and meaningful information. This enhancement allows for the emergence of more sophisticated and versatile tokens and NFTs than those currently available.

## Specification

The token standards implementing the [LSP4-DigitalAssetMetadata](#) standard are expected to include the [ERC725Y](#) functions to store the data keys defined below:

### ERC725Y Data Keys

#### SupportedStandards:LSP4DigitalAsset

```json
{
  "name": "SupportedStandards:LSP4DigitalAsset",
  "key": "0xeafec4d89fa9619884b60000a4d96624a38f7ac2d8d9a604ecf07c12c77e480c",
  "keyType": "Mapping",
  "valueType": "bytes4",
  "valueContent": "0xa4d96624"
}
```

A data key indicating the presence of other data keys related to the [LSP4-DigitalAsset-Metadata](#) standard.

#### LSP4TokenName

```json
{
  "name": "LSP4TokenName",
  "key": "0xdeba1e292f8ba88238e10ab3c7f88bd4be4fac56cad5194b6ecceaf653468af1",
  "keyType": "Singleton",
  "valueType": "string",
  "valueContent": "String"
}
```

A data key to store a string representing the name of the token.

The `LSP4TokenName` data key is OPTIONAL. If this data key is present and used, the following requirements apply:

_Requirements_

- The value of the `LSP4TokenName` MUST NOT be changeable and set only on deployment or during initialization of the token.

#### LSP4TokenSymbol

```json
{
  "name": "LSP4TokenSymbol",
  "key": "0x2f0a68ab07768e01943a599e73362a0e17a63a72e94dd2e384d2c1d4db932756",
  "keyType": "Singleton",
  "valueType": "string",
  "valueContent": "String"
}
```

A data key to store a string representing the symbol for the token.

The `LSP4TokenSymbol` data key is OPTIONAL. If this data key is present and used, the following requirements and recommendations apply:

_Requirements_

- The value of the `LSP4TokenSymbol` MUST NOT be changeable and set only on deployment or during initialization of the token.

_Recommendations_

- Symbols SHOULD be **UPPERCASE**.
- Symbols SHOULD NOT contain any white spaces.
- Symbols SHOULD contain only ASCII characters.

#### LSP4Metadata

```json
{
  "name": "LSP4Metadata",
  "key": "0x9afb95cacc9f95858ec44aa8c3b685511002e30ae54415823f406128b85b238e",
  "keyType": "Singleton",
  "valueType": "bytes",
  "valueContent": "VerifiableURI"
}
```

A data key to store the description of the asset.

For more informations on how to construct the VerifiableURI, see: [ERC725Y JSON Schema > `valueContent` > `VerifiableURI`](./LSP-2-ERC725YJSONSchema.md#VerifiableURI)

The linked JSON file SHOULD have the following format:

> **Note:** the `"attributes"` field is OPTIONAL.

```js
{
    "LSP4Metadata": {
        "name": "string", // name of the DigitalAsset if not defined in LSP4TokenName
        "description": "string",
        "links": [ // links related to DigitalAsset
            {
                "title": "string", // a title for the link.
                "url": "string" // the link itself
            },
            ...
        ],
        "icon": [ // SHOULD be used for LSP7 icons
            // multiple sizes of the same icon
            { // example of a verificationData based image verification
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
            ...
        ],
        "images": [ // COULD be used for LSP8 NFT art
            // multiple images in different sizes, related to the DigitalAsset, image 0, should be the main image
            // array of different sizes of the same image
            [
                { // example of a verificationData based image verification
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
                    "tokenId": 32bytes  // (optional) if token contract is an LSP8
                }
                ...
            ],
            [...]
        ],
        "assets": [ // SHOULD be used for any assets of the token (e.g. 3d assets, high res pictures or music, etc)
            {
                "url": 'string',
                "fileType": 'string',
                "verification": {
                    "method": 'keccak256(bytes)',
                    "data": 'string', // bytes32 hash of the asset
                }
            },
            { // example of a NFT/smart contract based asset
                "address": Address, // the address of an LSP7 or LSP8
                "tokenId": 32bytes  // (optional) if token contract is an LSP7
            }
        ],
        "attributes": [
            {
                "key": "string",    // name of the attribute
                "value": "string", // value assigned to the attribute
                "type": "string | number | boolean",   // for encoding/decoding purposes
            },
        ]
        ...
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
        icon: [
            {
                width: 256,
                height: 256,
                url: 'ifps://QmW5cF4r9yWeY1gUCtt7c6v3ve7Fzdg8CKvTS96NU9Uiwr',
                verification: {
                    method: 'keccak256(bytes)',
                    data: '0x01299df007997de92a820c6c2ec1cb2d3f5aa5fc1adf294157de563eba39bb6f',
                }
            }
        ],
        images: [ // COULD be used for LSP8 NFT art
            [
                {
                    width: 1024,
                    height: 974,
                    url: 'ifps://QmW4wM4r9yWeY1gUCtt7c6v3ve7Fzdg8CKvTS96NU9Uiwr',
                    verification: {
                        method: 'keccak256(bytes)',
                        data: '0xa9399df007997de92a820c6c2ec1cb2d3f5aa5fc1adf294157de563eba39bb6e',
                    }
                },
                ... // more image sizes
            ],
            ... // more images
        ],
        assets: [{
            verification: {
                method: 'keccak256(bytes)',
                data: '0x98fe032f81c43426fbcfb21c780c879667a08e2a65e8ae38027d4d61cdfe6f55',
            },
            url: 'ifps://QmPJESHbVkPtSaHntNVY5F6JDLW8v69M2d6khXEYGUMn7N',
            fileType: 'fbx'
        }],
        attributes: [
            {
                key: 'Standard type',
                value: 'LSP',
                type: "string"
            },
            {
                key: 'Standard number',
                value: 4,
                type: "number"
            },
            {
                key: '🆙',
                value: true,
                type: "boolean"
            }
        ]
    }
}
```

#### LSP4TokenType

```json
{
  "name": "LSP4TokenType",
  "key": "0xe0261fa95db2eb3b5439bd033cda66d56b96f92f243a8228fd87550ed7bdfdb3",
  "keyType": "Singleton",
  "valueType": "uint256",
  "valueContent": "Number"
}
```

A data key to store a number representing the type of token that the asset contract represents.

| Value |  Type   | Description                                                                                                                                                    |
| :---: | :-----: | :------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  `0`  | `Token` | Only valid for [LSP7-DigitalAsset](./LSP-7-DigitalAsset.md), when the asset's decimals are higher than 0, meaning that its a fungible token (e.g. USDC, LYXe). |

_Result_:

- `LSP4Metadata` data key represents the Token contract information.

| Value | Type  | Description                                                                                                                                                                                                                                                                                                                                                                                                            |
| :---: | :---: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  `1`  | `NFT` | Valid for [LSP7-DigitalAsset](./LSP-7-DigitalAsset.md), when the asset's decimals is equal to 0, meaning that each item cannot be divisble (e.g. 100 units of the same Handbag). <br> Valid for [LSP8-IdentifiableDigitalAsset](./LSP-8-IdentifiableDigitalAsset.md) when the representation (`LSP8TokenIdFormat`) of the tokenIds is different than **Addresses** (e.g. Piggy NFT contract with 50 different piggies) |

_Result_:

- In case of [LSP7-DigitalAsset](./LSP-7-DigitalAsset.md): The `LSP4Metadata` data key represents the information of the same **single** NFT.
- In case of [LSP8-IdentifiableDigitalAsset](./LSP-8-IdentifiableDigitalAsset.md): The `LSP4Metadata` data key represents the information of the NFT contract, and each single tokenId, if and only if, the tokenIds didn't have their own metadata.

  Metadata can be added to the tokenIds by either setting the `LSP4Metadata` data key for each tokenId or by setting the `LSP8TokenMetadataBaseURI` data key for the whole NFT contract. Check [LSP8-IdentifiableDigitalAsset] for more information.

| Value |     Type     | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| :---: | :----------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  `2`  | `Collection` | Only valid for [LSP8-IdentifiableDigitalAsset](./LSP-8-IdentifiableDigitalAsset.md), when the representation (`LSP8TokenIdFormat`) of the tokenIds is an address signaling that the tokenId is either a [LSP7-DigitalAsset](./LSP-7-DigitalAsset.md) or [LSP8-IdentifiableDigitalAsset](./LSP-8-IdentifiableDigitalAsset.md) contract. (e.g. Brand 2024 Summer Collection NFT contract containing Watches, Sunglasses and Braceletes, where each has its own supply/tokenIds) |

_Result_:

- `LSP4Metadata` data key represents the Collection contract information. The metadata of each LSP7 or LSP8 contract (Collection tokenId) needs to be fetched from the relevant contract.

> NOTE: More token types COULD be added later.

_Requirements_

- This MUST NOT be changeable, and set only during initialization of the token contract.

<!-- - `LSP26NFT` -->

#### LSP4Creators[]

```json
{
  "name": "LSP4Creators[]",
  "key": "0x114bd03b3a46d48759680d81ebb2b414fda7d030a7105a851867accf1c2352e7",
  "keyType": "Array",
  "valueType": "address",
  "valueContent": "Address"
}
```

A data key to store the addresses of the creators of the digital asset.

For more informations about how to access each index of the `LSP4Creators[]` array, see [ERC725Y JSON Schema > `keyType`: `Array`](./LSP-2-ERC725YJSONSchema.md#Array)

#### LSP4CreatorsMap

```json
{
  "name": "LSP4CreatorsMap:<address>",
  "key": "0x6de85eaf5d982b4e5da00000<address>",
  "keyType": "Mapping",
  "valueType": "(bytes4,uint128)",
  "valueContent": "(Bytes4,Number)"
}
```

A data key to store information about a specific creator of the digital asset. The information contains the interfaceId of the creator, and the index in the `LSP4Creators[]` array.

This data key exists so that smart contracts can detect whether the address of a creator is present in the `LSP4Creators[]` array without looping all over it on-chain. Moreover, it helps to identify at which index in the `LSP4Creators[]` the creator address is located for easy access and to change or remove this specific creator from the array. Finally, it also allows the detection of the interface supported by the creator.

The `valueContent` MUST be constructed as follows: `bytes4(standardInterfaceId) + uint128(indexNumber)`.
Where:

- `standardInterfaceId` = if the creator address is a smart contract, the [ERC165 interface ID](https://eips.ethereum.org/EIPS/eip-165) of the standard that the smart contract implements. Otherwise `0xffffffff` in the case where the creator address is:
  - an Externally Owned Account, or
  - a contract implementing no ERC165 interface ID.
- `indexNumber` = the index in the [`LSP4Creators[]` Array](##lsp4creators)

## Rationale

### Standardization

As more and more token standards emerge, it's important to keep a consistency in how asset's metadata is handled. This standard helps by providing a common method to detail the token's creators, its name, symbol, and other key information. This makes it easier for websites and interfaces to display the information in a standardized, uniform way.

### Usage of ERC725Y and LSP2-ERC72YJSONSchema

The choice to use ERC725Y, and representing the data keys according to [LSP2-ERC72YJSONSchema] standard, lies in its flexibility for storing asset metadata and properly representing it. Unlike other standards that limit metadata to a tokenURI, ERC725Y enables the storage of various type of data. This flexibility means there's no need to standardize new functions; instead, we can simply define a new data key and incorporate new standardized data into the token's storage. This approach allows for a broader and more adaptable representation of assets.

In addition to this, since the ERC725Y storage can be updated after token deployment, it allows to update metadata introducing a dynamic element to digital assets, such as addinng 3D files, access to new community, etc .. This capability could enable more complex and evolving NFT systems, where tokens can grow or gain new functions over time, with their evolution being traceable and verifiable on-chain.

### Creators

Current popular token standards often ignore the representation of creators within the token contracts. This oversight is unfair to the creators who then have to depend on centralized entities and marketplaces for identity verification based on biased and defined criteria. Integrating creators' addresses directly into the contract enables on-chain verification of the creators' identity. Creators can then proove themselves in various way to authenticate within dApps.

Moreover, incorporating the creators' information can help in different ways, it can help with royalties integration, as well as enhancing the on-chain authenticity of the asset. With the [LSP12-IssuedAssets](./LSP-12-IssuedAssets.md) standard, assets can reference their creators using the `LSP4Creators` data key. Conversely, creators can reference their issued assets using the `LSP12IssuedAssets` data key. This dual-reference system provides on-chain proof of authenticity, a feature not available in current token standards.

> Note: It's a flawed practice to assume that the owner or deployer of the contract is the token's creator. The owner might be a management contract, a factory contract, or another entity not directly involved in the creation.

### VerifiableURI

The current token standards typically rely on a `tokenURI` that links to a JSON schema, defining the token's metadata. However, this URI isn't always hosted on immutable storage like IPFS, leading to potential changes or tampering with the metadata content without the user's knowledge.

This reliance on a link-based approach, rather than content-based, means that the actual metadata content could change if the link is redirected. Consequently, it's crucial to have an **optional** on-chain method to verify that the content associated with the asset remains unaltered and consistent with what's stored in the contract.

**VerifiableURI** is a valueContent defined in [LSP2-ERC725YJSONSchema] designed to enable proof of the URI's authenticity, whether through hash-based, signature-based methods, or others. For instance, hashing the Metadata JSON content and storing its hash alongside the URI would allow interfaces to retrieve and hash the Metadata JSON, then compare it against the contract-stored hash to ensure the metadata hasn't been altered. This provides a layer of security and trust in the authenticity and consistency of the token's metadata.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP4DigitalAssetMetadata/LSP4DigitalAssetMetadata.sol) repository where token contract can inherit the following contract to have access to the ERC725Y storage and have the asset information set automatically.

The below defines the JSON interface of the `LSP4DigitalAssetMetadata`.

ERC725Y JSON Schema `LSP4DigitalAssetMetadata`:

```json
[
  {
    "name": "SupportedStandards:LSP4DigitalAsset",
    "key": "0xeafec4d89fa9619884b60000a4d96624a38f7ac2d8d9a604ecf07c12c77e480c",
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
  },
  {
    "name": "LSP4Metadata",
    "key": "0x9afb95cacc9f95858ec44aa8c3b685511002e30ae54415823f406128b85b238e",
    "keyType": "Singleton",
    "valueType": "bytes",
    "valueContent": "VerifiableURI"
  },
  {
    "name": "LSP4TokenType",
    "key": "0xe0261fa95db2eb3b5439bd033cda66d56b96f92f243a8228fd87550ed7bdfdb3",
    "keyType": "Singleton",
    "valueType": "uint256",
    "valueContent": "Number"
  },
  {
    "name": "LSP4Creators[]",
    "key": "0x114bd03b3a46d48759680d81ebb2b414fda7d030a7105a851867accf1c2352e7",
    "keyType": "Array",
    "valueType": "address",
    "valueContent": "Address"
  },
  {
    "name": "LSP4CreatorsMap:<address>",
    "key": "0x6de85eaf5d982b4e5da00000<address>",
    "keyType": "Mapping",
    "valueType": "(bytes4,uint128)",
    "valueContent": "(Bytes4,Number)"
  }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
