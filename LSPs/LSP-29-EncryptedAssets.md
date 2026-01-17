---
lip: 29
title: Encrypted Assets
author: b00ste
discussions-to:
status: Draft
type: LSP
created: 2025-01-08
requires: ERC725Y, LSP2
---

## Simple Summary

A standard for storing encrypted digital assets in [ERC725Y] smart contracts, enabling creators to manage token-gated content directly on their Universal Profile.

## Abstract

This standard defines a set of [ERC725Y] data keys for storing references to encrypted digital assets. The encrypted content is stored on IPFS, while metadata and access control information are encoded as [VerifiableURI] values in the Universal Profile's storage. The standard supports versioning, allowing creators to update content while preserving full revision history. Each asset can include social feed images for content preview and discovery.

## Motivation

LUKSO currently has no standard for storing encrypted, token-gated digital assets. While LSP4 defines metadata for digital assets (LSP7/LSP8 tokens), it only supports unencrypted content. Creators who want to offer exclusive, encrypted content to token holders have no standardized way to:

1. **Store Encrypted Content**: No defined schema for encrypted asset metadata
2. **Link to Creator**: No way to associate encrypted content with a Universal Profile
3. **Track Versions**: No mechanism for updating content while preserving history
4. **Enable Discovery**: No standard for enumerating a creator's encrypted offerings

LSP29 introduces a complete solution by:

1. **Defining a Schema**: Standardized JSON format for encrypted asset metadata
2. **Centralizing on Profile**: All encrypted assets stored on the creator's Universal Profile
3. **Supporting Versioning**: Append-only array with revision tracking preserves full history
4. **Enabling Discovery**: Easy enumeration via array iteration and mapping lookups
5. **Flexible Access Control**: Each asset can reference different token gates for decryption
6. **Social Feed Integration**: Images for content preview and social discovery

## Specification

### ERC725Y Data Keys

#### LSP29EncryptedAssets[]

An [LSP2 Array] of [VerifiableURI] values, each pointing to an encrypted asset's JSON metadata on IPFS.

```json
{
  "name": "LSP29EncryptedAssets[]",
  "key": "0x1965f98377ddff08e78c93d820cc8de4eeb331e684b7724bce0debb1958386c3",
  "keyType": "Array",
  "valueType": "bytes",
  "valueContent": "VerifiableURI"
}
```

For more information about how to access each index of the `LSP29EncryptedAssets[]` array, see [LSP2 Array].

#### LSP29EncryptedAssetsMap

An [LSP2 Mapping] from a content identifier hash to the array index. This mapping supports two usage patterns:

1. **Latest version**: Hash of content ID only → points to the most recent revision
2. **Specific version**: Hash of content ID + revision → points to that exact revision

```json
{
  "name": "LSP29EncryptedAssetsMap:<bytes20>",
  "key": "0x2b9a7a38a67cedc507c20000<bytes20>",
  "keyType": "Mapping",
  "valueType": "uint128",
  "valueContent": "Number"
}
```

**For latest version**: `<bytes20>` is the first 20 bytes of `keccak256(contentId)`, where `contentId` is the string identifier chosen by the creator. This entry is updated each time a new revision is added.

**For specific version**: `<bytes20>` is the first 20 bytes of `keccak256(abi.encodePacked(contentId, uint32(revision)))`. This entry is immutable once set.

**Examples** for content ID `"premium-content"`:

| Lookup Type | Hash Input                                                  | Key                                 |
| ----------- | ----------------------------------------------------------- | ----------------------------------- |
| Latest      | `keccak256("premium-content")`                              | `0x2b9a7a38a67cedc507c200008a5b...` |
| Revision 1  | `keccak256(abi.encodePacked("premium-content", uint32(1)))` | `0x2b9a7a38a67cedc507c2000012ab...` |
| Revision 2  | `keccak256(abi.encodePacked("premium-content", uint32(2)))` | `0x2b9a7a38a67cedc507c200003c7f...` |

