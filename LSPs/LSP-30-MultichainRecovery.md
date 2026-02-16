---
lip: 30
title: Multichain Recovery
author: Fabian Vogelsteller <fabian@lukso.network>, Stephen Horvath (@asciiman)
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2026-02-16
requires: LSP0, LSP6, LSP23
---

## Table of Content

- [Simple Summary](#simple-summary)
- [Abstract](#abstract)
- [Motivation](#motivation)
- [Specification](#specification)
  - [Format Version](#format-version)
  - [Full Example](#full-example)
  - [Root Object](#root-object)
  - [Account Object](#account-object)
  - [Network Object](#network-object)
  - [Controller Object](#controller-object)
  - [LSP23 Cross-Chain Deployment Object](#lsp23-cross-chain-deployment-object)
  - [Initial Controller Object](#initial-controller-object)
  - [Secrets Object](#secrets-object)
    - [Unencrypted Secrets](#unencrypted-secrets)
    - [Encrypted Secrets](#encrypted-secrets)
  - [Encryption Specification](#encryption-specification)
- [Rationale](#rationale)
- [Security Considerations](#security-considerations)
- [Copyright](#copyright)

## Simple Summary

This standard defines a portable JSON format for exporting, backing up, and recovering [Universal Profiles](./LSP-0-ERC725Account.md) and their associated controller keys across multiple networks.

## Abstract

LSP-30 defines a standardized JSON export format that captures the full state needed to recover and restore a Universal Profile. This includes the profile's account metadata, per-network controller configurations, [LSP23](./LSP-23-LinkedContractsFactory.md) cross-chain deployment data for reproducing the profile on new chains, and secret material (private keys or seed phrases) in either plaintext or encrypted form.

By standardizing this format, LSP-30 enables interoperability between wallets, browser extensions, and recovery tools. Any compliant application can import a backup file produced by another, ensuring users are never locked into a single tool for managing their identity. The standard complements [LSP-11 Basic Social Recovery](./LSP-11-BasicSocialRecovery.md), which handles on-chain guardian-based recovery, by providing the off-chain data portability layer.

## Motivation

Key loss is the most significant risk in self-custodial smart contract accounts. While seed phrase backups work for simple EOAs, Universal Profiles introduce a fundamentally more complex account model:

- A single Universal Profile may have **multiple controller addresses**, each with different [LSP6 Key Manager](./LSP-6-KeyManager.md) permissions.
- Controllers can be of different types: device keys, application keys, Universal Receiver Delegate contracts, or even other Universal Profiles.
- The same profile may be deployed across **multiple networks**, each with its own set of controllers.
- Reproducing a profile on a new chain requires the original **LSP23 deployment calldata**, factory address, and initial controller configuration.

No existing standard addresses the problem of portably capturing all of this information in a single, interoperable file. Without such a standard:

- Users are locked into whichever wallet or extension they used to create the profile.
- Migrating between tools requires manual, error-prone re-entry of keys and configuration.
- Cross-chain deployment data is effectively lost once the original tool is no longer available.

LSP-30 solves this by defining a JSON format that any compliant tool can produce and consume. It separates public account data from secret material, supports both encrypted and unencrypted export modes, and includes all the data necessary for full profile recovery.

This standard is complementary to [LSP-11 Basic Social Recovery](./LSP-11-BasicSocialRecovery.md). While LSP-11 provides an on-chain mechanism for regaining access through guardian voting, LSP-30 provides the off-chain backup layer that preserves the data needed to restore a profile from a file.

## Specification

### Format Version

As of 16.02.2026, the current version number is **2**. Implementations MUST include a `version` field in the root object. Consumers SHOULD reject files with an unrecognized version number and MAY attempt to migrate files from earlier versions.

### Full Example

The backup file SHOULD have the following format:

```js
{
  "version": 2,
  "backupDate": "2024-12-01T12:01:00Z",
  "accounts": [
    {
      "type": "LSP0-ERC725Account",
      "name": "myusername",
      "address": "0xa8eF14533CcfD44b281B1FFD098B6CdfcA39a247",
      "networks": [
        {
          "chainID": 42,
          "name": "LUKSO Mainnet",
          "controllers": [
            {
              "address": "0x12388301Db0812d7302Ba4AA0F035865A8a7A987",
              "name": "My custom controller",
              "type": "Device", // Device / App / LSP0-ERC725Account / UniversalReceiver
              "privateKeyIndex": 0
            },
            {
              "address": "0xDDDD8301Db0812d7302Ba4AA0F035865A8a7A987",
              "name": "My Token Filter URD",
              "type": "UniversalReceiver",
              "seedIndex": 2,
              "derivationPath": "0/44/5445/5/4/5"
            },
            {
              "address": "0x555588301Db0812d7302Ba4AA0F035865A8a7A987"
              // No type or key info — e.g., a hardware wallet or third-party controller
            }
          ]
        },
        {
          "chainID": 1,
          "name": "Ethereum",
          "controllers": [
            {
              "address": "0xAABB8301Db0812d7302Ba4AA0F035865A8a7A987",
              "name": "My custom controller",
              "type": "Device",
              "privateKeyIndex": 1
            },
            {
              "address": "0xFFF88301Db0812d7302Ba4AA0F035865A8a7A987",
              "name": "My recovery ledger"
            }
          ]
        },
        {
          "chainID": 4800,
          "name": "My Custom Network",
          "controllers": [] // Profile exists on this network but no controllers are known
        }
      ]
    }
  ],
  "LSP23CrossChainDeployment": [
    {
      "profileAddress": "0xa8eF14533CcfD44b281B1FFD098B6CdfcA39a247",
      "initialChainID": 42,
      "factoryAddress": "0x2300000A84D25dF63081feAa37ba6b62C4c89a30",
      "deploymentCalldata": "0x6a66a75300000000...", // Full ABI-encoded calldata
      "salt": "0x65845cc4e77a4c76db68c2e9c5f1606e818cf077bfeedbb19c0d89d6a1c255f0", // OPTIONAL
      "initialControllers": [
        {
          "address": "0xAA118301Db0812d7302Ba4AA0F035865A8a7A987",
          "addressPermissions": {
            "permissions": "0x0000000000000000000000000000000000000000000000000000000000060080",
            "decodedPermissions": { // OPTIONAL convenience field
              "REENTRANCY": true,
              "SUPER_SETDATA": true,
              "SETDATA": true
            },
            "allowedCalls": "0x",
            "allowedERC725YDataKeys": "0x"
          }
        },
        {
          "address": "0xBB228301Db0812d7302Ba4AA0F035865A8a7A987",
          "privateKeyIndex": 0,
          "addressPermissions": {
            "permissions": "0x00000000000000000000000000000000000000000000000000000000007f3f06",
            "decodedPermissions": {
              "ADDCONTROLLER": true,
              "EDITPERMISSIONS": true,
              "SUPER_TRANSFERVALUE": true,
              "TRANSFERVALUE": true,
              "SUPER_CALL": true,
              "CALL": true,
              "SUPER_STATICCALL": true,
              "STATICCALL": true,
              "DEPLOY": true,
              "SUPER_SETDATA": true,
              "SETDATA": true,
              "ENCRYPT": true,
              "DECRYPT": true,
              "SIGN": true,
              "EXECUTE_RELAY_CALL": true
            },
            "allowedCalls": "0x",
            "allowedERC725YDataKeys": "0x"
          }
        }
      ]
    }
  ],

  // ---- Unencrypted variant ----
  "secrets": {
    "encrypted": false,
    "data": [
      {
        "type": "privateKey",
        "index": 0,
        "address": "0xBB228301Db0812d7302Ba4AA0F035865A8a7A987",
        "secret": "0x2345676543212345676543212345674234234234234..."
      },
      {
        "type": "seedPhrase",
        "index": 2,
        "secret": "lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor"
      }
    ]
  }

  // ---- OR Encrypted variant ----
  "secrets": {
    "encrypted": true,
    "encryptionType": "Key from PBKDF2. Encrypted with AES-GCM.",
    "passwordHint": "Your Hint", // OPTIONAL, user-entered during export
    "data": {
      "secret": "YFBVYcOGN0fsrFtqfxDW0nkEetgTtDpVgmr1baTeYo2ao9u2D8jw...", // Base64
      "iv": "Cr5VIn/RCfn0Q5AbVm8uZQ==", // Base64
      "salt": "G+00wPQI+3JayHcwmlq0LWTKSokipaUBJBhaslHSPjE=" // Base64
    }
  }
}
```

### Root Object

The top-level JSON object MUST contain the following fields:

| Field                       | Type     | Required | Description                                                                                          |
| --------------------------- | -------- | -------- | ---------------------------------------------------------------------------------------------------- |
| `version`                   | `uint`   | REQUIRED | Format version number. Currently `2`.                                                                |
| `backupDate`                | `string` | REQUIRED | ISO 8601 UTC timestamp of when the backup was created (e.g., `"2026-02-16T12:21:11Z"`).              |
| `accounts`                  | `array`  | REQUIRED | Array of [Account Objects](#account-object).                                                         |
| `LSP23CrossChainDeployment` | `array`  | REQUIRED | Array of [LSP23 Cross-Chain Deployment Objects](#lsp23-cross-chain-deployment-object). MAY be empty. |
| `secrets`                   | `object` | REQUIRED | A [Secrets Object](#secrets-object) containing key material, either encrypted or in plaintext.       |

**Example:**

```json
{
  "version": 2,
  "backupDate": "2026-02-16T12:21:11Z",
  "accounts": [ ... ],
  "LSP23CrossChainDeployment": [ ... ],
  "secrets": { ... }
}
```

### Account Object

Each entry in the `accounts` array represents a single Universal Profile. It MUST contain the following fields:

| Field      | Type     | Required | Description                                                                                                           |
| ---------- | -------- | -------- | --------------------------------------------------------------------------------------------------------------------- |
| `type`     | `string` | REQUIRED | The account type. MUST be `"LSP0-ERC725Account"`.                                                                     |
| `name`     | `string` | REQUIRED | The profile name or username associated with this account.                                                            |
| `address`  | `string` | REQUIRED | The checksummed Ethereum address of the Universal Profile contract ([EIP-55](https://eips.ethereum.org/EIPS/eip-55)). |
| `networks` | `array`  | REQUIRED | Array of [Network Objects](#network-object) describing the chains where this profile has controllers.                 |

**Example:**

```json
{
  "type": "LSP0-ERC725Account",
  "name": "The name used for the Universal Profile (LSP3-ProfileMetadata)",
  "address": "0x12345678901234567890...",
  "networks": [ ... ]
}
```

### Network Object

Each entry in the `networks` array describes the profile's controller configuration on a specific chain.

| Field         | Type     | Required | Description                                                                                                                                        |
| ------------- | -------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `chainID`     | `uint`   | REQUIRED | The [EIP-155](https://eips.ethereum.org/EIPS/eip-155) chain ID.                                                                                    |
| `name`        | `string` | REQUIRED | Human-readable network name (e.g., `"LUKSO Mainnet"`, `"Ethereum"`).                                                                               |
| `controllers` | `array`  | REQUIRED | Array of [Controller Objects](#controller-object). MAY be empty if the profile exists on this network but has no known controllers in this backup. |

**Example:**

```json
{
  "chainID": 42,
  "name": "LUKSO Mainnet",
  "controllers": [ ... ]
}
```

### Controller Object

Each entry in the `controllers` array describes a controller address associated with the profile on a given network. Only the `address` field is required; all other fields provide additional context for recovery tools.

| Field             | Type     | Required | Description                                                                                                                                                                                      |
| ----------------- | -------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `address`         | `string` | REQUIRED | The checksummed Ethereum address of the controller.                                                                                                                                              |
| `type`            | `string` | OPTIONAL | The controller type. One of: `"Device"`, `"App"`, `"UniversalReceiver"`, `"LSP0-ERC725Account"`.                                                                                                 |
| `name`            | `string` | OPTIONAL | A human-readable label for the controller (e.g., `"UP Browser Extension"`, `"Universal Receiver"`).                                                                                              |
| `privateKeyIndex` | `uint`   | OPTIONAL | References a secret entry in `secrets.data[]` where `type` is `"privateKey"` and the `index` field matches this value.                                                                           |
| `seedIndex`       | `uint`   | OPTIONAL | References a secret entry in `secrets.data[]` where `type` is `"seedPhrase"` and the `index` field matches this value.                                                                           |
| `derivationPath`  | `string` | OPTIONAL | The HD key derivation path used to derive this controller's key from the referenced seed phrase (e.g., `"m'/44'/60'/0'/0"` or `"0/44/5445/5/4/5"`). Only meaningful when `seedIndex` is present. |

A controller object MUST NOT contain both `privateKeyIndex` and `seedIndex`. If neither is present, the controller's key material is not included in this backup (e.g., a hardware wallet key or a third-party controller).

**Controller types:**

- `"Device"` -- A key controlled by a device such as a browser extension, mobile app, or hardware wallet.
- `"App"` -- A key managed by an application or service.
- `"UniversalReceiver"` -- A [Universal Receiver Delegate](./LSP-1-UniversalReceiver.md) contract address.
- `"LSP0-ERC725Account"` -- Another Universal Profile acting as a controller.

**Example (device controller with private key reference):**

```json
{
  "address": "0x12345678901234567890...",
  "type": "Device",
  "privateKeyIndex": 0,
  "name": "UP Browser Extension"
}
```

**Example (Universal Receiver controller without key material):**

```json
{
  "address": "0x12345678901234567890...",
  "type": "UniversalReceiver",
  "name": "Universal Receiver"
}
```

**Example (seed-derived controller):**

```json
{
  "address": "0x12345678901234567890...",
  "type": "Device",
  "name": "My Token Filter URD",
  "seedIndex": 2,
  "derivationPath": "0/44/5445/5/4/5"
}
```

### LSP23 Cross-Chain Deployment Object

Each entry in the `LSP23CrossChainDeployment` array contains the data necessary to reproduce a Universal Profile deployment on a new chain using the [LSP23 Linked Contracts Factory](./LSP-23-LinkedContractsFactory.md).

| Field                | Type     | Required | Description                                                                                                                                                                        |
| -------------------- | -------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `profileAddress`     | `string` | REQUIRED | The checksummed address of the Universal Profile.                                                                                                                                  |
| `initialChainID`     | `uint`   | REQUIRED | The chain ID where the profile was originally deployed.                                                                                                                            |
| `factoryAddress`     | `string` | REQUIRED | The checksummed address of the [LSP23](./LSP-23-LinkedContractsFactory.md) factory contract used for deployment.                                                                   |
| `deploymentCalldata` | `string` | REQUIRED | The full ABI-encoded calldata (hex-encoded with `0x` prefix) used to deploy the profile through the factory. This is the data needed to reproduce the deployment on another chain. |
| `salt`               | `string` | OPTIONAL | The `bytes32` salt value (hex-encoded with `0x` prefix) used during the CREATE2 deployment.                                                                                        |
| `initialControllers` | `array`  | REQUIRED | Array of [Initial Controller Objects](#initial-controller-object) describing each controller's permissions at deployment time.                                                     |

**Example:**

```json
{
  "profileAddress": "0x12345678901234567890...",
  "initialChainID": 42,
  "factoryAddress": "0x2300000A84D25dF63081...",
  "deploymentCalldata": "0x6a66a753...",
  "initialControllers": [ ... ]
}
```

### Initial Controller Object

Each entry in the `initialControllers` array within an LSP23 Cross-Chain Deployment Object captures a controller's full permission state at deployment time. This data is essential for reproducing the same permission structure when deploying to a new chain.

| Field                | Type     | Required | Description                                                                                                            |
| -------------------- | -------- | -------- | ---------------------------------------------------------------------------------------------------------------------- |
| `address`            | `string` | REQUIRED | The checksummed address of the controller.                                                                             |
| `privateKeyIndex`    | `uint`   | OPTIONAL | References a secret entry in `secrets.data[]` where `type` is `"privateKey"` and the `index` field matches this value. |
| `addressPermissions` | `object` | REQUIRED | The [LSP6 Key Manager](./LSP-6-KeyManager.md) permission set for this controller. See below.                           |

**`addressPermissions` object:**

| Field                    | Type     | Required | Description                                                                                                                                                                                                          |
| ------------------------ | -------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `permissions`            | `string` | REQUIRED | The raw `bytes32` permissions value (hex-encoded with `0x` prefix), as stored under the `AddressPermissions:Permissions:<address>` [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data key. |
| `decodedPermissions`     | `object` | OPTIONAL | A convenience object mapping human-readable permission names to boolean values. This field is informational and MUST be consistent with the `permissions` bitfield when present.                                     |
| `allowedCalls`           | `string` | REQUIRED | The hex-encoded allowed calls value, as stored under the `AddressPermissions:AllowedCalls:<address>` data key. Use `"0x"` for unrestricted.                                                                          |
| `allowedERC725YDataKeys` | `string` | REQUIRED | The hex-encoded allowed ERC725Y data keys value, as stored under the `AddressPermissions:AllowedERC725YDataKeys:<address>` data key. Use `"0x"` for unrestricted.                                                    |

**Example:**

```json
{
  "address": "0x12345678901234567890...",
  "privateKeyIndex": 0,
  "addressPermissions": {
    "permissions": "0x00000000000000000000000000000000000000000000000000000000007f3f06",
    "decodedPermissions": {
      "ADDCONTROLLER": true,
      "EDITPERMISSIONS": true,
      "SUPER_TRANSFERVALUE": true,
      "TRANSFERVALUE": true,
      "SUPER_CALL": true,
      "CALL": true,
      "SUPER_STATICCALL": true,
      "STATICCALL": true,
      "DEPLOY": true,
      "SUPER_SETDATA": true,
      "SETDATA": true,
      "ENCRYPT": true,
      "DECRYPT": true,
      "SIGN": true,
      "EXECUTE_RELAY_CALL": true
    },
    "allowedCalls": "0x",
    "allowedERC725YDataKeys": "0x"
  }
}
```

### Secrets Object

The `secrets` field in the root object contains the private key material needed to control the profile. It supports two modes: **unencrypted** (plaintext) and **encrypted**.

The mode is determined by the `encrypted` boolean field.

#### Unencrypted Secrets

When `encrypted` is `false`, the `data` field is an array of secret entries in plaintext.

| Field       | Type      | Required | Description                    |
| ----------- | --------- | -------- | ------------------------------ |
| `encrypted` | `boolean` | REQUIRED | MUST be `false`.               |
| `data`      | `array`   | REQUIRED | Array of secret entry objects. |

**Secret entry fields:**

| Field     | Type     | Required | Description                                                                                                                              |
| --------- | -------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `type`    | `string` | REQUIRED | The type of secret. One of: `"privateKey"`, `"seedPhrase"`.                                                                              |
| `index`   | `uint`   | REQUIRED | A unique index used to reference this secret from controller objects via `privateKeyIndex` or `seedIndex`.                               |
| `address` | `string` | OPTIONAL | The checksummed Ethereum address derived from this secret. Applicable when `type` is `"privateKey"`.                                     |
| `secret`  | `string` | REQUIRED | The secret value. For `"privateKey"`: a hex-encoded private key with `0x` prefix. For `"seedPhrase"`: a space-separated mnemonic phrase. |

**Example:**

```json
{
  "encrypted": false,
  "data": [
    {
      "type": "privateKey",
      "index": 0,
      "address": "0x12345678901234567890...",
      "secret": "0x..." // Private Key for this EOA address above
    },
    {
      "type": "seedPhrase",
      "index": 1,
      "secret": "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12"
    }
  ]
}
```

#### Encrypted Secrets

When `encrypted` is `true`, the `data` field is an object containing the encrypted ciphertext and the cryptographic parameters needed for decryption. The plaintext, once decrypted, MUST be a valid JSON array of secret entries as defined in [Unencrypted Secrets](#unencrypted-secrets).

| Field            | Type      | Required | Description                                                                                                      |
| ---------------- | --------- | -------- | ---------------------------------------------------------------------------------------------------------------- |
| `encrypted`      | `boolean` | REQUIRED | MUST be `true`.                                                                                                  |
| `encryptionType` | `string`  | REQUIRED | A human-readable description of the encryption method used (e.g., `"Key from PBKDF2. Encrypted with AES-GCM."`). |
| `passwordHint`   | `string`  | OPTIONAL | A hint to help the user recall the encryption password. MUST NOT contain the actual password.                    |
| `data`           | `object`  | REQUIRED | The encrypted data envelope. See below.                                                                          |

**Encrypted `data` object fields:**

| Field    | Type     | Required | Description                                                                                    |
| -------- | -------- | -------- | ---------------------------------------------------------------------------------------------- |
| `secret` | `string` | REQUIRED | The Base64-encoded ciphertext. When decrypted, this produces the JSON array of secret entries. |
| `iv`     | `string` | REQUIRED | The Base64-encoded initialization vector used for AES-GCM encryption.                          |
| `salt`   | `string` | REQUIRED | The Base64-encoded salt used for PBKDF2 key derivation.                                        |

**Example:**

```json
{
  "encrypted": true,
  "encryptionType": "Key from PBKDF2. Encrypted with AES-GCM.",
  "passwordHint": "Your Hint", // User entered password during export process
  "data": {
    "secret": "Pah+MuluO/1DpDKLlnybfk...",
    "iv": "uupRYBHpJ8BUZgo8dGsexg==",
    "salt": "pXBdzrwQXcmkYoaFPWWqVs2GRYeQO28gVmgGNqdgeyE="
  }
}
```

### Encryption Specification

Implementations that produce encrypted backups MUST use the following scheme:

1. **Key Derivation**: Derive an encryption key from the user's password using [PBKDF2](https://datatracker.ietf.org/doc/html/rfc2898).
2. **Encryption**: Encrypt the JSON-serialized secret entries array using [AES-GCM](https://csrc.nist.gov/publications/detail/sp/800-38d/final).
3. **Encoding**: Encode the resulting ciphertext, initialization vector, and salt as Base64 strings.

Implementations SHOULD use a sufficient PBKDF2 iteration count (at least 600,000 iterations as recommended by [OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)) and a randomly generated salt of at least 32 bytes.

The `encryptionType` field MUST accurately describe the key derivation and encryption algorithms used, to allow consuming tools to select the correct decryption procedure. The current standard value is:

```text
"Key from PBKDF2. Encrypted with AES-GCM."
```

## Rationale

### JSON format

JSON was chosen as the export format because it is human-readable, universally supported across programming languages and platforms, and does not require specialized parsers. This maximizes the likelihood that a backup file can be read and processed even if the original exporting tool is no longer available.

### Version field

The `version` field allows the format to evolve over time without breaking existing consumers. Tools SHOULD check the version before attempting to parse the file and provide clear error messages for unsupported versions.

### LSP23 cross-chain deployment data

Including the full LSP23 deployment calldata and initial controller permissions enables deterministic reproduction of a Universal Profile on any EVM-compatible chain. Without this data, deploying the same profile address on a new chain would be impossible, as the CREATE2 address depends on the exact deployment parameters.

### Relationship to LSP-11

[LSP-11 Basic Social Recovery](./LSP-11-BasicSocialRecovery.md) provides an on-chain recovery mechanism where guardians vote to grant a new controller address access to the profile. LSP-30 is complementary: it provides off-chain backup and portability. A user might use LSP-30 to back up their profile to a file, and LSP-11 to recover access if all controller keys are lost. The two standards address different failure modes and can be used together for comprehensive recovery coverage.

### Controller type vocabulary

The controller `type` field uses a fixed vocabulary (`"Device"`, `"App"`, `"UniversalReceiver"`, `"LSP0-ERC725Account"`) rather than free-form strings. This enables consuming tools to categorize controllers consistently and present appropriate UI (e.g., showing a key icon for device controllers and a contract icon for Universal Receiver delegates).

## Security Considerations

### Unencrypted backups

An unencrypted backup file contains raw private keys and/or seed phrases in plaintext. Anyone who obtains this file gains full control over the associated controllers. Unencrypted backups SHOULD only be used in secure, controlled environments (e.g., for developer tooling or immediate import into another tool) and MUST be deleted after use.

### Encrypted backups

Encrypted backups protect secret material with a user-chosen password. The security of the backup is directly tied to the strength of this password. Implementations SHOULD enforce minimum password complexity requirements and use a high PBKDF2 iteration count to resist brute-force attacks.

### Password hints

The optional `passwordHint` field is stored in plaintext alongside the encrypted data. Users MUST be warned that the hint is visible to anyone who has the file. Hints SHOULD be vague enough to jog the owner's memory without revealing the password to others.

### Storage recommendations

Backup files -- whether encrypted or not -- SHOULD be stored in secure locations such as:

- Encrypted storage devices (USB drives with hardware encryption)
- Password managers
- Offline/air-gapped storage

Backup files SHOULD NOT be stored in plaintext on cloud services, email, or other locations accessible to third parties.

### Checksummed addresses

All Ethereum addresses in the backup MUST use [EIP-55](https://eips.ethereum.org/EIPS/eip-55) mixed-case checksum encoding. Consuming tools SHOULD validate checksums on import and warn the user if any address fails validation.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
