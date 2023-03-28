---
lip: 22
title: Transfer Restriction
author: Felix Hildebrandt <@fhildeb>
discussions-to: https://discord.gg/lukso
status: Draft
type: LSP
created: 2022-03-22
requires: ERC165, LSP1, LSP14
---

> STRUCTURES AND FUNCTION WILL CHANGE AS THIS IDEA IS A COMMON GROUND FOR DEVELOPMENT.

## Simple Summary

This standard describes an interface to restrict transferability.


## Abstract

This standard defines an interface for smart contracts, mainly assets and vaults, to disable or restrict their transferability to certain Universal Profiles or bind them to another asset. It has built-in consent for the receiver via [LSP14] and can house information about the restriction type, allowed kind of interactions, and current status. 

The consens should be interrelated with token hooks of [LSP1] in later stages. So far there is no specific plan for this feature as I seek for feedback on how to integrate such.

The inspiration mainly comes from the ideas of 
- [ERC-5192] locking,
- [ERC-5484] and [LSP14] consensus
- [ERC-5516] multi-ownability
- [ERC-4671] revokability
- [ERC-5114] asset-binding

## Motivation

When regular smart contracts have custom logic around their transferability, frontends have no generic way to determine if the instance has a specific limitation or is locked. The only way to find out would be to catch the `transfer` error after calling it. Applications like marketplaces, recovery services, and social apps need to check transfer-restriction properties beforehand to adjust UI accordingly. In the future, namely on what is outlined
as decentral society right now, restriction of behaviour will be a main pillar. 

Looking at the eager development of bound token over the last year, one common ground they share is indeed their restriction. However, everyone has their own niche way of doing so as every standard has a separate use-case. By coming up with a generic restriction interface, many possibilities and standards could leverage the interaction flow. An important step into this direction is the consent if an asset or vault is locked after transfer- increasing friendliness and broad acceptance.

A generic transfer restriction interface would enable a vast spectrum of use-cases: 
- temporary or final lock-in
- soulbound, account-bound, or non-tradable tokens and vaults
- identity or human-based approvals if there is connected authentication
- property-restricted bindings for services like aquired domains
- assets with added accessories or redeemed appliances
- reputation, to determine skill-based and nuanced governance or access
- accurate non-tradable proof of attendance
- non-financial rewards or recognition

If transferability restriction is set up by a organisation, it further allows for:
- community-restricted claims and management
- social membership opportunities

## Specification

**LSP22-TransferRestriction** interface id according to [ERC165]: `TBD`.

_This `bytes4` interface id is calculated as the XOR of the functions selectors defined below_

Smart contracts implementing the LSP22 standard MUST implement the [ERC165] `supportsInterface(..)` types, mapping and functions and MUST support the LSP22 interface id.

### Enumerable

The following enumerated type MUST be implemented to represent the different types of assets with respect to their locking behavior:

```Solidity
enum RestrictionType {
    HardLock,         // Permanently locked and non-transferable
    SoftLock,         // Locked, but deletable
    TempLock          // Can be (un)locked and transferred
}

RestrictionType public restrictionType;
```

1. `HardLock`: Caution, the asset is hard locked into its position after the owner choose to accept it without the functionality to ever remove it.
2. `SoftLock`: The asset is locked position after the owner choose to accept it. However, the asset can be deleted from certain addresses
3. `TempLock`: The asset can be locked or unlocked based on costom logic to enable recovery or community-based transfers.

The type of a contract CAN ONLY be changed if `redeem` is implemented when wanting to lock an entity to another asset, instead of an account.

### Mapping

The following mapping MUST be implemented to represent if a address is able to destroy or transfer the asset:

```Solidity
mapping(address => uint) public restrictionPermission;
```

- `0`: Can not perform any action
- `1`: Can delete
- `2`: Can delete & transfer
- `3`: Can delete & transfer & set allow actions

### Mandatory Methods

Smart contracts implementing the LSP22 standard MUST implement the following functions:

#### getRestrictionInfo

```solidity
getRestrictionInfo() external view returns (bool isLocked, RestrictionType restrictionType);
```

Check if the asset is currently locked and whats the restrictionType.

#### locked

```solidity
locked(bool isLocked) external;
```

Locks or Unlocks the contract to the new address. 

- MUST be connected to a arbitrary consent (like [LSP14]) if restrictionType is `HardLock` or `SoftLock`
- If locked, `transfer` or `transferOwnership` can not be called
- CAN ONLY be called once if `restrictionType` is `HardLock`

#### delete

```solidity
delete() external;
```

Deletes the contract from the address on custom logic. Some examples would be burning the asset or just change ownership to the `zero address`.

- MUST check if `restrictionPermission` of msg.sender is greater or equal `0`
- MUST emit `Deleted` event

#### transfer

```solidity
function transfer(address from, address to, ... ) external;
```

Fallback to transfer function of the underlying smart contract (asset).

This function CAN ONLY be called when the asset is `unlocked` and the `assetType` is `TempLock`. Otherwise, the consent is needed and [LSP14] MUST be used.

