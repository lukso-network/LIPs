---
lip: 14
title: Ownable 2 Step
author:
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2022-09-23
requires: ERC173, LSP1
---

## Simple Summary

<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->

This standard describes an extended version of [EIP173](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md) that uses a 2-step process to transfer or renounce ownership of a contract, instead of instant execution. It aims for a more secure management of contract ownership via a 2-step verification when transferring ownership of a contract.

In addition, this standard defines hooks that call the [`universalReceiver(...)`] function of the current owner and new owner, if these addresses are contracts that implement LSP1. This aims to:

- notify when the new owner of the contract should accept ownership.
- notify the previous and new owner when ownership of the contract has been fully transferred.

## Abstract

<!--A short (~200 word) description of the technical issue being addressed.-->

LSP14 - Ownable2Step simplifies ownership management in smart contracts through a two-step process, enhancing security and preventing accidental loss of control. Unlike instant ownership transfer, LSP14 ensures deliberate actions by requiring the new owner's acceptance, thereby minimizing risks associated with wrong addresses or lost keys. It also incorporates LSP1's universalReceiver function, enabling notifications during ownership changes, fostering transparency and communication between the previous and new owners. This standard is crucial for maintaining control over contracts, especially in scenarios where ownership carries significant power and access to sensitive functions. Through LSP14, LUKSO enhances the safety and reliability of contract ownership transitions, supporting a more secure and user-friendly blockchain ecosystem.

Because owning the contract allows access to sensitive methods, transferring to the wrong address or renouncing ownership of the contract by accident in a single transaction can be highly dangerous. Having those two processes work in 2 steps substantially reduces the probability of transferring or renouncing ownership of the contract by accident.

## Motivation

<!--The motivation is critical for LIPs that want to change the Ethereum protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->

The particular issue that the LSP14 standard solves is the irreversible nature of transferring or renouncing ownership of a contract.

Transferring ownership of the contract in a single transaction does not guarantee that the address behind the new owner (EOA or contract) is able to control the Ownable contract. For instance, if the new owner lost its private key or if the new owner is a contract that does not have any generic execution function.

Letting the new owner accept ownership of the contract guarantees that the contract is owned by an address (EOA or contract) that can be controlled, and that control over the contract implementing LSP14 will not be lost.

Finally, transferring ownership of the contract in two-steps enables the new owner to decide if he wants to become the new owner or not.

## Specification

[ERC165] interface id: `0x94be5999`

_This interface id can be used to detect Ownable2Step contracts._

### Methods

