---
lip: 35
title: Identifiable Digital Asset Entanglement
author: Fabian Vogelsteller <fabian@universaleverything.io>, Thomas Beard <thomas@universaleverything.io>
discussions-to: https://t.me/+PjX_Awnpjh8xYWE0
status: Draft
type: LSP
created: 2025-03-20
requires: ERC165, ERC725Y, LSP4, LSP7, LSP8, LSP34
---

## Simple Summary

A generic linking standard that connects an [LSP8] tokenId to an [LSP7] digital asset contract. The LSP8 acts as a transparent metadata router for the linked LSP7, so reading or writing token metadata on the LSP8 transparently proxies to the LSP7.

## Abstract

LSP35 defines the **structural entanglement** between an [LSP8] identifiable digital asset and an [LSP7] digital asset. It specifies:

- A data key, `LSP35OwnableToken`, set per-tokenId on the LSP8, pointing to a linked LSP7.
- **Data routing** — the LSP8 acts as a transparent router for metadata reads/writes, proxying `LSP4Metadata` (and any application-defined metadata key) to the linked LSP7.
- **Bidirectional link verification** — the LSP8 verifies the LSP7 points back before committing the link.
- **Parent authorization** — the linked LSP7 accepts metadata writes from the parent LSP8 contract.

LSP35 is purely about **how two contracts are linked and how metadata is routed**, not about what that metadata contains or who is allowed to mint. Metadata schemas are an application concern (e.g. [LSP33] for music). Minting rights delegation is handled separately by [LSP34].

## Motivation

Many digital asset use cases need to model a "container of items" where each item is itself an independently ownable digital asset. An LSP8 collection naturally represents the container, and a per-item LSP7 contract naturally represents fungible/divisible units of that item. Linking the two requires a standard way to:

1. **Point** an LSP8 tokenId at an LSP7 contract.
2. **Route** metadata transparently — so reading metadata for an LSP8 tokenId returns the linked LSP7's data.
3. **Forward** metadata writes — so the asset owner can manage everything from a single entry point.
4. **Verify** the link is bidirectional — preventing stale or invalid references.

LSP35 provides this linking layer as a standalone primitive. It is application-neutral: it does not assume music, art, gaming, or any particular metadata schema.

## Specification

### Linking (Plug and Play)

Linking is a single write per side:

1. On the LSP7: set `LSP8ReferenceContract` = `(lsp8Address, tokenId)` so the LSP7 knows its parent.
2. On the LSP8: call `setDataForTokenId(tokenId, LSP35OwnableToken, lsp7Address)`.

