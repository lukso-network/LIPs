---
lip: 28
title: The Grid
author: Fabian Vogelsteller <fabian@lukso.network>
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2025-02-11
requires: ERC165, ERC725Y, LSP1, LSP2, LSP5, LSP12
---

## Simple Summary

This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores that enable Universal Profiles to create and manage customizable, interactive grid layouts for mini-apps and content display.

## Abstract

This standard defines a set of data key-value pairs that allow Universal Profiles to create personalized, modular grid layouts. These layouts can host various types of content including mini-apps, social media embeds, text content, images, and interactive elements.

## Motivation

The Grid standard enables Universal Profiles to move beyond static metadata by providing a framework for creating dynamic, customizable layouts that can host both traditional content and mini-apps. This creates a more engaging and functional profile experience while maintaining the decentralized nature of Universal Profiles.

## Specification

Every contract that supports The Grid standard SHOULD implement the following [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data keys. The Grid enables Universal Profiles to create customizable layouts through a combination of standardized data structures and content types.

### ERC725Y Data Keys

#### SupportedStandards:LSP28TheGrid

The supported standard SHOULD be `LSP28TheGrid`

```json
{
  "name": "SupportedStandards:LSP28TheGrid",
  "key": "0x3310b3742dde3f8208ac7206f168f8f2b6b70fdb7ed1001d701574e301f6d778",
  "keyType": "Mapping",
  "valueType": "bytes4",
  "valueContent": "0x5ef83ad9" // ??
}
```

#### LSP28TheGrid

A JSON file that describes a customizable grid layout for displaying content and mini-apps. The grid can be configured with different column counts and contain various content types like iframes, text blocks, images, and other interactive elements.

```json
{
  "name": "LSP28TheGrid",
  "key": "0x724141d9918ce69e6b8afcf53a91748466086ba2c74b94cab43c649ae2ac23ff",
  "keyType": "Singleton",
  "valueType": "bytes",
  "valueContent": "VerifiableURI"
}
```

For construction of the VerifiableURI value see: [ERC725Y VerifiableURI Schema](./LSP-2-ERC725YJSONSchema.md#VerifiableURI)

The linked JSON file SHOULD have the following format:

```js
{
  "LSP28TheGrid": {
    "title": "My Socials",
    "gridColumns": 2,
    "grid": [
      {
        "width": 1,
        "height": 3,
        "type": "IFRAME",
        "properties": {
          "src": "...",            
        }
      },
      {
        "width": 2,
        "height": 2,
        "type": "TEXT",
        "properties": {
          "title": "...",
        }
      },
      {
        "width": 2,
        "height": 2,
        "type": "IMAGES",
        "properties": {
          "images": [
            "<IMAGE_URL_1>",
            "<IMAGE_URL_2>"
          ]
        }
      }
    ]
  }
}
```

Example:

```js
{
  "LSP28TheGrid": [
    {
      "title": "My Socials",
      "gridColumns": 2,
      "grid": [
        {
          "width": 1,
          "height": 3,
          "type": "IFRAME",
          "properties": {
            "src": "...",
            "allow": "accelerometer; autoplay; clipboard-write",
            "sandbox": "allow-forms;allow-pointer-lock;allow-popups;allow-same-orig;allow-scripts;allow-top-navigation",
            "allowfullscreen": true,
            "referrerpolicy": "..."
          }
        },
        {
          "width": 2,
          "height": 1,
          "type": "TEXT",
          "properties": {
            "title": "My title",
            "titleColor": "#000000",
            "text": "My title",
            "textColor": "#000000",
            "backgroundColor": "#ffffff",
            "link": "https://mylink.com"
          }
        },
        {
          "width": 2,
          "height": 1,
          "type": "IMAGES",
          "properties": {
            "type": "grid",
            "images": [
              "https://mylink.com/image1.png",
              "https://mylink.com/image2.png"
            ]
          }
        },
        {
          "width": 2,
          "height": 1,
          "type": "ELFSIGHT",
          "properties": {
            "id": "8473218e-6c60-4958-a6a7-b8c6065e1528"
          }
        },
        {
          "width": 2,
          "height": 1,
          "type": "X",
          "properties": {
            "type": "timeline",
            "username": "feindura",
            "id": "1804519711377436675",
            "theme": "light",
            "language": "en",
            "donottrack": true
          }
        }
      ]
    },
    {
      "width": 2,
      "height": 1,
      "type": "INSTAGRAM",
      "properties": {
        "type": "post",
        "id": "C98OXs6yhAq"
      }
    },
    {
      "width": 2,
      "height": 1,
      "type": "QR_CODE",
      "properties": {
        "data": "http://example.com"
      }
    }
  ]
}
```

## Rationale

The Grid standard addresses the need for more interactive and customizable profile experiences by providing a standardized way to create modular layouts that can host both traditional content and mini-apps. It enables Universal Profiles to become dynamic platforms for user interaction and content presentation. This approach maintains the decentralized nature of Universal Profiles while allowing for rich, web2-like experiences through standardized content types and layout options.

## Implementation

An implementation can be found in the [lukso-network/universalprofile-smart-contracts](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/main/contracts/UniversalProfile.sol);
The below defines the JSON interface of the `LSP28TheGrid`.

ERC725Y VerifiableURI Schema `LSP28TheGrid`:

```json
[
  {
    "name": "SupportedStandards:LSP28TheGrid",
    "key": "0x3310b3742dde3f8208ac7206f168f8f2b6b70fdb7ed1001d701574e301f6d778",
    "keyType": "Mapping",
    "valueType": "bytes4",
    "valueContent": "0x5ef83ad9" // ??
  },
  {
    "name": "LSP28TheGrid",
    "key": "0x724141d9918ce69e6b8afcf53a91748466086ba2c74b94cab43c649ae2ac23ff",
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