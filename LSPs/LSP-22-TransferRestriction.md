---
lip: 22
title: Transfer Restriction
author: Felix Hildebrandt <@fhildeb>
discussions-to: https://discord.gg/lukso
status: Draft
type: LSP
created: 2022-03-22
requires: EIP-165, EIP-712, LSP4, LSP5, LSP6
---

## Simple Summary

This standard describes an interface to restrict transferability for digital assets.

> The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

## Abstract

The Transfer Restriction standard provides a generic [EIP-165] interface to control the transferability of digital assets. Its mechanisms can be used to disable, limit, or conditionally permit the transfer of assets from [LSP5]-based smart contracts, fostering the broad realm of an account or asset-based economy. The standard houses information about the restriction type, allowed transfer and removal rights, and the current lock status. Consent for restrictive transactions MUST be provided using [EIP-712] hashed content signatures of the asset's [LSP4] metadata, permissions, and types. [LSP6] is added to verify signature permissions across smart contract accounts.

## Motivation

The development of restrictive tokens experienced a considerable upswing through the concepts of [Decentralized Societies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4105763) and [Soulbound Tokens](https://vitalik.ca/general/2022/01/26/soulbound.html). By analyzing the standardization landscape of the non-transferable and bound tokens, they come with many different functionalities. However, they end up in a niche or minimal approach, mainly focused on NFTs with a single manager and issuer. The proposal seeks to act as a foundation across the following ideas:

- [ERC-5192], [ERC-6268], [ERC-7066]: Lock, Unlock, Transfer-Lock Events
- [ERC-5192], [ERC-5633], [ERC-6454]: Transferability Indicator
- [ERC-4671], [ERC-5516]: Revoke and Reject Functionality
- [ERC-5484], [ERC-4973]: Consensual Handout and Burn
- [ERC-1238], [ERC-5252]: Mint and Burn Approvals
- [ERC-5753]: Lock and Unlock Operator
- [ERC-6982]: Default Asset Lock Type

This standardization aims to facilitate enhanced adoption and convenience by introducing a generic but versatile interface for assets of the expansive on-chain data economy. It tries to enhance the primitives of Soulbound Tokens and Locks to foster the extensive requirements of social environments without constraining previous use cases. Therefore, the following attributes are embedded into the specification:

- **Interface Detection**: User interfaces cannot detect the restriction status of assets before calling their transfer function. In order to allow for seamless interactions, a unique interface ID MUST be retrievable so frontends can be adjusted based on their functionality.
- **Hybrid Restriction Support**: Society brings various of asset lifecycles like temporary locking, strict binding, and advanced logic like time-based solutions or backups. A restriction type needs to be queryable to gain adoption across the landscape.
- **Fungibility Independence**: Digital assets reach across regular tokens, NFTs, and semi-fungible or mixed assets standards. Restriction MUST be implemented for any fungibility type to allow broad but unified usage.
- **Consent during Handout**: Shared consent MUST be given whenever something can get locked. The receiver MUST approve the asset's content, restriction type, and operators. After approval, locked tokens and their transfer or removal rights MUST not be modified without re-approving or unlocking the asset.
- **Shared Transfer Management**: Various operators MUST be allowed to perform transfers to allow shared and extended management possibilities, like backups or community revoking, that go beyond issuer and holder,
- **Separate Removal Rights**: The owner SHOULD always be able to remove or burn the asset. On top of that, various people SHOULD be able to remove the asset from the smart contract. Transfer and Removal rights MUST be separated to allow granular control and shared management use cases without violating the right to removal of the owner.
- **Contract-based Retrieval**: If an asset is restricted and locked on a smart contract, it MUST be embedded so ownership and identity-based contexts can be proven directly from smart contract interaction.

Potential outcomes of the specification could allow:

- Soulbound Tokens
- Identity or human-limited tokens or vaults
- Community-restricted claims or their recovery
- Property-restricted bindings for services like domains
- Assets with added accessories or related appliances
- Reputation for skill-based and nuanced governance
- Accurate proof of attendance
- Non-financial rewards or recognition
- New membership opportunities
- Simple or hybrid lock-in or staking processes

## Specification

### Interface

Assets implementing the LSP22 standard MUST implement the [EIP-165] `supportsInterface(..)` types, mappings, and functions and MUST support the LSP22 interface ID.

**LSP22-TransferRestriction** interface IDs according to [EIP-165]:

- Minimal LSP22: `0xcd832c6e`
- Redeemable LSP22: `0x31f5bb2b`

_These `bytes4` interface IDs are calculated as the XOR of the functions selectors defined below_

### Enumerable Structures

#### RestrictionType

The following enumerated type MUST be implemented to represent the different types of assets with respect to their locking behavior:

```solidity
// Enumeration to define the different types of restrictions that can be applied to tokens
enum RestrictionType {
    None,             // default, falls back to the defaultRestrictionType
    TempLock          // can be locked, unlocked, and transferred
    SoftLock,         // locked, but deletable
    HardLock,         // permanently locked and non-transferable
}
```

- `None`: No (additional) restriction was set, meaning it will fall back to the default lock type of the contract that MUST be set during the initialization of the smart contract.
- `TempLock`: A dynamic locking mechanism where an asset can toggle between locked and unlocked states, governed by custom logic. The switching allows for asset recovery or community-based transfers while maintaining security. The lock status can be altered in response to particular events or conditions, ensuring adaptability and controlled access.
- `SoftLock`: A condition in which an asset, post-acceptance by the owner, is locked to its assigned address with provisions for deletion or removal under specific circumstances. Only designated addresses, per the predefined `RestrictionPermission` criteria, have the authority to remove the asset, balancing security and flexibility.
- `HardLock`: A status where an asset is irrevocably locked to its assigned address once accepted by the owner. Under this condition, the asset cannot be transferred or removed, ensuring permanent retention and immutability.

A default restriction type of the asset MUST be predefined during the instantiation of the smart contract. However, each asset can be further restricted for addresses or token IDs individually.

A restriction type MAY ONLY be changed if `redeemAsset` is implemented when an owner wants to permanently `SoftLock` or `HardLock` the asset to his account. Otherwise, the restriction type can be re-set upon every successful `lockAsset` function call.

#### RestrictionPermission

The following enumerated permission set MUST be implemented to represent the different permissions of assets regarding their transfer behavior.

```solidity
// Enumeration to define the various permission levels associated with transfer restriction and management
enum RestrictionPermission {
    None,               // default, no permissions granted
    CanRemove,          // permission to disassociate the account from the asset
    IsOperator,         // permission to lock, unlock, transfer, and delete the asset
}
```

- `None`: The default value of the enum indicates that the address has no privileges regarding the locking method of the asset.
- `CanRemove`: Indicates that the address has the right to disassociate from the asset in case of expiration or particular condition. The allowed address can burn or transfer the asset to the zero address.
- `isOperator`: Indicates that the asset can be transferred to another address regarding backups or shared community management when it is unlocked.

### Structs

#### LockInfo

The `LockInfo` struct MUST be implemented to show the current transferability, when the status was changed, and by whom.

```solidity
struct LockInfo {
    bool isLocked;      // current lock indicator
    address executedBy; // operator who locked/unlocked the asset
    uint lockedAt;      // block number of when the asset was locked
}
```

#### AddressPermission

The `AddressPermission` struct MUST be implemented to coordinate the addresses and their permissions within the `lockAsset` function.

```solidity
struct AddressPermission {
    address addr;
    RestrictionPermission permission;
}
```

### Mappings

#### tokenRestriction

The following `tokenRestriction` mapping MUST be implemented to associate each asset with its `RestrictionType`. Depending on the fungibility, the `RestrictionType` is attached to a token ID or account. The `tokenRestriction` is set within the `lock` function.

```solidity
// For fungible assets, the key is the owner's address casted to uint256
// For non-fungible assets, the key will be the tokenID.
mapping(uint256 => RestrictionType) public tokenRestriction;
```

#### tokenPermissions

The following hierarchical `tokenPermissions` mapping MUST be implemented to associate each asset with a set of addresses and their respective `RestrictionPermission`. The addresses and restrictions are attached to a token ID or account, depending on the fungibility. The `tokenPermissions` of an asset are set within the `lock` function.

```solidity
// For fungible assets, the key is the owner's address casted to uint256
// For non-fungible assets, the key will be the tokenID.
mapping(uint256 => mapping(address => RestrictionPermission)) public tokenPermissions;
```

#### lockStatus

The following `lockStatus` mapping MUST be implemented regarding the `TempLock` property of the `restrictionType` mapping to verify if the asset is currently locked or transferable. The boolean is attached to a token ID or account, depending on the fungibility.

```solidity
// For fungible assets, the key is the owner's address casted to uint256
// For non-fungible assets, the key will be the tokenID.
mapping(uint256 => LockInfo) public lockStatus;
```

#### EIP-712 Nonces

The nonce MUST be implemented to ensure that every [EIP-712] signature is unique whenever an operator key of a smart contract grants a lock permission. Each address has its nonce, which increases with each locking operation. It's a unique number meant to be used once to prevent replay attacks.

```solidity
mapping(address => uint256) public nonces;
```

### Variables

#### defaultRestrictionType

The `defaultRestrictionType` variable MUST be set during the contract's initialization within the `constructor` to provide a unified behavioral template for all assets under the smart contract. It determines the standard restriction that will be applied to any asset unless specified otherwise using the `redeem` function. The `defaultRestrictionType` MUST NOT be set to the restriction type `None`.

```solidity
// Indicates the default restriction type for assets under this smart contract
RestrictionType public defaultRestrictionType = RestrictionType.<Type>;
```

#### EIP-712 Domain Separator

A `domainSeparator` is a hash value specific to the asset contract and MUST be implemented to prevent signature replay attacks across different contracts and chains. The separator includes the following details:

- contract name
- version
- chain ID
- contract address

```solidity
bytes32 private domainSeparator;
```

#### EIP-712 Type Hashes

The following type hashes are unique identifiers that MUST be implemented for the data structures being signed during the `lockAsset` function.

```solidity
bytes32 private constant DOMAIN_TYPEHASH;
bytes32 private constant LOCK_TYPEHASH;
```

- `DOMAIN_TYPEHASH` is a standardized identifier for the `domainSeparator`.
- `LOCK_TYPEHASH` defines the LSP22-specific data structure that will be hashed and signed.

These values are implemented within the [EIP-712 Consent](#eip-712-consent) section.

### Methods

#### lockAsset

The `lockAsset` function MUST be implemented to lock an asset with a specified `RestrictionType` and an array of `AddressPermission`. In order to lock the asset, the [EIP-712] signature of the receiver MUST be included. The [EIP-712] typed structured data that will be signed MUST include:

- the [LSP4] metadata of the asset
- the `RestrictionType` of the asset
- an array of all `AddressPermission` objects

Before locking the asset, the function MUST prove the [EIP-712] signature and check if the `msg.sender` was included with the `isOperator` permission. Any transfer function MUST fail after the asset is locked and its `lockStatus` entry is set. The function can only be called once if `restrictionType` is set to `SoftLock` or `HardLock`. If the restriction type is set to `TempLock`, the asset MUST be unlocked before an `isOperator` address can transfer it to a new address. Upon receipt, the asset MUST be added to the receiving smart contract's [LSP5] storage. The address of the signature MUST be verified against the [LSP6] `sign` permission of the [LSP5]-based smart contract to allow consent via operator keys. If the key is not permitted to sign for the smart contract, the `lockAsset` function MUST fail.

> Upon re-locking an asset, the receiver MUST sign again. This process MAY involve adding new operator addresses or changing the restrictionType.

> The locking method SHOULD be combined with the initial transfer if the asset will be locked right after. The combination of transfer and lock, similar to the idea of [ERC-7066], reduces potential blockers if the receiver does not consent.

```solidity
function lockAsset(
    uint256 key,
    address owner,
    string calldata metadata,
    RestrictionType type,
    AddressPermission[] memory permissions,
    uint8 v,
    bytes32 r,
    bytes32 s,
    address signer
) external;
```

_Parameters_

- `key`: The identifier of the asset. Based on the fungibility, the key will be the tokenID or the holder's account casted to uint256.
- `owner`: The current or new owner after the asset is locked or transferred and locked. If transferable, equals the `key`.
- `metadata`: The stringified [LSP4] metadata of the related digital asset.
- `type`: The RestrictionType that is applied to the asset.
- `permissions`: An array of addresses and their respective permissions.
- `v`, `r`, `s`: Off-chain signature parts of [EIP-712] generated using the private key of the `owner`.
- `signer`: The address of the operator key of the smart contract that was used to generate the signature.

> [EIP-712]: The hashed structured data consists of the `metadata`, `type`, and `permissions` parameters of the asset that will be locked. When the signature is sent to a smart contract function, the contract uses the `v`, `r`, and `s` values calculate the signer's address. If the calculated address matches the signing rights of the [LSP6], the `lockAsset` function can be further executed. An implementation can be found within [EIP-712 Consent](#eip-712-consent).

_Events_

- MUST emit the `AssetLocked` event after successfully locking an asset.

#### unlockAsset

The `unlockAsset` function MUST be implemented to unlock an asset if its restriction type is `TempLock`. After the asset is unlocked, only addresses of the asset that have the `isOperator` permission can call the transfer function. When the `unlockAsset` function is called, it has to update the `lockStatus` entry.

```solidity
function unlockAsset(uint256 key) external;
```

_Parameters_

- `key`: The identifier of the asset. Based on the fungibility, the key will be the tokenID or the holder's account casted to uint256.

_Events_

- MUST emit the `AssetUnlocked` event after successfully unlocking an asset.

#### removeAsset

The `removeAsset` function MUST be implemented to disassociate an asset from the owner if its restriction type is `TempLock` or `SoftLock`. The function transfers the ownership to the `zero address`. The `removeAsset` function checks if the `msg.sender` has the `CanRemove` or `isOperator` restriction permission. After approval, all `restrictionPermission` entries within the asset's `tokenPermissions` entry must be set to `None`. Upon removal, the asset MUST also be removed from the owner account's [LSP5] storage.

```solidity
function removeAsset(uint256 key) external;
```

_Parameters_

- `key`: The identifier of the asset. Based on the fungibility, the key will be the tokenID or the holder's account casted to uint256.

_Events_

- MUST emit the `AssetRemoved` event after successfully removing an asset from an address.

#### redeemAsset

The `redeemAsset` function MAY be implemented to allow owners of an asset to permanently lock it to their own or an owned and allowlisted address by changing the `restrictionType` to a different category.

- `TempLock` MAY be updated to `SoftLock` or `HardLock`
- `SoftLock` MAY be updated to `HardLock`

```solidity
redeemAsset(uint256 key, RestrictionType type, address finalOwner) external;
```

_Parameters_

- `key`: The identifier of the asset. Based on the fungibility, the key will be the tokenID or the address of the holder casted to uint256.
- `type`: The RestrictionType that is applied to the asset.
- `finalOwner`: The address of the current owner or an owned and allowlisted [LSP5]-based smart contract. If fungible, equals the `key`.

_Events_

- MUST emit the `AssetRedeemed` event after permanently locking an asset.

### Events

#### AssetLocked

Emitted when an asset is locked using the `lockAsset` function.

```solidity
event AssetLocked(uint256 indexed key, RestrictionType indexed type, address indexed owner, address executor, AddressPermission[] permissions);
```

_Parameters_

- `key`: The identifier of the asset. Based on the fungibility, the key will be the tokenID or the holder's address casted to uint256.
- `type`: The type of restriction applied to the asset at the time of locking.
- `owner`: The address of the smart contract that it was locked to. If fungible, equals the `key`.
- `executor`: The address of the smart contract that executed the lock operation.
- `permissions`: An array listing all addresses with their respective permissions for this asset.

#### AssetUnlocked

Emitted when an asset is unlocked using the `unlockAsset` function.

```solidity
event AssetUnlocked(uint256 indexed key, address indexed owner, address indexed executor);
```

_Parameters_

- `key`: The identifier of the asset. Based on the fungibility, the key will be the tokenID or the holder's address casted to uint256.
- `owner`: The address of the smart contract that it was unlocked on. If fungible, equals the `key`.
- `executor`: The smart contract address that executed the unlock operation.

#### AssetRemoved

Emitted when an asset is removed using the `removeAsset` function.

```solidity
event AssetRemoved(uint256 indexed key, address indexed removedFrom, address indexed executor);
```

_Parameters_

- `key`: The identifier of the asset. Based on the fungibility, the key will be the tokenID or the holder's address casted to uint256.
- `removedFrom`: The smart contract address that it was removed from.
- `executor`: The smart contract address that executed the removal operation.

#### AssetRedeemed

Emitted when an asset is redeemed using the `redeemAsset` function.

```solidity
event AssetRedeemed(uint256 indexed key, RestrictionType indexed newType, address indexed finalOwner);
```

_Parameters_

- `key`: The identifier of the asset. Based on the fungibility, the key will be the tokenID or the holder's address casted to uint256.
- `newType`: The new RestrictionType applied to the asset after redemption.
- `finalOwner`: The address of the smart contract the asset was redeemed on.

## Rationale

The interface is designed to be flexible and adaptable to various assets such as [LSP7] and [LSP8] that are held by any [LSP5]-based smart contracts like [LSP0] or [LSP9]. It uses [EIP-165] to quickly identify the supported interface and [EIP-712] to handle consent-based locking. To enable this consent across smart contract accounts, [LSP6] is used to verify signer permissions.

By providing a generic functionality for the locking and the associated restriction types, the standard acts as a primitive for many different asset lifecycles without preventing unauthorized transfers or changes after locking. Additionally, regular asset transfers are preserved without requiring consent.

The `lockAsset`, `unlockAsset`, `removeAsset`, and `redeemAsset` methods offer flexibility in defining transfer restrictions based on different permissions. By having public mappings for `tokenRestriction`, `tokenPermissions`, and `lockStatus`, all restriction data can constantly be retrieved directly from the asset.

## Compatibility

This standard is designed to be compatible with existing assets based on [LSP4] metadata (like [LSP7] and [LSP8]) managed by [LSP5]-based smart contracts (like [LSP0] and [LSP9]). The contracts implementing this standard need to ensure proper integration with the token standard and handle any potential conflicts with existing methods or events.

## Implementation

### LSP22 Setup

A reference implementation of the full contract will be provided upon further development of the proposal.

### EIP-712 Structure

The following setup and structure establish consent on every `lockAsset` function.

> Check the [EIP-712] standardization for further information.

```solidity
// LSP22 Contract Identification
bytes32 private constant DOMAIN_TYPEHASH = keccak256(
    "EIP712Domain(                                  // identifier name
        string name,                                // contract name
        string version,                             // contract version
        uint256 chainId,                            // chain ID
        address contract                            // address of the contract
    )"
);

// LSP22 Signed Data Structure
bytes32 private constant LOCK_TYPEHASH = keccak256(
    "lockAsset(                                     // lock function name
        address owner,                              // address that will own the locked asset
        string metadata,                            // stringified LSP5 metadata of the asset
        RestrictionType type,                       // restriction type of the asset
        AddressPermission[] permissions,            // array of addresses and their permissions
        address signer,                             // address that signed the typed structured data
        uint256 nonce                               // nonce of the signer
    )"
);

bytes32 private domainSeparator;

mapping(address => uint256) public nonces;

// LSP22 Signature Initialization
constructor() {
    domainSeparator = keccak256(abi.encode(
        DOMAIN_TYPEHASH,
        keccak256(bytes("<LockableAsset>")),        // hash of the asset's name
        keccak256(bytes("<1>")),                    // has of the asset version
        block.chainid,                              // chain ID
        address(this)                               // contract address
    ));
}
```

### EIP-712 Signature Approval

The following setup shows how consent is applied to the `lockAsset` function. In order to check the permission of the smart contract's operator key that signed the typed data structure, [LSP6] is used for authentication.

```solidity
// Signature Approval
function lockAsset(
    uint256 key,
    address owner,
    string calldata metadata,
    RestrictionType type,
    AddressPermission[] memory permissions,
    uint8 v,
    bytes32 r,
    bytes32 s,
    address signer
) external {
    bytes32 digest = keccak256(abi.encodePacked(    // hash of the data structure
        "\x19\x01",                                 // EIP-712 prefix (\<indicator>\<version>)
        domainSeparator,
        keccak256(abi.encode(
            LOCK_TYPEHASH,
            owner,
            metadata,
            type,
            permissions,
            signer nonces[signer]++                 // raise nonce after its used for hashing
        ))
    ));

    // get the operator address based on hash and signature
    address recovered_signer = ecrecover(digest, v, r, s);

    // retrieve the key permission of the signer
    bytes32 lsp6key = keccak256(abi.encodePacked("0x4b80742de2bf866c29110000", recovered_signer));

    // simplified instantiation of the LSP6 contract
    ownerContract = IExternalContract(owner);

    // retrive the permissions of the key
    bytes32 permissions = ownerContract.getData(lsp6key);

    // check if the signer has permission for the owner's address
    bytes32 signingThreshold = uint256(0x0000000000000000000000000000000000000000000000000000000000200000);
    bytes32 signingPermission = uint256(permissions);
    require(signingPermission < signingThreshold, "Invalid signature");
}
```

## Interface Cheat Sheet

```solidity
// Transfer Restriction and Management Interface
interface IAssetRestriction /* is ERC165 */ {

    // LSP22

    enum RestrictionType { None, TempLock, SoftLock, HardLock }

    enum RestrictionPermission { None, CanRemove, IsOperator }

    struct LockInfo { bool isLocked; address executedBy; uint lockedAt; }

    struct AddressPermission { address addr; RestrictionPermission permission; }

    mapping(uint256 => RestrictionType) public tokenRestriction;

    mapping(uint256 => mapping(address => RestrictionPermission)) public tokenPermissions;

    mapping(uint256 => LockInfo) public lockStatus;

    RestrictionType public defaultRestrictionType;

    function lockAsset(
        uint256 key,
        address owner,
        string calldata metadata,
        RestrictionType type,
        AddressPermission[] memory permissions,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address signer
    ) external;

    function unlockAsset(uint256 key) external;

    function removeAsset(uint256 key) external;

    function redeemAsset(uint256 key, RestrictionType type, address finalOwner) external;

    event AssetLocked(
        uint256 indexed key,
        RestrictionType indexed type,
        address indexed owner,
        address executor,
        AddressPermission[] permissions
    );

    event AssetUnlocked(uint256 indexed key, address indexed owner, address indexed executor);

    event AssetRemoved(uint256 indexed key, address indexed removedFrom, address indexed executor);

    event AssetRedeemed(uint256 indexed key, RestrictionType indexed newType, address indexed finalOwner);

    // EIP-712

    bytes32 private constant DOMAIN_TYPEHASH;

    bytes32 private constant LOCK_TYPEHASH;

    bytes32 private domainSeparator;

    mapping(address => uint256) public nonces;
}
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[EIP-165]: https://eips.ethereum.org/EIPS/eip-165
[EIP-712]: https://eips.ethereum.org/EIPS/eip-712
[ERC-5192]: https://eips.ethereum.org/EIPS/eip-5192
[ERC-6268]: https://eips.ethereum.org/EIPS/eip-6268
[ERC-7066]: https://eips.ethereum.org/EIPS/eip-7066
[ERC-5192]: https://eips.ethereum.org/EIPS/eip-5192
[ERC-5633]: https://eips.ethereum.org/EIPS/eip-5633
[ERC-6454]: https://eips.ethereum.org/EIPS/eip-6454
[ERC-4671]: https://eips.ethereum.org/EIPS/eip-4671
[ERC-5516]: https://eips.ethereum.org/EIPS/eip-5516
[ERC-5484]: https://eips.ethereum.org/EIPS/eip-5484
[ERC-4973]: https://eips.ethereum.org/EIPS/eip-4973
[ERC-1238]: https://erc1238.notion.site/
[ERC-5252]: https://eips.ethereum.org/EIPS/eip-5252
[ERC-5753]: https://eips.ethereum.org/EIPS/eip-5753
[ERC-6982]: https://eips.ethereum.org/EIPS/eip-6982
[ERC-7066]: https://eips.ethereum.org/EIPS/eip-7066
[LSP0]: ./LSP-0-ERC725Account.md
[LSP4]: ./LSP-4-DigitalAsset-Metadata.md
[LSP5]: ./LSP-5-ReceivedAssets.md
[LSP6]: ./LSP-6-KeyManager.md
[LSP7]: ./LSP-7-DigitalAsset.md
[LSP8]: ./LSP-8-IdentifiableDigitalAsset.md
[LSP9]: ./LSP-9-Vault.md
