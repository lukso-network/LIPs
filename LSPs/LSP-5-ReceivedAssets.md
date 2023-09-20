---
lip: 5
title: Received Assets
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: LSP2
---

## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data key values to store addresses of received assets in a [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract.

## Abstract
This data key value standard describes a set of data keys that can be added to an [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract to describe received assets:

- `LSP5ReceivedAssets[]` is an [LSP2 array](./LSP-2-ERC725YJSONSchema.md) of addresses.
- `LSP5ReceivedAssetsMap` is a dynamic address mapping, which contains:
  - an [ERC165 interface ID](https://eips.ethereum.org/EIPS/eip-165) to easily identify the standard used by the mapped asset smart contract
  - and the index in the `LSP5ReceivedAssets[]` array.

The data key `LSP5ReceivedAssetsMap` exists so that smart contracts can detect if an address is present in the array (e.g. as done in the  [LSP1-UniversalReceiverDelegate](./LSP-1-UniversalReceiver.md)).

## Motivation
This standard allows to create a decentralised portfolio of owned assets by a smart contract. See [LSP3 - Profile Metadata](./LSP-3-Profile-Metadata.md), or [LSP9 Vault](./LSP-9-Vault.md).

## Specification

Every contract that supports the ERC725Account SHOULD have the following data keys:

### ERC725Y Data Keys


#### LSP5ReceivedAssets[]

An array of received smart contract assets, like tokens (_e.g.: [LSP7 Digital Assets](./LSP-7-DigitalAsset)_) and NFTs (_e.g.: [LSP8 Identifiable Digital Assets](./LSP-8-IdentifiableDigitalAsset)_).


```json
{
    "name": "LSP5ReceivedAssets[]",
    "key": "0x6460ee3c0aac563ccbf76d6e1d07bada78e3a9514e6382b736ed3f478ab7b90b",
    "keyType": "Array",
    "valueType": "address",
    "valueContent": "Address"
}
```

For more info about how to access each index of the `LSP5ReceivedAssets[]` array, see [ERC725Y JSON Schema > `keyType`: `Array`](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#array)

#### LSP5ReceivedAssetsMap

References received smart contract assets, like tokens (_e.g.: [LSP7 Digital Assets](./LSP-7-DigitalAsset)_) and NFTs (_e.g.: [LSP8 Identifiable Digital Assets](./LSP-8-IdentifiableDigitalAsset)_). This data key exists so that smart contracts can detect whether the address of an asset is present in the `LSP5ReceivedAssets[]` array without looping all over it on-chain. Moreover, it helps to identify at which index in the `LSP5ReceivedAssets[]` the asset address is located for easy access and to change or remove this specific asset from the array. Finally, it also allows the detection of the interface supported by the asset.

The data value MUST be constructed as follows: `bytes4(standardInterfaceId) + uint128(indexNumber)`. Where:
- `standardInterfaceId` = the [ERC165 interface ID](https://eips.ethereum.org/EIPS/eip-165) of the standard that the token or asset smart contract implements (if the ERC165 interface ID is unknown, `standardInterfaceId = 0xffffffff`).
- `indexNumber` = the index in the [`LSP5ReceivedAssets[]` Array](#lsp5receivedassets)

Value example: `0x5fcaac27000000000000000c` (interfaceId: `0x5fcaac27` for a [LSP7](./LSP-7-DigitalAsset.md) token, index position `0x000000000000000c = 12`).

```json
{
    "name": "LSP5ReceivedAssetsMap:<address>",
    "key": "0x812c4334633eb816c80d0000<address>",
    "keyType": "Mapping",
    "valueType": "(bytes4,uint128)",
    "valueContent": "(Bytes4,Number)"
}
```

## Rationale

## Implementation

An implementation of setting received assets from a smart contract can be found in the [LSP1UniversalReceiverDelegate](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/main/contracts/LSP1UniversalReceiver/LSP1UniversalReceiverDelegateUP/LSP1UniversalReceiverDelegateUP.sol) smart contract.

ERC725Y JSON Schema `LSP5ReceivedAssets`:
```json
[
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
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
