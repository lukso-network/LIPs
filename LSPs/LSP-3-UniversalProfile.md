---
lip: 3
title: Universal Profile
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2019-07-12
requires: LSP2, LSP1, ERC725Account
---


## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key value stores that are useful to describe a smart contract based profile.

## Abstract
This standard, defines a set of key value stores that are useful to create a public on-chain profile, based on an (ERC725Account)[https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md].
Additionally this standards expects (LSP1-UniversalReceiver)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md] to be implemented as well, to make the smart contract account future proof.

## Motivation
To make the usage of Blockchain infrastructures easier and allow smart contract based accounts to be more than just a store of assets.
We need to define standards that make these accounts easier to use and interact-able. Therefore we need to define:

- Ways to make security and access to these accounts upgradeable through the use of ERC173 and ERC725X
- Allow these accounts to store information and reference other related systems through the use of ERC725Y
- Define a number of key values stores that any interface can expect to present through this standard (LSP3)  

On top of that many token standards (like ERC721, ERC223 and ERC777) do define their own way of calling contracts.
To rectify this, we propose the usage of [LSP1-UniversalReceiver](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md) and modified versions of ERC777 and other token standards,
to be used with this standard. This is obviously easier on EVM networks that have not yet an established ecosystem like LUKSO, than on the Ethereum mainnet.
Though we still think this addition is extremly necessary even on networks like Ethereum, as more standards are appearing that require to notify other smart contracts. 


## Specification

Every contract that supports to the Universal Profile standard SHOULD implement:

### Keys

#### LSP1UniversalReceiverDelegate

If the account delegates its universal receiver to another smart contract,
this smart contract address SHOULD be stored at the following key:

```solidity
keccak256('LSP1UniversalReceiverDelegate') > 0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47
```


#### LSP3Profile

A JSON file that describes the profile information, including profile image, background image, description and related links.

```json
{
    "name": "LSP3Profile",
    "key": "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5",
    "keyType": "Singleton",
    "valueContent": "JSONURL",
    "valueType": "bytes"
}
```

Example:
```solidity
key: keccak256('LSP3Profile') = 0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5
value: 0x6f357c6a +      820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361 + 696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178
       ^                 ^                                                                  ^
       keccak256(utf8)   hash                                                               encoded URL

```

The linked JSON file MUST have the following format:
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
        // below each image type SHOULD have different size of the same image, so that interfaces can choose which one to load for better loading performance
        "profileImage": [ // One image in different sizes, representing the profile.
            {  
              width: Number,
              height: Number,
              hashFunction: 'keccak256(bytes)',
              hash: 'string', // bytes32 hex string of the image hash
              uri: 'string'
            },
            ...
        ],
        "backgroundImage": [ // Image in different sizes, that can be used in conjunction with profile image to give a more personal look to a profile.
            { 
              width: Number,
              height: Number,
              hashFunction: 'keccak256(bytes)',
              hash: 'string', // bytes32 hex string of the image hash
              uri: 'string'
            },
            ...
        ]
    }
}
```

Example:
```js
{
  name: 'frozeman',
  links: [
    { title: 'Twitter', url: 'https://twitter.com/feindura' },
    { title: 'lukso.network', url: 'https://lukso.network' }
  ],
  description: 'The inventor of ERC725 and ERC20.....',
  profileImage: [
    {
      width: 1024,
      height: 974,
      hashFunction: 'keccak256(bytes)',
      hash: '0xbade827a9b6cb16897195d47e8866bef28c2136460b1e6051c6a7ddf2ff021a4',
      uri: 'ifps://QmW4wM4r9yWeY1gUCtt7c6v3ve7Fzdg8CKvTS96NU9Uiwr'
    },
    {
      width: 640,
      height: 609,
      hashFunction: 'keccak256(bytes)',
      hash: '0xbade827a9b6cb16897195d47e8866bef28c2136460b1e6051c6a7ddf2ff021a4',
      uri: 'ifps://QmXGELsqGidAHMwYRsEv6Z4emzMggtc5GXZYGFK7r6zFBg'
    }
  ],
  backgroundImage: [
    {
      width: 1800,
      height: 1013,
      hashFunction: 'keccak256(bytes)',
      hash: '0xbade827a9b6cb16897195d47e8866bef28c2136460b1e6051c6a7ddf2ff021a4',
      uri: 'ifps://QmPJESHbVkPtSaHntNVY5F6JDLW8v69M2d6khXEYGUMn7N'
    },
    {
      width: 1024,
      height: 576,
      hashFunction: 'keccak256(bytes)',
      hash: '0xbade827a9b6cb16897195d47e8866bef28c2136460b1e6051c6a7ddf2ff021a4',
      uri: 'ifps://QmZc9uMJxyUeUpuowJ7AD6MKoNTaWdVNcBj72iisRyM9Su'
    }
  ]
}
```

#### LSP3IssuedAssets[]

References issued smart contract assets, like tokens and NFTs.

```json
{
    "name": "LSP3IssuedAssets[]",
    "key": "0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0",
    "keyType": "Array",
    "valueContent": "ArrayLength",
    "valueType": "uint256",
    "elementKey": "0xb8c4a0b76ed8454e098b20a987a980e6",
    "elementKeyType": "ArrayElement",
    "elementValueContent": "Address",
    "elementValueType": "address"
}
```

Example:
```solidity
key: keccak256('LSP3IssuedAssets[]') = 0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0
value: uint256 (array length) e.g. 0x0000000000000000000000000000000000000000000000000000000000000002

// array items

// element 0
key: 0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000000
value: 0xcafecafecafecafecafecafecafecafecafecafe

// element 1
key: 0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000001
value: 0xcafecafecafecafecafecafecafecafecafecafe
```

## Rationale
Universal Profiles are important to create verifiable public accounts that are the source of asset issuance,
or a verifiable public appearance. 

## Implementation

A implementation can be found in the [lukso-network/standards-scenarios](https://github.com/lukso-network/standards-scenarios/blob/master/contracts/Accounts/LSP3Account.sol);
The below defines the JSON interface of the `LSP3Account`.

ERC725Y JSON Schema `LSP3Account`:
```json
[
    {
        "name": "LSP3Profile",
        "key": "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5",
        "keyType": "Singleton",
        "valueContent": "JSONURL",
        "valueType": "bytes"
    },
    {
        "name": "LSP3IssuedAssets[]",
        "key": "0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0",
        "keyType": "Array",
        "valueContent": "ArrayLength",
        "valueType": "uint256",
        "elementKey": "0x3a47ab5bd3a594c3a8995f8fa58d0876",
        "elementKeyType": "ArrayElement",
        "elementValueContent": "Address",
        "elementValueType": "address"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
