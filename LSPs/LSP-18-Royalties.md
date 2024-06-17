---
lip: 18
title: Royalties
author: Volodymyr Lykhonis <vlad@universal.page>, Jake Prins <jake@universal.page> 
discussions-to: https://discord.gg/E2rJPP4
status: RFC
type: LSP
created: 2022-11-23
requires: LSP2
---

## Simple Summary

This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data key values to store royalties recipient addresses and corresponding percentages in a [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract.

## Abstract

LSP18 is a metadata standard that defines two data keys that can be added to an [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract to describe royalties:

- `LSP18RoyaltiesRecipients` is a [LSP2 BytesCompactArray](./LSP-2-ERC725YJSONSchema.md#bytescompactbytesarray) of royalties recipient that contains:
  - a recipient's interface id 
  - a recipient's address
  - a royalties share (percent)
- `LSP18RoyaltiesEnforcePayment` is a boolean to enforce royalties whenever the NFT is sold at loss.

## Motivation

This standard allows to create a decentralised asset royalties allocations by a smart contract.

## Specification

Every contract that supports the LSP18Royalties MUST have the following data keys:

### ERC725Y Data Keys

#### LSP18RoyaltiesRecipients

An array of royalties recipients and corresponding percentages.

The data value MUST be a [LSP2 BytesCompactArray](./LSP-2-ERC725YJSONSchema.md#bytescompactbytesarray) which contains a list of royalties recipients. Each royalties recipient is a tuple of:
- `interfaceId` = an interface identifing a recipient of royalties. If the interface is not known, it is assumed to be `0xffffffff`.
- `recipient` = address of a recipient to receive royalties
- `points` = a percentage in points where `100_000` is basis. e.g. `15%` is `15_000` points, and `1.5%` is `1_500` points.

```json
{
    "name": "LSP18RoyaltiesRecipients",
    "key": "0xc0569ca6c9180acc2c3590f36330a36ae19015a19f4e85c28a7631e3317e6b9d",
    "keyType": "Singleton",
    "valueType": "(bytes4,address,uint32)[CompactBytesArray]",
    "valueContent": "(Bytes4,Address,Number)"
}
```

A compact byte array allows optionally to store additional fields if needed. Required fields are: `interfaceId` and `recipient`. The `points` field is optional and if not provided it is assumed to be `0` points.

#### LSP18RoyaltiesEnforcePayment

A boolean when `true` to indicate enforcement of royalties even if a NFT is sold at a loss. By default this is `false`, and a marketplace may not enforce royalties.

```json
{
    "name": "LSP18RoyaltiesEnforcePayment",
    "key": "0x580d62ad353782eca17b89e5900e7df3b13b6f4ca9bbc2f8af8bceb0c3d1ecc6",
    "keyType": "Singleton",
    "valueType": "boolean",
    "valueContent": "Boolean"
}
```

## Rationale

## Implementation

ERC725Y JSON Schema `LSP18Royalties`:
```json
[
    {
        "name": "LSP18RoyaltiesRecipients",
        "key": "0xc0569ca6c9180acc2c3590f36330a36ae19015a19f4e85c28a7631e3317e6b9d",
        "keyType": "Singleton",
        "valueType": "(bytes4,address,uint32)[CompactBytesArray]",
        "valueContent": "(Bytes4,Address,Number)"
    },
    {
        "name": "LSP18RoyaltiesEnforcePayment",
        "key": "0x580d62ad353782eca17b89e5900e7df3b13b6f4ca9bbc2f8af8bceb0c3d1ecc6",
        "keyType": "Singleton",
        "valueType": "boolean",
        "valueContent": "Boolean"
    }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
