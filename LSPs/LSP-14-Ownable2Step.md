---
lip: 14
title: Ownable2Step
author:  
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2022-09-23
requires: ERC173
---

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->
This contract describes a version of [EIP173](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md), it being different by making the process of transferring ownership and renouncing ownership a 2-step process instead of instant execution.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
The particular issue that this implementation of [EIP173](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md) solves is the irreversible nature of transferring or renouncing ownership of a contract. Because owning the contract allows you to have access to sensitive methods, transferring or renouncing ownership of the contract by accident in a single transaction can be highly dangerous. Having those two processes work in 2 steps will substantially reduce the probability of transferring or renouncing ownership of the contract by accident.

## Motivation
<!--The motivation is critical for LIPs that want to change the Ethereum protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->


## Specification

[ERC165] interface id: `0x94be5999`

_This interface id can be used to detect Ownable2Step contracts._

### Methods

Contains the methods from:
- [ERC173](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md#specification) (Ownable). *See below for details*

#### owner

```solidity
function owner() external view returns (address);
```

Returns the `address` of the current contract owner.

#### pendingOwner

```solidity
function pendingOwner() external view returns (address);
```

Return the `address` of the pending owner, of a ownership transfer, that was initiated with `transferOwnership(address)`. MUST be `address(0)` if no ownership transfer is in progress.

MUST be set when transferring ownership of the contract via `transferOwnership(address)` to a new `address`.

SHOULD be cleared once the [`pendingOwner`](#pendingowner) has claim ownership of the contract.


#### transferOwnership

```solidity
function transferOwnership(address newOwner) external;
```

Sets the `newOwner` as `pendingOwner`.

MUST be called only by `owner()`.

The `newOwner` MUST NOT be the contract itself `address(this)`

#### acceptOwnership

```solidity
function acceptOwnership() external;
```

Allow an `address` to become the new owner of the contract. MUST only be called by the pending owner.

MUST be called after `transferOwnership` by the current `pendingOwner` to finalize the ownership transfer.

MUST emit a [`OwnershipTransferred`](https://eips.ethereum.org/EIPS/eip-173#specification) event once the new owner has claimed ownership of the contract.

#### renounceOwnership

```solidity
function renounceOwnership() public;
```

Leaves the contract without an owner. Once ownership of the contract is renounced, it MUST NOT be possible to call the functions restricted to the owner only.

Since renouncing ownership is a sensitive operation, it SHOULD be done as a two step process by calling  `renounceOwnership(..)` twice. First to initiate the process, second as a confirmation.

*Requirements:*

- MUST be called only by the `owner()` only.
- The second call MUST happen AFTER the delay of 100 blocks and within the next 100 blocks from the first `renounceOwnership(..)` call.
- If the 200 block has passed, the `renounceOwnership(..)` call phase SHOULD reset the process, and a new one will be initated.

MUST emit a [`RenounceOwnershipInitiated`](#renounceownershipinitiated) event on the first `renounceOwnership(..)` call.
MUST emit [`OwnershipTransferred`](https://eips.ethereum.org/EIPS/eip-173#specification) event after successfully renouncing the ownership.

### Events

#### OwnershipTransferStarted

```solidity
event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
```

MUST be emitted when the process of transferring owhership of the contract is initiated.

_Values:_

- `previousOwner` Address of the current owner of the conract that implements LSP14.

- `newOwner` Address that will receive ownership of the contract that implemets LSP14. 

#### RenounceOwnershipInitiated

```solidity
event RenounceOwnershipInitiated();
```

MUST be emitted when the process of renouncing ownership of the contract is initiated.

### Hooks

Every contract that supports the LSP14 standard SHOULD implement these hooks:

#### _notifyUniversalReceiver

```solidity
function _notifyUniversalReceiver(
    address universalReceiver,
    bytes32 typeId,
    bytes memory data
)
```

Calls the `universalReceiver(..)` function on the `universalReceiver` address in the following situations:

- When transferring ownership to the new owner, if the new owner address supports LSP1 InterfaceID, with the parameters below:

    - `typeId`: keccak256('LSP14OwnershipTransferStarted')
    - `data`: TBD

- When accepting ownership by the new owner, if the old owner address supports LSP1 InterfaceID, with the parameters below:

    - `typeId`: keccak256('LSP14OwnershipTransferred_SenderNotification')
    - `data`: TBD

- When accepting ownership by the new owner, if the new owner address supports LSP1 InterfaceID, with the parameters below:

    - `typeId`: keccak256('LSP14OwnershipTransferred_RecipientNotification')
    - `data`: TBD


## Interface Cheat Sheet

```solidity
interface ILSP14  /* is ERC173 */ {
         

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event RenounceOwnershipInitiated();


    function owner() external view returns (address);
    
    function pendingOwner() external view returns (address);

    function transferOwnership(address newOwner) external; // onlyOwner

    function acceptOwnership() external;
    
    function renounceOwnership() external; // onlyOwner

}
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[LSP1-UniversalReceiver]: <./LSP-1-UniversalReceiver.md>
[LSP2-ERC725YJSONSchema]: <./LSP-2-ERC725YJSONSchema.md>
