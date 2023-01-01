---
lip: 19
title: Social Registry
status: Draft
type: LSP
author: Samuel Videau <samuel@dropps.io>, António Pedro <antonio@dropps.io>
created: 2022-07-26
updated: 2023-01-01
requires: ERC725Y, LSP2
---

## Simple Summary

This standard describes a smart contract, and a data model to store Social Media information such as posts, likes and follows.

## Abstract

This standard defines a set of data formats and a key-value pair to create a Social Media Feed, combining [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md) and an open distributed storage network such as [IPFS](https://ipfs.tech/) or [ARWEAVE](https://arweave.org).
It also defines a smart contract used to guaranty authenticity and timestamp of a post.

## Motivation

Real interoperability requires social media itself to be separated from social media companies. This proposal aims to create a common interoperable standard in which messages generated on one social media app could be transported and read in any other application.

Using a standardized data model to store social media makes content platform-independent and allows it to be read and stored easily. This content can be added to an [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md), giving it a Social Media Account character.

## Specification

### LSP19SocialRegistry

A Universal Profile's Social Media State will live under a record referenced by the "LSP19SocialRegistry" data key of their ERC725Y store.

The JSON Url stored inside points to a JSON file that lists all the social media actions of a profile, including posts, likes, dislikes and follows.

```json
  {
      "name": "LSP19SocialRegistry",
      "key": "0xaa093cc8e40d9473239c9fefe0f7e73ad8b9fb1bfca176dcaf5a8af4eacfb1f4",
      "keyType": "Singleton",
      "valueType": "bytes",
      "valueContent": "JSONURL"
  }
```

This registry should be updated everytime a new post is added by the user.
Note: It might not be necessary to update the registry for each follow, like or dislike. A balanced trade-off between interoperability/decentralization and cost/UX could be found.

The linked JSON file SHOULD have the following format:

```js
{
  "LSP19SocialRegistry": {
    "posts": [ // Messages authored by the profile. Includes original posts, comments and reposts.
      {
        "url": "String", // The url in decentralized storage with the post content and metadata
        "hash": "Bytes32" // The hash of the post object
      },
      ...
    ],
    "follows": [ "Address", ... ], // UPs this account has subscribed.  Will compose the account's feed.
    "likes": [
      {
        "url": "String", // The url in decentralized storage with the post content and metadata
        "hash": "Bytes32" // The hash of the post object
      }
    ], // The identifier (hash) of all the posts this account has liked,
    "dislikes": [
      {
        "url": "String", // The url in decentralized storage with the post content and metadata
        "hash": "Bytes32" // The hash of the post object
      }
    ], // The identifier (hash) of all the posts this account has disliked
  }
}
```

Below is an example of a social registry:

```JSON
{
  "posts": [
    {
      "url": "ar://NUb9WJ9BbbxLfIDgGwq4zPECBz_df0CrhBmRsYsn8-Y",
      "hash": "0xb1029df66ea5ae5cdcc0e84b6e048e37b3df14a4aec92fc4c23d86f8c62e4a4c"
    }
  ], 
  "likes": [
    {
      "url": "ar://oHJwvoggzfUxv2WpJIeIlLNC-OR1X1CmGO2zp7BeRgk",
      "hash": "0x50f7488034e24cf441d5d02a174d5f56930dbbdbb8815dbb54346be1c5648377"
    }
  ],
  "dislikes": [
    {
      "url": "ar://PPJDYJf6AgZZYKOXZtBBgmdz_-XFCFaBiTuh7Mojecc",
      "hash": "0xe15aaaa78c05fc9f9f6d9099db9e984dffe7a732e4fdd503187ad1a91f8390c7"
    }
  ],
  "follows": [
    "0x53529E4164E5CCA7d6A1C55f8500A57D0F435bee"
  ]
}
```

### Profile Posts

A Profile Post can be an original message, a comment on another post or a repost. The JSON file should have the following format:

Not all fields are required. For example, a `repost` doesn't need a message, but it should have the `url` and `hash` to the original post.
The `LSP19ProfilePostSignature` property is optional and depends on the use case. It is used to authenticate a post through a controller EOA (Externally Owned Account)

```js
{
  "LSP19ProfilePost": {
    "version": "0.0.1", // The Metadata version of this post
    "author": "Address", // The Universal Profile who authored the post
    "locale": "string", // language code - Country Code (de_DE)
    "app": "string", // The platform that originated this post
    "validator": "Address", // Address of a validator smart contract which will authenticate a post and provide its publication date (more info bellow)
    "nonce": "string", // Random value to allow duplicates
    "message": "string", // The post original content
    "links": [
      {
        "title": "string", // The link's label
        "url": "string"
      },
      ...
    ],
    "tags": [ // Tags attached to a post
      "string",
      ...
    ],
    "medias": [ // Medias attached to a post
      {
        "hashFunction": "keccak256(bytes)",
        "hash": "string",
        "url": "string", 
        "fileType": "string"
      }
    ],
    "assets": [
      "interface": "string" // Contract interface
      "contract": "Address", // Address of the asset contract
      "tokenId": "any" // Or null
    ]
    "parentPost": {
      "url": "string",
      "hash": "string",
    }, // or null. A post with a parentPost is a comment
    "childPost": {
      "url": "string",
      "hash": "string",
    }, // or null. A post with a childPost is a repost
  },
  "LSP19ProfilePostHash": {// Hash of the LSP19ProfilePost object
    "hashFunction": 'keccak256(bytes)',
    "hash": "string",
  }, 
  "LSP19ProfilePostSignature": "string" // Signature of the LSP19ProfilePost content from UP controller that create the post, or NULL
}
```
Below is an example of a post object:

```JSON
{
  "LSP19ProfilePost": {
    "version":"0.0.1",
    "message": "This is the first Lookso post.",
    "author": "0x742242E9572cEa7d3094352472d8463B0a488b80",
    "app": "Lookso",
    "locale": "en-US",
    "validator": "0x049bAfA4bF69bCf6FcB7246409bc92a43f0a7264",
    "nonce": "415665014",
    "links": [
      {
        "title": "Our website",
        "url": "https://dropps.io"
      }
    ],
    "medias": 
      [
        {
          "hashFunction": "keccak256(bytes)",
          "hash": "0x813a0027c9201ccdec5324aa32ddf0e8b9400479662b6f243500a42f2f85d2eb",
          "url": "ar://gkmVUoHE4Ay6ScIlgV4E7Fs1m13LfpAXSuwuRGRQbeA",
          "fileType": "jpg"
        }
      ],
    "assets":
      [
        {
          "interface": "0x622e7a01",
          "contract": "0x8cE5Aa1F67FbC9034720E7C9e1e1a841C46faC22",
          "tokenId": "0x715f248956de7ce65e94d9d836bfead479f7e70d69b718d47bfe7b00e05b4fe4"
        },
        {
          "interface": "0xda1f85e4",
          "contract": "0xbC595d500b30aeb9b04e4D4360f84FdCb2910393"
        }
      ],
    "parentPost": {
      "hash": "0xdc1812e317c6cf84760d59bda99517de5b5c5190fcf820713075430337805340",
      "url": "ar://PPJDYJf6AgZZYKOXZtBBgmdz_-XFCFaBiTuh7Mojecc"
    },
    "childHash": null
  },
  "LSP19ProfilePostHash": {
    "hashFunction": "keccak256(utf-8)",
    "hash": "0x0017eb3f3b2c10c3387c710e849c64527ae331bfb2d42fb70fbe95588ff5d6cd"
  },
  "LSP19ProfilePostSignature": "0x2845551019619d59657b6e485d1cb2067479a5bc364270030d7c4143b4cc0ee5279432bee8425f17d091f067e6b8f987390900b1fd82bef52fcb4c8b2b06ab901b"
}
```

The post content and metadata is stored under _LSP19ProfilePost_. 
<br>The content and metadata present in the _LSP19ProfilePost_ JSON object are hashed, and the hash is saved under _LSP19ProfilePostHash_. (E.g. `keccak256(JSON.stringify(LSP19ProfilePost))`)
<br>Finally, the controller address can be used to sign the _LSP19ProfilePost_ object and obtain the _LSP19ProfilePostSignature_ (optional field). This signature can be obtained, for example, using `web3.eth.accounts.sign(LSP19ProfilePost, privateKey);`

Let's breakdown the _LSP19ProfilePost_ attributes:

* **version** allows clients that adhere to the protocol to display posts according to their version
* **message** is the actual content of a post that will be displayed as text.
* **author** is the address of the Universal Profile that submitted the post.
* **app** is the name of the URL of the platform that originated the post.
* **locale** is the language code used in the post message.
* **validator** is the address of the post validator, the contract that timestamped this particular post. Use it to verify the post authenticity and timestamp.
* **nonce** is what makes a post unique. Otherwise, posts written by the same author with the same message would generate the same hash and collide in the validator storage. The transaction would then revert when someone tried posting the same content twice. Even if on different dates! We don't want that. Anyone has the right to just pass by and say "Goodmorning!" everyday.
* **links** they can be used in the future to extend the standard.
* **tags** they can be used in the future as hashtags.
* **medias** Media files attached to the post. Images, videos, or any other file type.
* **assets** Digital assets attached to the post. LSP7, LSP8, ERC20, ERC721, ERC1155, etc.
* **parentPost** If this post is a comment, the hash and url of the original post should go in here.
* **childPost** If this post is a repost, the hash and url of the original post should go in here.

⚠️ The `LSP19ProfilePostHash` and `LSP19ProfilePostSignature` values are based on the `LSP19ProfilePost` JSON object content.

## Post Validator

This defines a validator smart contract where any Universal Profile can store proof that it knew some information at a given point in time.

### Motivation

One should not trust the author of a message to provide an accurate timestamp because it can be faked.
Instead, a trustless timestamping service should be used to determine the message's creation date.
This is possible using the blockchain as the source of time.

Furthermore, notice that timestamping a given hash is proof that the author
was able to generate that hash at that time. This can be used to approach another problem:
Cryptographic signatures are usually used to provide proof of ownership and timestamp.
However, because a smart contract cannot sign, this method cannot be used for contract based accounts
like an [ERC725Account](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-0-ERC725Account.md).
Current practice if for an Externally Owned Address (EOA) to sign on behalf of the contract.
However, it's hard to know if the EOA had permissions to sign at the time and to timestamp the signed message in a trustless way.

### Specification

This is a Solidity contract for a post validator that is tailored for Universal Profiles (UPs) and content publishing. 
The contract has two functions: `post` and `postWithJsonUrl`.

The `post` function allows a UP to make a post by emitting a `NewPost` event with the postHash and the UP's address as the indexed arguments.

The `postWithJsonUrl` function extends the `post` function by allowing the UP to also specify a reference to the latest Social Media Record in the `jsonUrl` argument. 
This function first verifies that the UP implements the ERC725Y standard (which includes a key/value store) and then sends a transaction to the UP to update the registry reference in the UP's key/value store with the `jsonUrl` value.

### Implementation

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import {_INTERFACEID_ERC725Y} from "@erc725/smart-contracts/contracts/constants.sol";
import { OwnableUnset } from "@erc725/smart-contracts/contracts/custom/OwnableUnset.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import { ILSP6KeyManager} from "@lukso/lsp-smart-contracts/contracts/LSP6KeyManager/ILSP6KeyManager.sol";

/**
* @title LSP19 post validator
* @notice A validator tailored for Universal Profiles and content publishing
* @dev Writes to the Universal Profile key/value store
*/
contract LSP19PostValidator is Context {

  bytes32 public constant REGISTRY_KEY = keccak256("LSP19SocialRegistry");

  event NewPost(bytes32 indexed postHash, address indexed author);

  /**
  * @notice Universal Profile (message sender) makes a post
  * @param postHash will pushed in an event, with the _msgSender, in order to validate the author and the timestamp of the post
  */
  function post(bytes32 postHash) public {
      // Save the timestamp as a blockchain event
      emit newPost(postHash, _msgSender());
  }
  
  /**
  * @notice Universal Profile (message sender) makes a post
  * @dev This contract must have permissions to write on the Universal Profile
  * @param postHash will pushed in an event, with the _msgSender, in order to validate the author and the timestamp of the post
  * @param jsonUrl Reference to the latest Social Media Record of the sender
  */
  function postWithJsonUrl(bytes32 postHash, bytes calldata jsonUrl) public {

      // Save the timestamp as a blockchain event
      post(postHash);

      // Verify sender supports the IERC725Y standard
      require(ERC165Checker.supportsERC165(_msgSender()), "Sender must implement ERC165. A UP does.");
      require(ERC165Checker.supportsInterface(_msgSender(), _INTERFACEID_ERC725Y), "Sender must implement IERC725Y (key/value store). A UP does");

      // Create the tx to update the registry reference in the UP
      bytes memory encodedCall = abi.encodeWithSelector(
          bytes4(keccak256(bytes("setData(bytes32,bytes)"))), //function.selector
          REGISTRY_KEY, jsonUrl
      );

      // Send the setData tx to the UP
      ILSP6KeyManager( OwnableUnset(_msgSender()).owner() ).execute(encodedCall);
  }
}
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