- MUST check if allow list of caller is greater or equal `1`

#### pendingOwner

```solidity
function pendingOwner() external view returns (address);
```

This function is part of the [LSP14] specification.

#### transferOwnership

```solidity
function transferOwnership(address newPendingOwner) external;
```

This function is part of the [LSP14] specification.

#### acceptOwnership

```solidity
function acceptOwnership() external;
```

This function is part of the [LSP14] specification

#### renounceOwnership

```solidity
function renounceOwnership() external;
```

This function is part of the [LSP14] specification.

### Optional Methods

Smart contracts implementing the LSP22 standard CAN implement the following functions:
#### redeem

```solidity
redeem(address asset) external;
```

Redeems the transferability of an address forever and locks it in place by setting type to `HardLock`. Used for entities that are bound to another asset, like the binding of accessories or digital goods to avatars

- CAN ONLY be executed if sender is owner of both assets
- MUST use additional request like `transferOwnership` but to owner itself
- MUST emit `Redeemed` event when `acceptOwnership` went through

#### updateRestrictionPermission

```solidity
updateRestrictionPermission(address asset, uint value) external;
```

Updates the values in the `restrictionPermission` 

- MUST check if `restrictionPermission` of msg.sender is equal to `2`
- MUST emit event `RestrictionPermissionUpdated`

### Events

#### LockingSet

```solidity
event LockingSet(bool locked, address owner);
```

MUST be emitted when the contact is locked or unlocked. 

#### Deleted

```solidity
event Deleted(address owner, address contract);
```

MUST be emitted when the contact is deleted.

#### Redeemed

```solidity
event Redeemed(address owner, address contract);
```

MUST be emitted when the contact is redeemed.

#### RestrictionPermissionUpdated

```solidity
event RestrictionPermissionUpdated(address user, uint permission);
```

MUST be emitted when the allow list was updated.

#### Transfer

When consent is needed, events MUST be emitted like defined in [LSP14] spec. Otherwise, fall back to regular transfer events. 

## Rationale

The interface is designed to be flexible and adaptable to various token and vault standards, such as [LSP7], [LSP8], and [LSP9]. It uses [LSP165] to quickly identify the supported interface and [LSP14] to handle consent-based ownership transfers.

By providing a two-step process for transferring ownership, the standard ensures that both parties (the current owner and the new owner) consent to the transfer whenever an _initial_ or _following_ lock-in process is involved. The backing prevents accidental or unauthorized transfers. If no locking mechanism occurs on transfer, it can be sent without a two-step process.

The `lock`, `unlock`, `delete`, `redeem`, `updateRestrictionPermission` and `getRestrictionInfo` methods offer flexibility in defining transfer restrictions based on different conditions or rules.

## Compatibility
This standard is designed to be compatible with existing standards based on [LSP7], [LSP8], and [LSP9]. The contracts that are implementing this standard need to ensure proper integration with the base token standard and handle any potential conflicts with existing methods or events.

## Implementation

A reference implementation will be provided upon further development of the proposal. The implementation should demonstrate how the standard can be applied to assets and vaults with various restriction types to showcase different transfer behavior.

## Interface Cheat Sheet

```solidity

interface ILSP22  /* is ERC165 */ {  

    // Enumeration  
    enum RestrictionType {
        HardLock,
        SoftLock,
        TempLock
    }

    // Restrictions
    function restrictionType() external view returns (RestrictionType);
    function restrictionPermission(address user) external view returns (uint);
    function getRestrictionInfo() external view returns (bool isLocked, RestrictionType restrictionType);
    function updateRestrictionPermission(address asset, uint value) external;

    // Actions
    function locked(bool isLocked) external;
    function delete() external;
    function transfer(address from, address to, ...) external;
    function redeem(address asset) external;

    // LSP14
    function pendingOwner() external view returns (address);
    function transferOwnership(address newPendingOwner) external;
    function acceptOwnership() external;
    function renounceOwnership() external;
    
    
    // Events
    event LockingSet(bool locked, address owner);
    event Deleted(address owner, address contract);
    event Redeemed(address owner, address contract);
    event RestrictionPermissionUpdated(address user, uint permission);
}
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[ERC-5192]: <https://eips.ethereum.org/EIPS/eip-5192>
[ERC-5484]: <https://eips.ethereum.org/EIPS/eip-5484>
[ERC-5516]: <https://eips.ethereum.org/EIPS/eip-5516>
[ERC-4671]: <https://eips.ethereum.org/EIPS/eip-4671>
[ERC-5114]: <https://eips.ethereum.org/EIPS/eip-5114>
[LSP1]: <./LSP-1-UniversalReceiver.md>
[LSP7]: <./LSP-7-DigitalAsset.md>
[LSP8]: <./LSP-8-IdentifiableDigitalAsset.md>
[LSP9]: <./LSP-9-Vault.md>
[LSP14]: <./LSP-14-Ownable2Step.md>