#### LSP29EncryptedAssetRevisionCount

An [LSP2 Mapping] from a content identifier hash to the total number of revisions for that content.

```json
{
  "name": "LSP29EncryptedAssetRevisionCount:<bytes32>",
  "key": "0xb41f63e335c22bded8140000<bytes20>",
  "keyType": "Mapping",
  "valueType": "uint128",
  "valueContent": "Number"
}
```

Where `<bytes20>` is the first 20 bytes of `keccak256(contentId)`.

### JSON Schema

The [VerifiableURI] stored in the array MUST point to a JSON file on IPFS conforming to the following schema:

```json
{
  "LSP29EncryptedAsset": {
    "version": "1.0.0",
    "id": "<string>",
    "title": "<string>",
    "description": "<string>",
    "images": "[[<image>, ...], ...]",
    "revision": "<number>",
    "createdAt": "<string>",
    "file": {
      "type": "<string>",
      "name": "<string>",
      "size": "<number>",
      "lastModified": "<number>",
      "hash": "<string>"
    },
    "encryption": {
      "method": "<string>",
      "ciphertext": "<string>",
      "dataToEncryptHash": "<string>",
      "accessControlConditions": "<array>",
      "decryptionCode": "<string>",
      "decryptionParams": "<object>"
    },
    "chunks": {
      "cids": "[<string>, ...]",
      "iv": "<string>",
      "totalSize": "<number>"
    }
  }
}
```

#### LSP29EncryptedAsset

| Key           | Type   | Required | Description                                               |
| ------------- | ------ | -------- | --------------------------------------------------------- |
| `version`     | string | Yes      | Schema version (e.g., `"1.0.0"`)                          |
| `id`          | string | Yes      | Unique content identifier chosen by creator               |
| `title`       | string | Yes      | Human-readable title for the content                      |
| `description` | string | No       | Human-readable description of the content                 |
| `images`      | array  | No       | Social feed images for content preview                    |
| `revision`    | number | Yes      | Version number starting at 1, incremented for each update |
| `createdAt`   | string | Yes      | ISO 8601 timestamp when this revision was created         |
| `file`        | object | Yes      | Technical metadata about the encrypted file               |
| `encryption`  | object | Yes      | Encryption metadata for decryption                        |
| `chunks`      | object | Yes      | Chunked storage information                               |

#### file

| Key            | Type   | Required | Description                                          |
| -------------- | ------ | -------- | ---------------------------------------------------- |
| `type`         | string | Yes      | MIME type of the original file (e.g., `"video/mp4"`) |
| `name`         | string | Yes      | Original filename                                    |
| `size`         | number | Yes      | Original file size in bytes (before encryption)      |
| `lastModified` | number | No       | Unix timestamp (ms) of file's last modification      |
| `hash`         | string | Yes      | Hash of the original file content (SHA-256, hex)     |

#### images

An array of image arrays for social feed functionality. Each inner array contains different sizes of the same image, following the LSP4Metadata images structure. The first image in the first inner array should be used as the main preview image.

**Structure:**

```json
"images": [
  [
    {
      "width": "number",
      "height": "number",
      "url": "string",
      "verification": {
        "method": "keccak256(bytes)",
        "data": "string"
      }
    },
    {
      "width": "number",
      "height": "number",
      "url": "string",
      "verification": {
        "method": "ecdsa",
        "data": "string",
        "source": "string"
      }
    }
  ],
  [
    // Additional image sets
  ]
]
```

| Key            | Type   | Required | Description                                         |
| -------------- | ------ | -------- | --------------------------------------------------- |
| `width`        | number | Yes      | Image width in pixels                               |
| `height`       | number | Yes      | Image height in pixels                              |
| `url`          | string | Yes      | URL to the image file                               |
| `verification` | object | Yes      | Verification data for image authenticity            |
| `method`       | string | Yes      | Verification method (`keccak256(bytes)` or `ecdsa`) |
| `data`         | string | Yes      | Hash or signature for verification                  |
| `source`       | string | No       | URL for signature verification (ecdsa method only)  |

