---
lip: 26
title: Smart Contract Generated Image
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2023-10-18
requires: ERC165, ERC725Y, LSP2
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


<!-- #### SupportedStandards:LSP26SmartContractGeneratedImage

The supported standard SHOULD be `LSP26SmartContractGeneratedImage`

```json
{
    "name": "SupportedStandards:LSP26SmartContractGeneratedImage,
    "key": "0xeafec4d89fa9619884b6000066dd77705f8478e25be2bac9497eb3d614cd9054",
    "keyType": "Mapping",
    "valueType": "bytes4",
    "valueContent": "0xeafec4d8"
}
``` -->


#### LSP26SmartContractGeneratedImage


```json
{
    "name": "LSP26SmartContractGeneratedImage",
    "key": "0x66dd77705f8478e25be2bac9497eb3d614cd9054bcbbe0bbf7258139b6b06bd6",
    "keyType": "Singleton",
    "valueType": "(bytes16,bytes)",
    "valueContent": "(String,String)"
}
```


## Rationale

Profile's metadata is important for creating a verifiable public account that is the source of asset issuance,
or a verifiable public appearance. This metadata does not need to belong to a real world person, but gives the account a "recognisable face".

## Implementation

A implementation can be found in the [lukso-network/universalprofile-smart-contracts](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/main/contracts/UniversalProfile.sol);
The below defines the JSON interface of the `LSP3UniversalProfile`.

ERC725Y JSON Schema `LSP3UniversalProfile`:

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
        "valueContent": "JSONURL"
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
