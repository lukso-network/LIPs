---
lip: 33
title: Music NFT
author: Fabian Vogelsteller <fabian@universaleverything.io>, Thomas Beard <thomas@universaleverything.io>
discussions-to: https://t.me/+PjX_Awnpjh8xYWE0
status: Draft
type: LSP
created: 2025-03-20
requires: ERC725Y, LSP2, LSP4
---

## Simple Summary

A generic music metadata standard for any [ERC725Y] contract on LUKSO. Defines the structured data that any contract carrying music — an [LSP7] token, an [LSP8] tokenId, a profile, a vault, or any future ERC725Y-based contract — uses to describe a release or track.

## Abstract

LSP33 defines a **metadata schema** for music. It is **token-type neutral** and **contract-type neutral**: any [ERC725Y]-compatible contract can carry LSP33 metadata, regardless of whether it represents fungible units, identifiable items, a profile, a vault, or anything else. The schema is the standard; the carrier is up to the application.

LSP33 specifies:

- An **`LSP33Metadata`** data key for structured music data (contributors, identifiers, copyright, lyrics, preview, stems, DDEX, AI usage).
- Required **`LSP4Metadata` attributes** for release-level and track-level information (artist, genre, release date, etc.).
- A **`SupportedStandards:LSP33MusicNFT`** marker so indexers and interfaces can identify music-bearing contracts.

LSP33 is purely about **what data a music asset carries**. It does not prescribe a token type, an ownership model, a linking scheme, or a minting policy:

- For carrying music on an [LSP7] token contract or per-tokenId on an [LSP8] collection — both work out of the box, because both are [ERC725Y].
- For linking an [LSP8] container tokenId to an [LSP7] item contract with transparent metadata routing, see [LSP35].
- For delegating minting rights to the holder of an external token, see [LSP34].

A developer adding music metadata to a brand-new contract type only needs to ensure the contract implements [ERC725Y] and writes the data keys defined below.

### Artist vs Collector Ownership (example role model)

LSP33 itself does not prescribe an ownership model — that is up to the carrier. However, the most common arrangement for music releases on LUKSO is an [LSP8] container holding tokenIds for each track, optionally entangled with a per-track [LSP7] item contract via [LSP35], with minting rights delegated via [LSP34]. In that arrangement the roles separate cleanly:

| | **Artist** | **Minter** | **Collector** |
|---|---|---|---|
| **What they hold** | LSP8 `owner()` and/or LSP7 `owner()` ([ERC173]) | LSP8 `tokenOwnerOf(tokenId)` (via [LSP34]) | LSP7 units (`balanceOf`) |
| **Can do** | Set metadata on the contracts they own | Mint additional LSP7 units of their tokenId | Transfer / trade units |
| **Tradeable?** | No — represents authorship | Yes — represents the right to mint | Yes — fungible units |

Holding an LSP8 tokenId or LSP7 units never grants control over metadata. Authorship of metadata always stays with the [ERC173] contract `owner()` (the artist). When LSP33 is carried by a different contract type (a profile, a vault, a custom contract), the ownership model is whatever that carrier defines — LSP33 only requires that the metadata is reachable via [ERC725Y].

## Motivation

Music on-chain needs a way to describe releases and tracks with **provenance** (prove creation without selling), **industry compatibility** (DDEX, ISRC, ISWC, GRid for DSP interoperability), and **AI transparency** (DDEX ERN 4.3.2 disclosure fields).

Existing LUKSO standards already cover digital identity ([LSP0], [LSP3]), generic asset metadata ([LSP4]), token contracts ([LSP7], [LSP8]), and structured ERC725Y storage ([LSP2]) — but none of them describe music specifically, and none should: tying a music schema to a particular token type would force every future carrier (a vault, a profile, a streaming-rights contract) to reimplement it.

LSP33 fills the gap with a **carrier-neutral metadata schema**. The data lives wherever it makes sense; the schema stays the same.

## Specification

### Carrier Requirements

LSP33 metadata can be carried by **any [ERC725Y] contract**. An LSP33-compliant carrier MUST:

- Implement [ERC725Y].
- Set `SupportedStandards:LSP33MusicNFT` (see [data keys](#erc725y-data-keys) below) on the relevant ERC725Y storage scope (the contract level for contract-wide metadata, or the per-tokenId scope when the carrier supports per-item ERC725Y storage like [LSP8]).
- Set `LSP4Metadata` and `LSP33Metadata` on the same scope.
- Include the [required `LSP4Metadata` attributes](#lsp4metadata-attributes) for the chosen level (release or track).

The standard is intentionally agnostic about *which* ERC725Y contract carries the data. The following are common carriers, but they are examples — not the only valid options.

#### Example carrier — LSP7 token

An [LSP7] contract is a natural carrier when a track or release is represented as fungible / non-divisible units (collectible editions, signed copies, semi-fungible assets).

- SHOULD set `LSP4TokenType` = `1` (NFT/NDT) for a single track, or `2` (Collection) for a release.
- For a non-divisible track collectible, SHOULD set `decimals()` = `0`.
- All four LSP33 data keys live at the contract level.

#### Example carrier — LSP8 collection

An [LSP8] contract is a natural carrier when a release contains multiple distinct items (tracks of an album, editions of a release) that each need their own metadata scope.

- SHOULD set `LSP4TokenType` = `2` (Collection).
- SHOULD set `LSP8TokenIdFormat` = `0` (uint256). TokenIds SHOULD be sequential starting from `1`.
- Release-level metadata lives at the contract level.
- Per-track metadata is written via `setDataForTokenId(tokenId, LSP4Metadata|LSP33Metadata, value)`.

#### Other carriers

Any other [ERC725Y] contract — a profile ([LSP0]/[LSP3]), a vault ([LSP9]), or a future contract type — can carry LSP33 metadata simply by writing the data keys defined below to its ERC725Y storage. No new token primitive is required, and no specific ownership model is assumed.

For LSP8 ↔ LSP7 entanglement (transparent metadata routing from a container tokenId to an item contract), see [LSP35]. For delegating minting rights via an external token, see [LSP34]. Both are optional and orthogonal to the metadata schema.

### ERC725Y Data Keys

#### SupportedStandards:LSP33MusicNFT

```json
{
  "name": "SupportedStandards:LSP33MusicNFT",
  "key": "0xeafec4d89fa9619884b60000f43ae543d533ae7389b5791d7870aadfdcff2ca4",
  "keyType": "Mapping",
  "valueType": "bytes4",
  "valueContent": "0x3cd46617"
}
```

MUST be set on any [ERC725Y] contract that carries LSP33 metadata, regardless of carrier type (LSP7, LSP8, profile, vault, or any other ERC725Y contract).

#### LSP33Metadata

```json
{
  "name": "LSP33Metadata",
  "key": "0xbecee5b67fa43fb2e96c7c6ccdc23007fffc2b24205416b2122cd7b8d8ef48fa",
  "keyType": "Singleton",
  "valueType": "bytes",
  "valueContent": "VerifiableURI"
}
```

References the extended music metadata JSON file (see below). Can be set at the contract level on an LSP7 or LSP8, or per-tokenId on an LSP8.

### Metadata Model

LSP33 uses two data keys:

- **`LSP4Metadata`** (from [LSP4]) — human-readable: name, description, artwork, links, audio assets, attributes. MUST include top-level `"category": "Music"`.
- **`LSP33Metadata`** (this standard) — structured music data: contributors, identifiers, copyright, lyrics, preview, stems, DDEX.

Each key is typically a **separate JSON file**. They MAY be combined into a single JSON document with both keys as top-level properties (in which case both data keys reference the same URI) — an optimization, not a requirement.

#### LSP4Metadata Attributes

**Release level** (any contract scope describing a whole release — typically the contract level of an LSP7 release token or LSP8 collection, but valid on any [ERC725Y] scope):

| Attribute | Required | Description |
| :--- | :---: | :--- |
| `Artist` | ✓ | Primary artist or band name |
| `Release Type` | ✓ | `Single`, `EP`, `Album`, `Compilation` |
| `Release Date` | ✓ | ISO 8601 (`YYYY-MM-DD`) |
| `Primary Genre` | ✓ | Primary genre |
| `Track Count` | ✓ | Total number of tracks |
| `Label` |  | Record label |
| `Secondary Genre` |  | Secondary genre |
| `Language` |  | ISO 639-2 code |

**Track level** (any contract scope describing a single track — the contract level of an LSP7 track token, the per-tokenId scope of an LSP8 collection, or any other [ERC725Y] scope a carrier chooses):

| Attribute | Required | Description |
| :--- | :---: | :--- |
| `Artist` | ✓ | Track artist |
| `Track Number` | ✓ | Position in release (use `1` when standalone) |
| `Primary Genre` | ✓ | Primary genre |
| `Release Date` | ✓ | ISO 8601 |
| `Duration` |  | e.g. `3:35` or `PT3M35S` |
| `Disc Number` |  | For multi-disc releases |
| `Explicit Content` |  | `Explicit`, `NotExplicit`, `Cleaned` |
| `BPM` |  | Beats per minute |
| `Key` |  | Musical key (e.g. `Cm`, `F#`) |
| `Secondary Genre` |  | Secondary genre |
| `Language` |  | ISO 639-2 code |

#### LSP33Metadata Fields

| Field | Level | Description |
| :--- | :---: | :--- |
| `contributors` | Release & Track | Ordered list of contributors with roles |
| `identifiers` | Release & Track | Industry identifiers (ISRC, ISWC, UPC, GRid, catalogue) |
| `copyright` | Release & Track | `pLine` (℗) and `cLine` (©) |
| `lyrics` | Track | Full lyrics text, language, synced flag |
| `preview` | Track | `startMs`, `durationMs` |
| `stems` | Track | Stem/multitrack files |
| `ddex` | Release & Track | DDEX ERN XML reference |
| `audio_ai_usage` | Track (required) | Extent of generative AI used in the sound recording. One of `none`, `some`, `material`, `all` |
| `composition_ai_usage` | Track (required) | Extent of generative AI used in the underlying composition. One of `none`, `some`, `material`, `all` |
| `commercial_samples` | Track (required) | Whether the track contains third-party commercial material. One of `none`, `interpolation`, `sample` |

##### AI Classification (DDEX ERN 4.3.2)

LSP33 aligns with DDEX ERN 4.3.2's AI-disclosure model (as used by LabelGrid, Spotify and other DSPs). Every track MUST declare three top-level fields on its `LSP33Metadata`:

| Field | Required Values | Meaning |
| :--- | :--- | :--- |
| `audio_ai_usage` | `none`, `some`, `material`, `all` | How much of the **sound recording** was generated by AI. `none` = purely human, `some` = minor AI assistance, `material` = substantial AI generation combined with human work, `all` = entirely AI-generated. |
| `composition_ai_usage` | `none`, `some`, `material`, `all` | How much of the **underlying composition** (melody, lyrics, arrangement) was generated by AI. Same scale as above. |
| `commercial_samples` | `none`, `interpolation`, `sample` | Whether the track reuses third-party commercial material. `none` = original, `interpolation` = re-recorded/replayed reference to another work, `sample` = directly sampled recording. |

Additionally, every contributor object on a track MUST declare an `ai_contribution` field describing that contributor's individual involvement. At least **one** contributor per track MUST have `ai_contribution` != `"all"` — i.e. every track MUST credit at least one human contributor. Indexers and DSPs SHOULD reject a track whose contributors are all marked `"all"`.

| Value | Meaning |
| :--- | :--- |
| `none` | The contributor's work is fully human. |
| `partly` | The contributor used AI tools as part of their work. |
| `all` | The contributor's work is entirely AI-generated (e.g. a credited AI model). |

##### Contributors

Ordered array. Order = display sequence (maps to DDEX `SequenceNumber`).

```json
{
  "contributors": [
    { "name": "ledfut", "address": "0x1234...abcd", "roles": ["MainArtist", "Producer"], "ai_contribution": "none" },
    { "name": "ampy", "address": "0x5678...efgh", "roles": ["Composer", "Lyricist"], "ai_contribution": "partly" },
    { "name": "Big Boss", "roles": ["ExecutiveProducer"], "ai_contribution": "none" }
  ]
}
```

| Property | Type | Required |
| :--- | :---: | :---: |
| `name` | `string` | ✓ |
| `address` | `string` (UP address) |  |
| `email` | `string` |  |
| `roles` | `string[]` | ✓ |
| `ai_contribution` | `string` (`none` \| `partly` \| `all`) | ✓ (track level) |

Common roles (extensible):

| Role | DDEX Equivalent |
| :--- | :--- |
| `MainArtist` | `MainArtist` |
| `FeaturedArtist` | `FeaturedArtist` |
| `Producer` | `StudioProducer` |
| `ExecutiveProducer` | `ExecutiveProducer` |
| `Composer` | `Composer` |
| `Lyricist` | `Lyricist` |
| `MixingEngineer` | `MixingEngineer` |
| `MasteringEngineer` | `MasteringEngineer` |
| `Remixer` | `Remixer` |

##### Identifiers

```json
{
  "identifiers": {
    "isrc": "USABC2512345",
    "iswc": "T-123.456.789-0",
    "upc": "012345678905",
    "grid": "A12345A67890123456",
    "catalogueNumber": "TMPS005"
  }
}
```

| Property | Level | Description |
| :--- | :---: | :--- |
| `isrc` | Track | International Standard Recording Code |
| `iswc` | Both | International Standard Musical Work Code |
| `upc` | Release | Universal Product Code |
| `grid` | Release | Global Release Identifier |
| `catalogueNumber` | Both | Label catalogue number |

##### Copyright

```json
{
  "copyright": {
    "pLine": { "year": 2026, "text": "TMPS" },
    "cLine": { "year": 2026, "text": "TMPS" }
  }
}
```

`pLine` = sound recording copyright (℗). `cLine` = composition copyright (©).

##### Lyrics

```json
{
  "lyrics": {
    "text": "Verse 1:\nFeel the bass drop...",
    "language": "en",
    "synced": false
  }
}
```

##### Preview

```json
{ "preview": { "startMs": 30000, "durationMs": 30000 } }
```

Maps to DDEX ERN `<PreviewDetails>`.

##### Stems

Array of stem/multitrack files. Each follows LSP4's `assets` structure with an added `name`:

```json
{
  "stems": [
    {
      "name": "Vocals",
      "url": "ipfs://Qm.../vocals.wav",
      "fileType": "audio/wav",
      "verification": { "method": "keccak256(bytes)", "data": "0x..." }
    }
  ]
}
```

##### DDEX

Reference to a [DDEX ERN](https://ddex.net/standards/electronic-release-notification-message-suite/) XML file:

```json
{
  "ddex": {
    "url": "ipfs://Qm.../release-ern.xml",
    "version": "4.3.2",
    "verification": { "method": "keccak256(bytes)", "data": "0x..." }
  }
}
```

### Full Metadata Examples

A release with tracks naturally produces **four separate files** — one `LSP4Metadata` and one `LSP33Metadata` for the release, and one of each per track. A standalone LSP7 only needs the two track files. Files MAY be combined into fewer.

#### Release — `LSP4Metadata`

```json
{
  "LSP4Metadata": {
    "name": "ledfut - single 20031400",
    "description": "A 2-track house single by ledfut, released on TMPS.",
    "links": [
      { "title": "Artist Website", "url": "https://ledfut.xyz" },
      { "title": "Spotify", "url": "https://open.spotify.com/album/..." }
    ],
    "icon": [
      {
        "width": 256,
        "height": 256,
        "url": "ipfs://QmIcon256.../icon.png",
        "verification": { "method": "keccak256(bytes)", "data": "0xabcd..." }
      }
    ],
    "images": [
      [
        {
          "width": 1024,
          "height": 1024,
          "url": "ipfs://QmCover1024.../cover.jpg",
          "verification": { "method": "keccak256(bytes)", "data": "0x1234..." }
        }
      ]
    ],
    "assets": [],
    "attributes": [
      { "key": "Artist", "value": "ledfut", "type": "string" },
      { "key": "Release Type", "value": "Single", "type": "string" },
      { "key": "Release Date", "value": "2025-11-06", "type": "string" },
      { "key": "Primary Genre", "value": "House", "type": "string" },
      { "key": "Track Count", "value": "2", "type": "string" },
      { "key": "Label", "value": "TMPS", "type": "string" },
      { "key": "Language", "value": "eng", "type": "string" }
    ],
    "category": "Music"
  }
}
```

#### Release — `LSP33Metadata`

```json
{
  "LSP33Metadata": {
    "contributors": [
      { "name": "ledfut", "address": "0x1234...abcd", "roles": ["MainArtist", "Producer"], "ai_contribution": "none" },
      { "name": "Studio Wizard", "address": "0xabcd...1234", "roles": ["MasteringEngineer"], "ai_contribution": "none" }
    ],
    "identifiers": {
      "upc": "012345678905",
      "catalogueNumber": "TMPS005"
    },
    "copyright": {
      "pLine": { "year": 2025, "text": "TMPS" },
      "cLine": { "year": 2025, "text": "TMPS" }
    },
    "ddex": {
      "url": "ipfs://QmDdex.../release-ern.xml",
      "version": "4.3.2",
      "verification": { "method": "keccak256(bytes)", "data": "0x9abc..." }
    }
  }
}
```

#### Track — `LSP4Metadata`

```json
{
  "LSP4Metadata": {
    "name": "20031400",
    "description": "Track 1 from 'ledfut - single 20031400'. A driving house cut.",
    "links": [],
    "icon": [
      {
        "width": 256,
        "height": 256,
        "url": "ipfs://QmTrackIcon.../icon.png",
        "verification": { "method": "keccak256(bytes)", "data": "0xdef0..." }
      }
    ],
    "images": [
      [
        {
          "width": 1024,
          "height": 1024,
          "url": "ipfs://QmTrackCover.../cover.jpg",
          "verification": { "method": "keccak256(bytes)", "data": "0x2345..." }
        }
      ]
    ],
    "assets": [
      {
        "url": "ipfs://QmAudio.../20031400.flac",
        "fileType": "audio/flac",
        "verification": { "method": "keccak256(bytes)", "data": "0x6789..." }
      }
    ],
    "attributes": [
      { "key": "Artist", "value": "ledfut", "type": "string" },
      { "key": "Track Number", "value": "1", "type": "string" },
      { "key": "Primary Genre", "value": "House", "type": "string" },
      { "key": "Release Date", "value": "2025-11-06", "type": "string" },
      { "key": "Duration", "value": "5:22", "type": "string" },
      { "key": "BPM", "value": "128", "type": "string" },
      { "key": "Key", "value": "Am", "type": "string" },
      { "key": "Explicit Content", "value": "NotExplicit", "type": "string" }
    ],
    "category": "Music"
  }
}
```

#### Track — `LSP33Metadata`

```json
{
  "LSP33Metadata": {
    "contributors": [
      { "name": "ledfut", "address": "0x1234...abcd", "roles": ["MainArtist", "Producer", "Composer"], "ai_contribution": "none" },
      { "name": "ampy", "address": "0x5678...efgh", "roles": ["Lyricist"], "ai_contribution": "partly" },
      { "name": "Studio Wizard", "address": "0xabcd...1234", "roles": ["MixingEngineer", "MasteringEngineer"], "ai_contribution": "none" }
    ],
    "audio_ai_usage": "none",
    "composition_ai_usage": "some",
    "commercial_samples": "none",
    "identifiers": {
      "isrc": "USABC2512345",
      "iswc": "T-123.456.789-0",
      "catalogueNumber": "TMPS005-01"
    },
    "copyright": {
      "pLine": { "year": 2025, "text": "TMPS" },
      "cLine": { "year": 2025, "text": "TMPS" }
    },
    "lyrics": {
      "text": "Verse 1:\nFeel the bass drop low tonight\nMoving through the neon light\n\nChorus:\nWe don't stop, we don't stop...",
      "language": "en",
      "synced": false
    },
    "preview": {
      "startMs": 45000,
      "durationMs": 30000
    },
    "stems": [
      {
        "name": "Drums",
        "url": "ipfs://QmStems.../drums.wav",
        "fileType": "audio/wav",
        "verification": { "method": "keccak256(bytes)", "data": "0xaaaa..." }
      },
      {
        "name": "Bass",
        "url": "ipfs://QmStems.../bass.wav",
        "fileType": "audio/wav",
        "verification": { "method": "keccak256(bytes)", "data": "0xbbbb..." }
      },
      {
        "name": "Vocals",
        "url": "ipfs://QmStems.../vocals.wav",
        "fileType": "audio/wav",
        "verification": { "method": "keccak256(bytes)", "data": "0xcccc..." }
      }
    ],
    "ddex": {
      "url": "ipfs://QmDdex.../track1-ern.xml",
      "version": "4.3.2"
    }
  }
}
```

## Rationale

**Carrier-neutral.** LSP33 specifies *what* to store, not *where*. Any [ERC725Y] contract — token, profile, vault, or future contract type — can carry the schema by writing the data keys defined here. Tying the schema to a specific token type would force every new music-bearing contract to redefine it, fragmenting the ecosystem.

**Reuses existing primitives.** LSP33 builds on [LSP4] (so any LSP4-aware wallet or marketplace already understands the human-readable metadata) and on [LSP2]/[ERC725Y] (so the storage format is already standard). No new token contract is introduced.

**Separate metadata files.** `LSP4Metadata` and `LSP33Metadata` are separate data keys so any LSP4-aware interface works out of the box and each can evolve independently. They may still be combined into a single file when desired.

**Metadata only.** LSP33 deliberately does not specify linking, ownership, or minting mechanics. Those concerns are handled by [LSP35] (LSP8 ↔ LSP7 entanglement) and [LSP34] (minting rights delegation), keeping each standard focused and independently adoptable. The artist-vs-collector separation that motivates LSP33's existence is enforced by those companion standards on the carriers that opt into them.

## Implementation

Reference implementation: [lukso-network/lsp-smart-contracts#1088](https://github.com/lukso-network/lsp-smart-contracts/pull/1088).

ERC725Y JSON Schema `LSP33MusicNFT`:

```json
[
  {
    "name": "SupportedStandards:LSP33MusicNFT",
    "key": "0xeafec4d89fa9619884b60000f43ae543d533ae7389b5791d7870aadfdcff2ca4",
    "keyType": "Mapping",
    "valueType": "bytes4",
    "valueContent": "0x3cd46617"
  },
  {
    "name": "LSP33Metadata",
    "key": "0xbecee5b67fa43fb2e96c7c6ccdc23007fffc2b24205416b2122cd7b8d8ef48fa",
    "keyType": "Singleton",
    "valueType": "bytes",
    "valueContent": "VerifiableURI"
  }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC173]: https://eips.ethereum.org/EIPS/eip-173
[ERC725Y]: https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#erc725y
[LSP0]: ./LSP-0-ERC725Account.md
[LSP2]: ./LSP-2-ERC725YJSONSchema.md
[LSP3]: ./LSP-3-Profile-Metadata.md
[LSP4]: ./LSP-4-DigitalAsset-Metadata.md
[LSP7]: ./LSP-7-DigitalAsset.md
[LSP8]: ./LSP-8-IdentifiableDigitalAsset.md
[LSP9]: ./LSP-9-Vault.md
[LSP34]: ./LSP-34-ExternalOwnership.md
[LSP35]: ./LSP-35-IdentifiableDigitalAssetEntanglement.md