#### encryption

| Key                       | Type   | Required | Description                                                |
| ------------------------- | ------ | -------- | ---------------------------------------------------------- |
| `method`                  | string | Yes      | Encryption method identifier (see supported methods below) |
| `ciphertext`              | string | Yes      | Encrypted symmetric key                                    |
| `dataToEncryptHash`       | string | Yes      | Hash of the encrypted data for verification                |
| `accessControlConditions` | array  | Yes      | Conditions for decryption access                           |
| `decryptionCode`          | string | Yes      | Code or reference for decryption logic                     |
| `decryptionParams`        | object | Yes      | Dynamic parameters embedded in `decryptionCode`            |

The `decryptionParams` object contains the dynamic values that are hardcoded into the `decryptionCode`. This enables UI display and content filtering without parsing the decryption code. See [Decryption Parameters Security](#decryption-parameters-security) for important security considerations.

**Supported Encryption Methods:**

| Method                         | Description                            | Example `decryptionParams`                                                             |
| ------------------------------ | -------------------------------------- | -------------------------------------------------------------------------------------- |
| `lit-digital-asset-balance-v1` | Digital asset balance via Lit Protocol | `{ "tokenAddress": "0x...", "requiredBalance": "1000000" }`                            |
| `lit-lsp8-ownership-v1`        | LSP8 NFT ownership via Lit Protocol    | `{ "tokenAddress": "0x...", "requiredTokenId": "42" }`                                 |
| `lit-lsp26-follower-v1`        | LSP26 on-chain follower check          | `{ "followedAddresses": ["0x...", "0x..."] }`                                          |
| `lit-social-followers-v1`      | Off-chain social verification          | `{ "platform": "twitter", "creatorHandle": "@creator", "requiredFollowers": "10000" }` |
| `lit-time-locked-v1`           | Time-lock via Lit Protocol             | `{ "unlockTimestamp": "1735689600" }`                                                  |

#### chunks

| Key         | Type   | Required | Description                                             |
| ----------- | ------ | -------- | ------------------------------------------------------- |
| `cids`      | array  | Yes      | Array of IPFS CIDs for encrypted content chunks         |
| `iv`        | string | Yes      | Initialization vector for symmetric encryption (base64) |
| `totalSize` | number | Yes      | Total size of encrypted content in bytes                |

### Data Flow

#### Creating New Content

1. Creator chooses a unique `id` (e.g., `"exclusive-album-2025"`)
2. Set `revision` to `1`
3. Set `createdAt` to current ISO 8601 timestamp
4. Encrypt content and upload chunks to IPFS
5. Create JSON metadata and upload to IPFS
6. Encode as [VerifiableURI]
7. Write to ERC725Y storage:
   - Append to `LSP29EncryptedAssets[]` array
   - Set `LSP29EncryptedAssetsMap:<keccak256(id)>` to new array index (latest)
   - Set `LSP29EncryptedAssetsMap:<keccak256(id + revision)>` to new array index (version 1)
   - Set `LSP29EncryptedAssetRevisionCount:<id>` to `1`

#### Updating Content (New Revision)

1. Use the same `id` as the original content
2. Read `LSP29EncryptedAssetRevisionCount:<id>` to get current revision count
3. Set `revision` to `currentCount + 1`
4. Set `createdAt` to current ISO 8601 timestamp
5. Encrypt new content and upload chunks to IPFS
6. Create JSON metadata and upload to IPFS
7. Encode as [VerifiableURI]
8. Write to ERC725Y storage:
   - Append to `LSP29EncryptedAssets[]` array
   - Update `LSP29EncryptedAssetsMap:<keccak256(id)>` to new array index (latest)
   - Set `LSP29EncryptedAssetsMap:<keccak256(id + revision)>` to new array index (this version)
   - Increment `LSP29EncryptedAssetRevisionCount:<id>`

#### Reading Latest Version

1. Compute key: `LSP29EncryptedAssetsMap:<keccak256(id)>`
2. Read array index from mapping
3. Read [VerifiableURI] from `LSP29EncryptedAssets[index]`
4. Fetch and verify JSON from IPFS

#### Reading Specific Version

1. Compute key: `LSP29EncryptedAssetsMap:<keccak256(abi.encodePacked(id, uint32(revision)))>`
2. Read array index from mapping
3. Read [VerifiableURI] from `LSP29EncryptedAssets[index]`
4. Fetch and verify JSON from IPFS

#### Enumerating All Versions

1. Read `LSP29EncryptedAssetRevisionCount:<id>` to get total count
2. For each revision 1 to count:
   - Compute key: `LSP29EncryptedAssetsMap:<keccak256(abi.encodePacked(id, uint32(revision)))>`
   - Read array index and fetch corresponding element

## Rationale

### Append-Only Array

The array is designed to be append-only to ensure:

- **Immutability**: Once content is published, it cannot be removed or altered
- **Audit Trail**: Full history of all content versions is preserved
- **Verifiability**: Third parties can verify the complete history

### Single Mapping with Dual Purpose

A single mapping (`LSP29EncryptedAssetsMap`) serves both use cases through different hash inputs:

- **Latest version**: Hash of content ID only → always points to most recent revision (updated on each new version)
- **Specific version**: Hash of content ID + revision → immutable pointer to that exact revision

This design reduces the number of data keys while maintaining O(1) lookup for both patterns.

### Content ID Design

Content IDs are creator-chosen strings rather than hashes because:

- **Human Readable**: IDs like `"premium-album-2025"` are meaningful
- **Stable**: Same ID persists across revisions
- **Flexible**: Creators control their namespace

### Revision Count

A separate revision count mapping enables:

- **Enumeration**: List all versions without iterating entire array
- **Validation**: Verify expected revision number before write
- **Efficiency**: O(1) lookup of version count

## Security Considerations

### Content Immutability

While the array is append-only at the application level, ERC725Y storage can technically be overwritten by the Universal Profile owner. Consumers should:

- Verify content hashes match [VerifiableURI] declarations
- Consider timestamps when multiple versions exist
- Be aware that "latest" mapping can be updated

### Decryption Parameters Security

The `decryptionParams` field exists for UI/querying purposes and MUST match the hardcoded values in `decryptionCode`. Applications SHOULD:

- Verify `decryptionParams` values match those embedded in `decryptionCode` when possible
- Display warnings to users if discrepancies are detected
- Never rely solely on `decryptionParams` for access control enforcement
- Treat `decryptionCode` as the authoritative source of truth

Actual access control MUST be enforced by the decryption mechanism (e.g., Lit Protocol access control conditions embedded in `decryptionCode`). Applications MUST NOT rely solely on the JSON `decryptionParams` field for security.

### Method Versioning

The `method` field includes a version suffix (e.g., `lit-lsp7-balance-v1`). When creating new encryption methods:

- Use unique, descriptive method identifiers
- Include version suffix for future compatibility (e.g., `-v1`, `-v2`)
- Document required `decryptionParams` schema for each method
- Maintain backward compatibility when incrementing versions

### Content ID Collisions

Content IDs are user-chosen strings. Applications SHOULD:

- Validate uniqueness before creating new content with an ID that may already exist
- Check `LSP29EncryptedAssetRevisionCount:<id>` to detect existing content
- Handle collisions gracefully (e.g., append suffix or reject)

### IPFS Persistence

Content stored on IPFS requires pinning for persistence. Applications SHOULD:

- Use pinning services for long-term storage
- Provide mechanisms for creators to ensure content availability
- Handle cases where IPFS content may become unavailable

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC725Y]: https://github.com/ethereum/ercs/blob/master/ERCS/erc-725.md#erc725y
[LSP2 Array]: https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md#array
[LSP2 Mapping]: https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md#mapping
[VerifiableURI]: https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md#verifiableuri
