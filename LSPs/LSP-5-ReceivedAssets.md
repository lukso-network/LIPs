---
lip: 5
title: ReceivedAssets
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: LSP2
---

## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key values to store addresses of received assets in a [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract.

## Abstract
This key value standard describes keys to be added to and [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract, that reference received asset smart contracts. Two keys are proposed: `LSP5ReceivedAssets[]` to hold an array of addresses and `LSP5ReceivedAssetsMap` to hold a mapping of the index in the former array and an standards interface ID to be able to quickly tell different assets standards apart without querying each other asset smart contract directly. The key `LSP5ReceivedAssetsMap` also helps to prevent adding duplications to the array, when automatically added via smart contract (e.g. a [LSP1-UniversalReceiverDelegate](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md)).

## Motivation
To be able to display received assets in a profile we need to keep track of all received asset contract addresses. This is important for [LSP3 UniversalProfile](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-3-UniversalProfile.md), but also Vault smart contracts.

## Specification

Every contract that supports to the ERC725Account SHOULD have the following keys:

### Keys

#### LSP5ReceivedAssetsMap

References issued smart contract assets, like tokens and NFTs.

The `valueContent` MUST be constructed as follows: `bytes8(indexNumber) + bytes4(standardInterfaceId)`. Where `indexNumber` is the index in the [LSP3IssuedAssets[] Array](#lsp3issuedassets) and `standardInterfaceId` the interface ID if the token or asset smart contract standard.

```json
{
    "name": "LSP5ReceivedAssetsMap:<address>",
    "key": "0x812c4334633eb81600000000<address>",
    "keyType": "Mapping",
    "valueContent": "Mixed",
    "valueType": "bytes"
}
```

#### LSP5ReceivedAssets[]

References issued smart contract assets, like tokens and NFTs.

```json
{
    "name": "LSP5ReceivedAssets[]",
    "key": "0x6460ee3c0aac563ccbf76d6e1d07bada78e3a9514e6382b736ed3f478ab7b90b",
    "keyType": "Array",
    "valueContent": "Address",
    "valueType": "address"
}
```

## Rationale

## Implementation

A implementation can be found in the [lukso-network/standards-scenarios](https://github.com/lukso-network/standards-scenarios/blob/master/contracts/XXX);
The below defines the JSON interface of the `LSP5ReceivedAssets`.

ERC725Y JSON Schema `LSP5ReceivedAssets`:
```json
[
    {
        "name": "LSP5ReceivedAssetsMap:<address>",
        "key": "0x812c4334633eb81600000000<address>",
        "keyType": "Mapping",
        "valueContent": "Mixed",
        "valueType": "bytes"
    },
    {
        "name": "LSP5ReceivedAssets[]",
        "key": "0x6460ee3c0aac563ccbf76d6e1d07bada78e3a9514e6382b736ed3f478ab7b90b",
        "keyType": "Array",
        "valueContent": "Address",
        "valueType": "address"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
