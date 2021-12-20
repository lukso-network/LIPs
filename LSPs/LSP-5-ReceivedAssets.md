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
This key value standard describes a set of keys that can be added to an [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract.
Two keys are proposed to reference received asset smart contracts.

- `LSP5ReceivedAssets[]` to hold an array of addresses.
- `LSP5ReceivedAssetsMap` to hold:
  - the index in the former array where the received asset address is stored.
  - an [ERC165 interface ID](https://eips.ethereum.org/EIPS/eip-165) to easily identify the standard used by each asset smart contracts, without the need to query the contracts directly. 

The key `LSP5ReceivedAssetsMap` also helps to prevent adding duplications to the array, when automatically added via smart contract (e.g. a [LSP1-UniversalReceiverDelegate](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md)).

## Motivation
To be able to display received assets in a profile we need to keep track of all received asset contract addresses. This is important for [LSP3 UniversalProfile](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-3-UniversalProfile-Metadata.md), but also Vault smart contracts.

## Specification

Every contract that supports to the ERC725Account SHOULD have the following keys:

### ERC725Y Keys


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

## Rationale

## Implementation

An implementation can be found in the [LSP1UniversalReceiverDelegate](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/main/contracts/LSP1UniversalReceiver/LSP1UniversalReceiverDelegateUP/LSP1UniversalReceiverDelegateUP.sol) smart contract. The below defines the JSON interface of the `LSP5ReceivedAssets`.

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