The methods are based on the methods from [ERC173](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md#specification) (Ownable), with additional changes. _See below for details_

#### owner

```solidity
function owner() external view returns (address);
```

Returns the `address` of the current contract owner.

#### pendingOwner

```solidity
function pendingOwner() external view returns (address);
```

Returns the `address` of the upcoming new owner that was initiated by the current owner via `transferOwnership(address)`.

**Requirements:**

- MUST be `address(0)` if no ownership transfer is in progress.
- MUST be set to a new `address` when transferring ownership of the contract via `transferOwnership(address)`.
- SHOULD be cleared once the [`pendingOwner()`](#pendingowner) has accepted ownership of the contract.

#### transferOwnership

```solidity
function transferOwnership(address newOwner) external;
```

Sets the `newOwner` as `pendingOwner()`. To transfer ownership fully of the contract, the pending owner MUST accept ownership via the function `acceptOwnership()`.

MUST emit a [`OwnershipTransferredStarted`](#ownershiptransferstarted) event once the new owner was set as `pendingOwner()`.

**Requirements:**

- MUST only be called by the current `owner()` of the contract.

**LSP1 Hooks:**

- If the new owner address supports [LSP1](./LSP-1-UniversalReceiver.md) interface, SHOULD call the new owner's [`universalReceiver(...)`] function with the default parameters below:

  - `typeId`: `keccak256('LSP14OwnershipTransferStarted')` > `0xee9a7c0924f740a2ca33d59b7f0c2929821ea9837ce043ce91c1823e9c4e52c0`
  - `data`: The data sent SHOULD be abi encoded and contain the [current owner](#owner) (`address`) and the [pending owner](#pendingowner) (`address`) respectively.

The Type ID associated with this hook COULD be altered in a contract that inherits from LSP14. This allows for more straightforward identification of the contract whose ownership is being transferred. Example where the LSP14 type ID is overridden can be found in [LSP0](LSP-0-ERC725Account.md#transferownership) and [LSP9](LSP-9-Vault.md#transferownership) standards.

#### acceptOwnership

```solidity
function acceptOwnership() external;
```

Allows the `pendingOwner()` to accept ownership of the contract.

This function MUST be called as the second step (after `transferOwnership(address)`) by the current `pendingOwner()` to finalize the ownership transfer.

MUST emit a [`OwnershipTransferred`](https://eips.ethereum.org/EIPS/eip-173#specification) event once the new owner has claimed ownership of the contract.

**Requirements:**

- MUST only be called by the `pendingOwner()`.

**LSP1 Hooks:**

- If the previous owner is a contract that supports [LSP1](./LSP-1-UniversalReceiver.md) interface, SHOULD call the previous owner's [`universalReceiver(...)`] function with the default parameters below:

  - `typeId`: `keccak256('LSP14OwnershipTransferred_SenderNotification')` > `0xa124442e1cc7b52d8e2ede2787d43527dc1f3ae0de87f50dd03e27a71834f74c`
  - `data`: The data sent SHOULD be abi encoded and contain the [previous owner](#owner) (`address`) and the new owner (`address`) respectively.

- If the new owner is a contract that supports [LSP1](./LSP-1-UniversalReceiver.md) interface, SHOULD call the new owner's [`universalReceiver(...)`] function with the default parameters below:

  - `typeId`: `keccak256('LSP14OwnershipTransferred_RecipientNotification')` > `0xe32c7debcb817925ba4883fdbfc52797187f28f73f860641dab1a68d9b32902c`
  - `data`: The data sent SHOULD be abi encoded and contain the [previous owner](#owner) (`address`) and the new owner (`address`) respectively.

The Type IDs associated with these hooks can be altered in a contract that inherits from LSP14. This allows for more straightforward identification of the contract whose ownership is being transferred. Examples where the LSP14 type IDs are overridden can be found in the [LSP0](LSP-0-ERC725Account.md#acceptownerhsip) and [LSP9](LSP-9-Vault.md#acceptownership) standards.

#### renounceOwnership

```solidity
function renounceOwnership() external;
```

Leaves the contract without an owner. Once ownership of the contract is renounced, it MUST NOT be possible to call functions restricted to the owner only.

Since renouncing ownership is a sensitive operation, it SHOULD be done as a two step process by calling `renounceOwnership(..)` twice. First to initiate the process, second as a confirmation.

MUST emit a [`RenounceOwnershipInitiated`](#renounceownershipinitiated) event on the first `renounceOwnership(..)` call.
MUST emit [`OwnershipTransferred`](https://eips.ethereum.org/EIPS/eip-173#specification) event after successfully renouncing the ownership.

**Requirements:**

- MUST be called only by the `owner()` only.
- The second call MUST happen AFTER the delay of 100 blocks and within the next 100 blocks from the first `renounceOwnership(..)` call.
- If 200 blocks have passed, the `renounceOwnership(..)` call phase SHOULD reset the process, and a new one will be initiated.

**LSP1 Hooks:**

- If the previous owner is a contract that supports [LSP1](./LSP-1-UniversalReceiver.md) interface, SHOULD call the previous owner's [`universalReceiver(...)`] function with the default parameters below on the second renounce ownership call:

  - `typeId`: `keccak256('LSP14OwnershipTransferred_SenderNotification')` > `0xa124442e1cc7b52d8e2ede2787d43527dc1f3ae0de87f50dd03e27a71834f74c`
  - `data`: The data sent SHOULD be abi encoded and contain the [previous owner](#owner) (`address`) and the new owner (`address`) respectively.

### Events

#### OwnershipTransferStarted

```solidity
event OwnershipTransferStarted(address indexed currentOwner, address indexed newOwner);
```

MUST be emitted when the process of transferring owhership of the contract is initiated.

_Values:_

- `currentOwner` Address of the current owner of the contract that implements LSP14.

- `newOwner` Address that will receive ownership of the contract that implements LSP14.

#### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

MUST be emitted when ownership of the contract has been transferred.

#### RenounceOwnershipStarted

```solidity
event RenounceOwnershipStarted();
```

MUST be emitted when the process of renouncing ownership of the contract is initiated.

#### OwnershipRenounced

```solidity
event OwnershipRenounced();
```

MUST be emitted when ownership of the contract has been renounced.

## Interface Cheat Sheet

```solidity
interface ILSP14  /* is ERC173 */ {


    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event RenounceOwnershipInitiated();

    event OwnershipRenounced();


    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function transferOwnership(address newOwner) external; // onlyOwner

    function acceptOwnership() external; // only pendingOwner()

    function renounceOwnership() external; // onlyOwner

}
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: https://eips.ethereum.org/EIPS/eip-165
[LSP1-UniversalReceiver]: ./LSP-1-UniversalReceiver.md
[LSP2-ERC725YJSONSchema]: ./LSP-2-ERC725YJSONSchema.md
[`universalReceiver(...)`]: ./LSP-1-UniversalReceiver.md#universalreceiver
