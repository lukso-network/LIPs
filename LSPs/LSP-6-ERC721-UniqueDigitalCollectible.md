---
lip: 6
title: Unique Digital Collectible
author: Claudio Weck <claudio@fanzone.media>, Ankit Kumar<ankit@fanzone.media>, Olex
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-04-20
requires: LSP1, ERC725Y, ERC721
---

## Simple Summary

This standard describes a smart contract that mints unique token IDs based on ERC721 standard and also supports LSP-1 Universal Receiver.

## Abstract

This standard defines a smart contract which can mint NFT's for collectibles.
Additionally, the current standard modifies ERC721 to work with LSP-1[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md] and also applying certain additional features like minting multiple token IDs and burning token IDs.

## Motivation

This standard aims to create a smart contract in which each minted NFT is unique addressable with its own token ID, so each mint can be given unique values and scores for games and other apps. Each smart contract will be linked to another smart contract which will be based on ERC725Y [https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md] and this smart contract will contain the metadata.


## Specification

Every contract that supports to the Unique Digital Collectible standard SHOULD implement:

### ERC721 modifications

To be compliant with this standard the required ERC721 needs to be modified as follows:

#### universalReceiver

```solidity
 function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal virtual returns (bool)
 ```
This function should be updated to the virtual function so that it can be overrided.
 
The ERC721 smart contract COULD expect receivers to implement LSP1.
This is especially recommended for the LUKSO network, to improve the overall compatibility and future proofness of assets and universal profiles based on (LSP1)[https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-3-UniversalProfile.md]. 

### Constructor

```solidity
 constructor(address newOwner, string memory name, string memory symbol, string memory baseURI)
```
To define the NFT name, symbol and baseURI ,the ERC721 default name, symbol and baseURI are used.

Symbols should be UPPERCASE, without spaces and contain only ASCII.

BaseURI should be the address of the ERC725Y smart contract(Metadata).
 
Example:
```js
name() => 'MY Non Fungible Token'
symbol() => 'MNFT'
baseURI() => '0xD0292eF97Fc40B103755972F121e41a800F14657'
```

The ERC725Y smart contract SHOULD have the following format:

```json
{
 "ERC725YMetaData": {
     "name":"Josh K",
     "description":"A seldom Card of season 2021.",
     "external_url":"?referrer=...",
     "image":"https://ipfs.lukso.network/ipfs/QmcNWt4tZsFcNPwTPALJ8zgeLBrudNojfSMzQ7ntHYWToF",
     "attributes":[
          {
             "trait_type":"platform",
             "value":"Fanzone.io",
             "address":"0x40FCFBBcBC8154a8dD1A539558419CcaA05DD240"
         },
             {
             "trait_type":"zone",
             "value":"Football",
             "address":"0x44f4595B475C0681e153d8eb55D88163Bd658a71"
         },
         {
             "trait_type":"league",
             "value":"Partner D",
             "address":"0x9dBd66D2D31Ee01f790094f72E69b09cb5d554f1"
         },
         {
             "trait_type":"team",
             "value":"GER",
             "address":"0x7D417b9704aE84B3e4B359215692676c285E6b06"
         },
         {
             "trait_type":"athlete",
             "value":"Rui",
             "address":"0x2368653729e016c77194db560490239a9ab96b8f"
         },
         {
             "trait_type":"other_team",
             "value":"FC Berlin",
             "address":"0x2368653729e016c77194db560490239a9ab96b8f"
         },
         {
             "trait_type":"season",
             "value":"2021",
             "address":"0x0b5078372aabc617b239c8d6cf5d5d05866ab320" 
         },
         {
             "trait_type":"scarcity",
             "value":"Uncommon"
         },
         {
             "trait_type":"position",
             "value":"Midfielder"
         },
         {
             "trait_type":"edition",
             "value":"classic"
         },
         {
             "trait_type":"jersey",
             "value":"home"
         },
         {
             "trait_type":"language",
             "value":"en"
         },
         {
             "trait_type":"print_date",
             "value":1605754960,
             "display_type":"date"
         }
     ]
 }
}
```
### Keys

#### SupportedStandards

The supported standard SHOULD be `LSP6UniqueDigitalCollectible`

```solidity
key: '0xeafec4d89fa9619884b6b891356264550000000000000000000000007a21a5c1'
value: '0x7a21a5c1'
```

## Rationale

## Implementation

A implementation can be found in the [fanzone-media/standard-implementations](https://github.com/fanzone-media/standards-implementations/blob/master/contracts/UniqueDigitalCollectible/LSP6UniqueDigitalCollectible.sol);
The below defines the JSON interface of the `LSP6UniqueDigitalCollectible`.

ERC725Y JSON Schema `LSP6UniqueDigitalCollectible`:
```json
[
    {
        "name": "SupportedStandards:LSP6UniqueDigitalCollectible",
        "key": "0xeafec4d89fa9619884b6b891356264550000000000000000000000007a21a5c1",
        "keyType": "Mapping",
        "valueContent": "0x7a21a5c1",
        "valueType": "bytes"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
