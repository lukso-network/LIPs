---
lip: 34
title: External Minting Rights
author: Fabian Vogelsteller <fabian@universaleverything.io>, Thomas Beard <thomas@universaleverything.io>
discussions-to: https://t.me/+PjX_Awnpjh8xYWE0
status: Draft
type: LSP
created: 2025-03-20
requires: ERC725Y
---

## Simple Summary

A single [ERC725Y] data key that grants minting rights on a contract to whoever controls an external source — typically an [LSP8] tokenId.

## Abstract

This standard defines **one** data key, `LSP34OwnershipSource`, that points to an external contract (and optionally a tokenId) from which the implementing contract resolves an **authorized minter**.

The contract's `owner()` remains the standard [ERC173] owner (the artist). `LSP34OwnershipSource` does **not** override ownership — it only grants the resolved address permission to call `mint()`. This is used, for example, by an [LSP7] track token in [LSP33] Music NFTs: the artist stays the owner and controls metadata, while the address controlling the linked [LSP8] tokenId can mint new units.

## Motivation

Some contracts need to let an external party mint tokens without giving up ownership. For example, a label or platform that controls an LSP8 release should be able to mint collectible units on the corresponding LSP7 track, while the artist retains full control over metadata and contract ownership. LSP34 provides a single declarative pointer: *"whoever controls that token can mint here."*

## Specification

### ERC725Y Data Key

#### LSP34OwnershipSource

```json
{
  "name": "LSP34OwnershipSource",
  "key": "0xa8bc5aea0671308a0920eb016db4108c486ef117a7cd18bf3a9dfcadab6232e1",
  "keyType": "Singleton",
  "valueType": "(address,bytes32)",
  "valueContent": "(Address,bytes32)"
}
```

**Value encoding:** `abi.encode(address sourceContract, bytes32 tokenId)`

- `sourceContract` — the contract to query for the authorized minter.
- `tokenId` — the tokenId to query on `sourceContract`. If `bytes32(0)`, query `owner()` on `sourceContract` instead of `tokenOwnerOf(tokenId)`.

### Minting Rights Resolution

A contract implementing LSP34 MUST allow `mint()` to be called by:

1. The contract's own `owner()` (standard [ERC173] owner — the artist), **or**
2. The address resolved from `LSP34OwnershipSource`:
   - If `tokenId != bytes32(0)`, this is `ILSP8(sourceContract).tokenOwnerOf(tokenId)`.
   - If `tokenId == bytes32(0)`, this is `IERC173(sourceContract).owner()`.

If `LSP34OwnershipSource` is unset, only the contract's `owner()` can mint.

### Ownership

LSP34 does **not** affect `owner()`. The contract's [ERC173] owner remains unchanged regardless of whether `LSP34OwnershipSource` is set. This means:

- `owner()` always returns the standard [ERC173] owner.
- `transferOwnership(address)` and `renounceOwnership()` behave as standard [ERC173].
- `setData` and `setDataBatch` remain restricted to the contract's `owner()` (the artist).

Only minting rights are delegated. The artist retains full control over metadata, ownership, and contract configuration.

### Access Control

`LSP34OwnershipSource` is protected by standard ERC725Y access control — only the current `owner()` can set it.

## Rationale

LSP34 is intentionally minimal: one data key, one resolution rule for minting rights. The `bytes32` tokenId field handles both cases (LSP8 tokenId owner, or plain ERC173 `owner()`) without a second key.

`bytes32(0)` is reserved as the "call owner() instead" sentinel. Implementations using sequential `uint256` tokenIds SHOULD start from `1`.

By keeping ownership untouched, LSP34 ensures that artists never lose control over their contracts. The only capability delegated is minting, which is a narrow, well-defined permission.

## Implementation

Reference implementation: [lukso-network/lsp-smart-contracts#1088](https://github.com/lukso-network/lsp-smart-contracts/pull/1088).

ERC725Y JSON Schema `LSP34ExternalOwnership`:

```json
[
  {
    "name": "LSP34OwnershipSource",
    "key": "0xa8bc5aea0671308a0920eb016db4108c486ef117a7cd18bf3a9dfcadab6232e1",
    "keyType": "Singleton",
    "valueType": "(address,bytes32)",
    "valueContent": "(Address,bytes32)"
  }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC173]: https://eips.ethereum.org/EIPS/eip-173
[ERC725Y]: https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#erc725y
[LSP7]: ./LSP-7-DigitalAsset.md
[LSP8]: ./LSP-8-IdentifiableDigitalAsset.md
[LSP33]: ./LSP-33-MusicNFT.md
