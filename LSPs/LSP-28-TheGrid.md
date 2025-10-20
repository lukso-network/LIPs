---
lip: 28
title: The Grid
author: Fabian Vogelsteller <fabian@lukso.network>
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2025-02-11
requires: ERC725Y
---

## Simple Summary

This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data keys to reference a interactive grid layouts for mini-apps and content display. A grid can be added to Universal Profiles or other smart contracts, like LSP7 and LSP8 tokens.

## Abstract

This standard defines a set of data key-value pairs that allow Universal Profiles to create personalized, modular grid layouts. These layouts can host various types of content including mini-apps, social media embeds, text content, images, and interactive elements.

## Motivation

The Grid standard enables Universal Profiles to move beyond static metadata by providing a framework for creating dynamic, customizable layouts that can host both traditional content and web3 enabled mini-apps. This allows for additional content to be referenced from profiles and tokens.

By using adding mini-apps with a [up-provider](https://github.com/lukso-network/tools-up-provider), parent pages can forward their connected accounts to mini-apps allowing for a seamless connection from the parent page.

## Specification

Every contract that supports The Grid standard SHOULD implement the following [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data keys. The Grid enables Universal Profiles to create customizable layouts through a combination of standardized data structures and content types.

### ERC725Y Data Keys

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

##### Main grid properties

- **title**: The name of the grid, for the interface to display.
- **gridColumns**: The number of columns the grid should have, we recommend the numbers from `2`-`4`.
- **visibility**: Tells the user interface weather or not to show the grid to other users, or only to the grid owner. This IS NOT real private grid, as it is public on the blockchain and not encrypted.
- **grid**: The content of the grid. Each item is a box in the grid with sizes and content properties.
- **visibility**: The user preferred visibility of the grid as reference for interfaces displaying the grid. MUST be:

  - `public` - visible to everyone
  - `private` - visible only to the user owning the grid

  > Note that on-chain data can by viewed by everyone so the `visibility` property doesn't enforce privacy. Interfaces should let their users know that this data is not fully private.

##### Grid element properties

- **width/height**: The size of the grid in a number of steps. It is up to the interface to determine the width and height of each step. We recommend numbers from `1`-`3`.
- **type**: The type of the grid item, commonly `IFRAME` to load external content, but custom types can also be defined, as seen in the JSON file below.
- **properties**: The properties of the grid item, different based on the `type`.

The linked JSON file SHOULD have the following format:

```js
{
  "LSP28TheGrid": [
    {
      "title": "My Socials",
      "gridColumns": 2, // Example value
      "visibility": "private", // private/public OPTIONAL
      "grid": [
        // IFRAME
        {
          "width": 1,  // Example value
          "height": 3,  // Example value
          "type": "IFRAME",
          "properties": {
            "src": "...",
            "allow": "accelerometer; autoplay; clipboard-write", // OPTIONAL
            "sandbox": "allow-forms;allow-pointer-lock;allow-popups;allow-same-orig;allow-scripts;allow-top-navigation", // OPTIONAL
            "allowfullscreen": true, // OPTIONAL
            "referrerpolicy": "..." // OPTIONAL
          }
        },

        // TEXT
        {
          "width": 2,
          "height": 2,
          "type": "TEXT",
          "properties": {
            "title": "My title", // OPTIONAL and MARKDOWN possible
            "titleColor": "#000000", // OPTIONAL, overwrites "text-color" for titles
            "text": "My title", // OPTIONAL and MARKDOWN possible
            "textColor": "#000000", // OPTIONAL
            "backgroundColor": "#ffffff", // OPTIONAL
            "backgroundImage": "https://myimage.jpg", // OPTIONAL
            "link": "https://mylink.com" // OPTIONAL click on the box, opens link
          }
        },

        // IMAGES
        {
          "width": 2,
          "height": 2,
          "type": "IMAGES",
          "properties": {
            "type": "grid", // OPTIONAL "grid", "carousel", (grid is default)
            "images": ["<IMAGE_URL_1>", "<IMAGE_URL_2>"]
          }
        },

        // -------------------------------
        // Custom items from web application

        // ELFSIGHT
        {
          "width": 2,
          "height": 1,
          "type": "ELFSIGHT",
          "properties": {
            "id": "..." // Elfsight ID
          }
        },

        // X (post)
        {
          "width": 2,
          "height": 1,
          "type": "X",
          "properties": {
            "type": "post",
            "username": "feindura",
            "id": "1804519711377436675", // OPTIONAL used when "post" type
            "theme": "light", // OPTIONAL data-theme=dark
            "language": "en", // OPTIONAL data-lang=en
            "donottrack": true // OPTIONAL data-dnt=true
          }
        },

        // INSTAGRAM (post)
        {
          "width": 2,
          "height": 2,
          "type": "INSTAGRAM",
          "properties": {
            "type": "p", // The type of item, for example "p" for post
            "id": "..." // Post ID
          }
        },

        // QR CODE
        {
          "width": 2,
          "height": 1,
          "type": "QR_CODE",
          "properties": {
            "data": "..." // data displayed in QR code
          }
        }
      ]
    }
  ]
}
```

## Rationale

The Grid standard addresses the need interactive UIs related to profiles and tokens by providing a standardized way to create modular layouts that can host both traditional content and mini-apps. It enables Universal Profiles to become dynamic platforms for user interaction and content presentation. This approach maintains the decentralized nature of Universal Profiles while allowing for rich, web2-like experiences through standardized content types and layout options.

## Implementation

An implementation can be found in the [universaleverything.io)[https://universaleverything.io];

Below is an example of an ERC725Y JSON Schema.

```json
[
  {
    "name": "LSP28TheGrid",
    "key": "0x724141d9918ce69e6b8afcf53a91748466086ba2c74b94cab43c649ae2ac23ff",
    "keyType": "Singleton",
    "valueType": "bytes",
    "valueContent": "VerifiableURI"
  }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
