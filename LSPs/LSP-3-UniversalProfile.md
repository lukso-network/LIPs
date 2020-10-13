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


#### LSP3Name

The name of the profile, can be a username, company name, or other title.

```json
{
    "type": "LSP3Name",
    "key": "0xa5f15b1fa920bbdbc28f5d785e5224e3a66eb5f7d4092dc9ba82d5e5ae3abc87",
    "keyType": "Singleton",
    "valueContent": "String",
    "valueType": "string"
}
```

Example:
```solidity
key: keccak256('LSP3Name') = 0xa5f15b1fa920bbdbc28f5d785e5224e3a66eb5f7d4092dc9ba82d5e5ae3abc87
value: web3.utils.utf8ToHex('myamazingname') = 0x6d79616d617a696e676e616d65
```

#### LSP3Profile

A JSON file that describes the profile information, like profile image, background image and description.

```json
{
    "type": "LSP3Profile",
    "key": "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5",
    "keyType": "Singleton",
    "valueContent": "URI",
    "valueType": "string"
}
```

Example:
```solidity
key: keccak256('LSP3Profile') = 0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5
value: web3.utils.utf8ToHex('ipfs://QmQ2CN2VUdb5nVAz28R47aWP6BjDLPGNJaSBniBuZRs3Jt') = 0x697066733a2f2f516d5132434e3256556462356e56417a323852343761575036426a444c50474e4a6153426e6942755a5273334a74
```

The linked JSON file MUST have the following format:
```js
{
    "LSP3Profile": {
        "profileImage": "URI", // The profile image represents one image representing the profile, like a person image, a company logo or avatar.
        "profileImageHash": "keccak256",
        "backgroundImage": "URI", // The background is an image that can be used in conjunction with profile image to give a more personal look to the profile.
                                  // Websites displaying the profile have to choose how or if, to use this image.
        "backgroundImageHash": "keccak256",
        "description": "string" // A description, describing the person, company, organisation and/or creator of the profile.
    }
}
```

#### LSP3Links

A JSON file describing a set of links related to this profile.

```json
{
    "type": "LSP3Links",
    "key": "0xca76618882d87383fed780cdd8bd4576dcc8c3d08a78ba85b2016652c7fdec40",
    "keyType": "Singleton",
    "valueContent": "URI",
    "valueType": "string"
}
```

Example:
```solidity
key: keccak256('LSP3Links') = 0xca76618882d87383fed780cdd8bd4576dcc8c3d08a78ba85b2016652c7fdec40
value: web3.utils.utf8ToHex('ipfs://QmQ7UV2Vddb5nVAz28R47aWP6BjDLPGNJaSBniBuZRs1JJ') = 0x697066733a2f2f516d513755563256646462356e56417a323852343761575036426a444c50474e4a6153426e6942755a5273314a4a
```

The linked JSON file MUST have the following format:
```json
{
    "LSP3Links": [
        {
            "title": "string",
            "link": "URI"
        },
        ...
    ]
}
```

#### LSP3IssuedAssets[]

References issued smart contract assets, like tokens and NFTs.

```json
{
    "type": "LSP3IssuedAssets[]",
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

ERC725Y JSON Interface `LSP3Account`:
```json
[
    {
        "type": "LSP3Name",
        "key": "0xa5f15b1fa920bbdbc28f5d785e5224e3a66eb5f7d4092dc9ba82d5e5ae3abc87",
        "keyType": "Singleton",
        "valueContent": "String",
        "valueType": "string"
    },
    {
        "type": "LSP3Profile",
        "key": "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5",
        "keyType": "Singleton",
        "valueContent": "URI",
        "valueType": "string"
    },
    {
        "type": "LSP3Links",
        "key": "0xca76618882d87383fed780cdd8bd4576dcc8c3d08a78ba85b2016652c7fdec40",
        "keyType": "Singleton",
        "valueContent": "URI",
        "valueType": "string"
    },
    {
        "type": "LSP3IssuedAssets[]",
        "key": "0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0",
        "keyType": "Array",
        "valueContent": "ArrayLength",
        "valueType": "uint256",
        "elementKey": "0xb8c4a0b76ed8454e098b20a987a980e6",
        "elementKeyType": "ArrayElement",
        "elementValueContent": "Address",
        "elementValueType": "address"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