Both writes MUST be authorized by the contract `owner()` of the respective contract (the LSP8's [ERC173] `owner()` for the LSP8 side, and the LSP7's [ERC173] `owner()` for the LSP7 side). The LSP8 SHOULD verify the [bidirectional link](#bidirectional-link-verification) before committing.

Because linking is just two data-key writes, any of these workflows is valid:

1. **Container-first.** Deploy an LSP8, mint metadata-only tokenIds. Later, deploy an LSP7 for any tokenId and link it — that tokenId becomes ownable as fungible units without touching the others.
2. **Item-first.** Deploy a standalone LSP7. Later, deploy or reuse an LSP8, mint a tokenId for this item, and link.
3. **Both at once.** Deploy LSP8 + LSP7 in one transaction and link immediately.
4. **Pure standalone.** Deploy only an LSP7. It never has to join a collection.

A tokenId with no `LSP35OwnableToken` is a **metadata-only tokenId** — useful for cataloguing or proving existence without issuing fungible units.

### Data Routing

When `LSP35OwnableToken` is set for a tokenId, the LSP8 MUST act as a transparent router for the data key `LSP4Metadata` (and any additional metadata data keys the implementation chooses to route, such as `LSP33Metadata` in the music NFT case). All other data keys are read/written locally on the LSP8's tokenId storage.

**Reads — `getDataForTokenId(tokenId, dataKey)`:**

```
LSP35OwnableToken unset OR dataKey not a routed metadata key
  → return LSP8 local tokenId storage

otherwise
  → call LSP7.getData(dataKey)
     success → return LSP7 value
     revert  → fall back to LSP8 local tokenId storage
```

The fallback keeps metadata available if the linked LSP7 becomes unreachable.

**Writes — `setDataForTokenId(tokenId, dataKey, value)`:**

```
require: msg.sender == owner()   // the LSP8 ERC173 contract owner

LSP35OwnableToken unset OR dataKey not a routed metadata key
  → write to LSP8 local tokenId storage, emit TokenIdDataChanged

otherwise
  → call LSP7.setData(dataKey, value)
     success → LSP7 emits DataChanged; LSP8 emits no event
     revert  → whole call reverts
```

**Access control.** `setDataForTokenId` is gated by the LSP8's contract `owner()` ([ERC173]) — **not** by `tokenOwnerOf(tokenId)`. Token ownership confers transferability of the unit, not authorship of the metadata. This prevents collectors from overwriting authoritative metadata after acquiring a tokenId.

**Events.** The LSP8 does **not** emit `TokenIdDataChanged` for forwarded writes — the data lives on the LSP7, which emits its own `DataChanged`. Indexers MUST follow the `LSP35OwnableToken` link and subscribe to `DataChanged` on the LSP7. `TokenIdDataChanged` on the LSP8 only reflects locally stored data.

#### Parent Authorization

A linked LSP7 MUST accept `setData` / `setDataBatch` if **either**:

1. `msg.sender == owner()` (the LSP7's [ERC173] contract owner), **or**
2. `msg.sender` equals the parent LSP8 address decoded from the LSP7's `LSP8ReferenceContract` data key.

This is safe because the LSP8 already enforces its own `owner()` before forwarding, and the LSP7 only trusts whichever LSP8 has been pinned in its `LSP8ReferenceContract`.

#### Bidirectional Link Verification

Before setting `LSP35OwnableToken` for a tokenId, the LSP8 SHOULD verify that the referenced LSP7's `LSP8ReferenceContract` points back to `(address(this), tokenId)`. If verification fails, the call SHOULD revert.

### Relationship to LSP-34 (Minting Rights)

LSP35 says nothing about who may mint additional units of a linked LSP7. That is the concern of [LSP34]: an LSP7 MAY set `LSP34OwnershipSource` to `(lsp8Address, tokenId)` to grant minting rights to whoever currently controls that LSP8 tokenId, while leaving its own `owner()` (and its `setData` permissions) unchanged. LSP34 and LSP35 are independent and may be adopted separately.

### ERC725Y Data Keys

#### LSP35OwnableToken

```json
{
  "name": "LSP35OwnableToken",
  "key": "0xf15b1730dc1b8c28a2d5eafc16b4ecfcf13a69f6a7cd1a6067ee2a4fe2990e4c",
  "keyType": "Singleton",
  "valueType": "address",
  "valueContent": "Address"
}
```

Set per-tokenId on the LSP8 via `setDataForTokenId`, pointing to a linked LSP7.

- **Unset** → the tokenId is metadata-only.
- **Set** → the referenced LSP7 is treated as the authoritative metadata source for this tokenId.

Requirements:

- MUST only be settable by the LSP8's contract `owner()` ([ERC173]).
- SHOULD be verified bidirectionally before being set.
- SHOULD NOT be changed once set, to preserve the integrity of metadata referenced by existing LSP7 holders.

The value MAY be encoded as either 20 bytes (`abi.encodePacked(address)`) or 32 bytes (`abi.encode(address)`). Implementations MUST handle both.

## Rationale

**Plug-and-play composition.** The LSP8 container and LSP7 item are independent building blocks joined by a single data key. Any workflow — container-first, item-first, both-at-once, or pure standalone — works from the same primitives. No migration contracts, no special "upgrade" paths.

**Transparent data routing.** Making the LSP8 a router for linked LSP7 metadata gives applications a single entry point, prevents metadata drift between contracts, and degrades gracefully to LSP8 local storage if the LSP7 is unreachable.

**`owner()` access control on writes.** Gating `setDataForTokenId` on the LSP8's `owner()` — not on `tokenOwnerOf(tokenId)` — preserves the distinction between authorship (held by the contract owner) and collectibility (held by tokenId / LSP7 unit holders). A collector who buys a tokenId or LSP7 units never gains the ability to rewrite the metadata they bought into.

**Application neutral.** LSP35 specifies only the entanglement and routing mechanics. Metadata schemas (e.g. [LSP33] for music) and minting delegation ([LSP34]) are layered on top, so each concern can evolve independently.

## Implementation

Reference implementation: [lukso-network/lsp-smart-contracts#1088](https://github.com/lukso-network/lsp-smart-contracts/pull/1088).

ERC725Y JSON Schema `LSP35IdentifiableDigitalAssetEntanglement`:

```json
[
  {
    "name": "LSP35OwnableToken",
    "key": "0xf15b1730dc1b8c28a2d5eafc16b4ecfcf13a69f6a7cd1a6067ee2a4fe2990e4c",
    "keyType": "Singleton",
    "valueType": "address",
    "valueContent": "Address"
  }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC173]: https://eips.ethereum.org/EIPS/eip-173
[ERC725Y]: https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#erc725y
[LSP4]: ./LSP-4-DigitalAsset-Metadata.md
[LSP7]: ./LSP-7-DigitalAsset.md
[LSP8]: ./LSP-8-IdentifiableDigitalAsset.md
[LSP33]: ./LSP-33-MusicNFT.md
[LSP34]: ./LSP-34-ExternalOwnership.md
