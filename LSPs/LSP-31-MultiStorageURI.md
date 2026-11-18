---
lip: 31
title: Multi-Storage URI
author: b00ste
discussions-to:
status: Draft
type: LSP
created: 2025-02-24
requires: LSP2
---

## Simple Summary

A value type for encoding references to content stored across multiple storage backends with verification metadata, extending the [VerifiableURI] concept from [LSP2].

## Abstract

LSP31 defines a **MultiStorageURI** value type for [ERC725Y] smart contracts. While [LSP2] [VerifiableURI] points to a single URL, MultiStorageURI points to the same content replicated across multiple storage backends, each identified by backend-specific fields. A single verification hash confirms that all backends store identical content bytes.

## Specification

### MultiStorageURI

A MultiStorageURI consists of bytes sliced into the same header structure as [VerifiableURI], followed by a JSON-encoded entries array instead of a single URL:

```
0x0031           00000000       0000          0000...0000          0000...

^                ^              ^             ^                    ^
MultiStorageURI  Verification   Verification  Verification         Encoded entries
identifier       method         data length   data                 (JSON array)
```

- **MultiStorageURI identifier**: MUST be `bytes2(0x0031)`: `0031`

- **Verification method**: Same as [VerifiableURI]. The first 4 bytes of the hash of the method name: `bytes4(keccak256('methodName'))`.

- **Verification data length**: Length of the verification data in bytes, encoded as `bytes2`.

- **Verification data**: Hash of the content bytes. All backends MUST store identical content, so a single hash covers all entries.

- **Encoded entries**: A UTF-8 encoded JSON array of storage entry objects.

#### Detecting MultiStorageURI vs VerifiableURI

Applications can distinguish MultiStorageURI from [VerifiableURI] by examining the first 2 bytes:

- `0x0000` → [VerifiableURI] (single URL)
- `0x0031` → MultiStorageURI (multiple backend entries)

#### Entries JSON Schema

Each entry in the JSON array describes a storage backend. The `backend` field is the discriminant:

```json
[
  { "backend": "ipfs", "cid": "<string>" },
  { "backend": "s3", "bucket": "<string>", "key": "<string>", "region": "<string>" },
  { "backend": "lumera", "actionId": "<string>" },
  { "backend": "arweave", "transactionId": "<string>" }
]
```

| Backend   | Required Fields           | Description                              |
| --------- | ------------------------- | ---------------------------------------- |
| `ipfs`    | `cid`                     | IPFS content identifier (CIDv0 or CIDv1) |
| `s3`      | `bucket`, `key`, `region` | AWS S3 object location                   |
| `lumera`  | `actionId`                | Lumera/Pastel Cascade action ID          |
| `arweave` | `transactionId`           | Arweave transaction ID                   |

#### Constraints

- The entries array MUST contain **at least 2 entries**. Single-backend content SHOULD use [VerifiableURI] instead.
- The `backend` field is the **discriminant** — each entry MUST have exactly one backend type with its corresponding required fields.
- All backends MUST store **identical content bytes** — the single verification hash covers all entries.

#### Example

The following shows how to encode a MultiStorageURI using the `keccak256(bytes)` verification method:

```ts
import { concat, keccak256, numberToHex, stringToHex, toHex } from 'viem';

const verificationMethod = keccak256(toHex('keccak256(bytes)')).slice(0, 10) as `0x${string}`;
// '0x8019f9b1'

const hash = keccak256(contentBytes);
// '0xd47cf10786205bb08ce508e91c424d413d0f6c48e24dbfde2920d16a9561a723'

const verificationDataLength = numberToHex(32, { size: 2 });
// '0x0020'

const entries = JSON.stringify([
  { backend: 'ipfs', cid: 'QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG' },
  { backend: 'arweave', transactionId: 'bNbA3TEQVL60xlgCcqdz4ZPHFZ711cZ3hmkpGttDt_U' },
]);

// final result (to be stored on chain)
const multiStorageURI = concat([
  '0x0031', // MultiStorageURI identifier
  verificationMethod, // first 4 bytes of keccak256('keccak256(bytes)')
  verificationDataLength, // 2 bytes: length of verification data
  hash, // 32 bytes: keccak256 of content
  stringToHex(entries), // UTF-8 encoded JSON entries
]);
```

To decode, reverse the process:

```ts
import { hexToNumber, hexToString, slice } from 'viem'

const data = /* value read from ERC725Y getData() */

const identifier = slice(data, 0, 2)          // 0x0031
const verificationMethod = slice(data, 2, 6)  // 4 bytes
const verificationDataLength = hexToNumber(slice(data, 6, 8)) // 2 bytes → number
const verificationData = slice(data, 8, 8 + verificationDataLength)
const entries = JSON.parse(hexToString(slice(data, 8 + verificationDataLength)))
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC725Y]: https://github.com/ethereum/ercs/blob/master/ERCS/erc-725.md#erc725y
[LSP2]: https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md
[VerifiableURI]: https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md#verifiableuri
[CC0]: https://creativecommons.org/publicdomain/zero/1.0/
