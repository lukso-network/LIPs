---
lip: 12
title: IssuedAssets
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2022-05-24
requires: LSP2
---

## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data key values to store addresses of issued assets by an [ERC725X](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract.

## Abstract
This data key value standard describes a set of data keys that can be added to an [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract to describe issued assets:


- `LSP12IssuedAssets[]` is an [LSP2 array](./LSP-2-ERC725YJSONSchema.md) of addresses.
- `LSP12IssuedAssetsMap` is a dynamic address mapping, which contains:
  - an [ERC165 interface ID](https://eips.ethereum.org/EIPS/eip-165) to easily identify the standard used by the mapped asset smart contract
  - and the index in the `LSP12IssuedAssets[]` array.

The data key `LSP12IssuedAssetsMap` exists so that smart contracts can detect if an address is present in the array (e.g. as done in the  [LSP1-UniversalReceiverDelegate](./LSP-1-UniversalReceiver.md)).

## Motivation
This standard allows any smart contract to state that it issued a certain asset. The asset itself MUST reference the issuer smart contract as well, for it be verifable issued. This allows other smart contracts to link the authenticity of an asset to a specific issuer. See also [LSP4 - DigitalAsset Metadata](./LSP-4-DigitalAsset-Metadata.md) for the `owner` and `LSP4Creators[]`.

A full verification flow for an asset should contain a check on the asset and the issuer smart contract. If we use an asset using [LSP4 - DigitalAsset Metadata](./LSP-4-DigitalAsset-Metadata.md) and a [LSP0 - ERC725Account](./LSP-0-ERC725Account.md) as the issuer. The flow should looks as follows:

1. Smart contract that receives asset, should check for the `owner` or the `LSP4Creators[]` array and retrieve an issuer address.
2. Then check on the issuer that a `LSP12IssuedAssetsMap` is set for this asset address

## Specification

Every contract that supports the ERC725Account SHOULD have the following data keys:

### ERC725Y Data Keys


#### LSP12IssuedAssets[]

An array of issued smart contract assets, like tokens (_e.g.: [LSP7 Digital Assets](./LSP-7-DigitalAsset)_) and NFTs (_e.g.: [LSP8 Identifiable Digital Assets](./LSP-8-IdentifiableDigitalAsset)_).


```json
{
    "name": "LSP12IssuedAssets[]",
    "key": "0x7c8c3416d6cda87cd42c71ea1843df28ac4850354f988d55ee2eaa47b6dc05cd",
    "keyType": "Array",
    "valueType": "address",
    "valueContent": "Address"
}
```

For more info about how to access each index of the `LSP12IssuedAssets[]` array, see [ERC725Y JSON Schema > `keyType`: `Array`](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#array)

#### LSP12IssuedAssetsMap

References issued smart contract assets, like tokens (_e.g.: [LSP7 Digital Assets](./LSP-7-DigitalAsset)_) and NFTs (_e.g.: [LSP8 Identifiable Digital Assets](./LSP-8-IdentifiableDigitalAsset)_).

The data value MUST be constructed as follows: `bytes4(standardInterfaceId) + bytes8(indexNumber)`. Where:
- `standardInterfaceId` = the [ERC165 interface ID](https://eips.ethereum.org/EIPS/eip-165) of the standard that the token or asset smart contract implements (if the ERC165 interface ID is unknown, `standardInterfaceId = 0xffffffff`).
- `indexNumber` = the index in the [`LSP12IssuedAssets[]` Array](#LSP12Issuedassets)

Value example: `0xe33f65c3000000000000000c` (interfaceId: `0xe33f65c3`, index position `0x000000000000000c = 12`).

```json
{
    "name": "LSP12IssuedAssetsMap:<address>",
    "key": "0x74ac2555c10b9349e78f0000<address>",
    "keyType": "Mapping",
    "valueType": "(bytes4,bytes8)",
    "valueContent": "(Bytes4,Number)"
}
```

## Rationale

## Implementation

ERC725Y JSON Schema `LSP12IssuedAssets`:
```json
[
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
        "valueType": "(bytes4,bytes8)",
        "valueContent": "(Bytes4,Number)"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
