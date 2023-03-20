---
lip: 20
title: Call Verification
author: skimaHarvey
discussions-to:
status: Draft
type: LSP
created: 2023-03-15
requires: 
---

## Simple Summary

This standard introduces a mechanism for delegating the verification of a function call to another contract.
 
## Abstract

The Call Verification standard introduces a way for a smart contracts to delegate the conditions or requirements needed to call a specific function to another smart contract. 

This approach offers increased flexibility, where the call requirements can be checked before or/and after the execution of the function being called on another contract.

## Motivation

In certain situations, a smart contract may need to modify the conditions or requirements for calling a specific function. These requirements might be complex or subject to change, making them difficult to manage within the same contract.

Delegating the function call requirements to another smart contract enables a more dynamic and adaptable approach. This makes it easier to update, modify, or enhance the requirements without affecting the primary contract's functionality. The Call Verification standard aims to provide a solution that allows contracts to be more versatile and adaptable in response to changing conditions or requirements.


## Specification

**LSP20-CallVerification** interface id according to [ERC165]: `0x480c0ec2`.

### Methods

Smart contracts implementing the LSP20 standard SHOULD implement both of the functions listed below:

#### lsp20VerifyCall

```solidity
function lsp20VerifyCall(address caller, uint256 value, bytes memory receivedCalldata) external returns (bytes4 magicValue);
```

MUST return the first 3 bytes of `lsp20VerifyCall(..)` function selector if the call to the function is allowed, concatenated with a byte that determines if the `lsp20VerifyCallResult(..)` function should be called after the original function call. 

The byte that invokes the `lsp20VerifyCallResult(..)` function is strictly `0x01`.

_Parameters:_

- `caller`: The address who called the function on the contract delegating the verification mechanism.
- `value`:  The value sent by the caller to the function called on the contract delegating the verification mechanism.
- `receivedCalldata`: The calldata sent by the caller to the contract delegating the verification mechanism.


_Returns:_ `magicValue` , the magic value determining if the verification succeeded or not.


#### lsp20VerifyCallResult

```solidity
function lsp20VerifyCallResult(bytes32 callHash, bytes memory callResult) external returns (bytes4 magicValue);
```

MUST return the `lsp20VerifyCallResult(..)` function selector if the call to the function is allowed.

_Parameters:_

- `callHash`: The keccak256 of the parameters of `lsp20VerifyCall(..)` parameters packed-encoded (concatened).
- `callResult`: The result of the function being called on the contract delegating the verification mechanism.

_Returns:_ `magicValue` , the magic value determining if the verification succeeded or not.


## Rationale

TBD

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts] repository.

## Interface Cheat Sheet

```solidity
interface ILSP20  /* is ERC165 */ {

  function lsp20VerifyCall(address caller, uint256 value, bytes memory receivedCalldata) external returns (bytes4 magicValue);

  function lsp20VerifyCallResult(bytes32 callHash, bytes memory callResult) external returns (bytes4);

}
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[lukso-network/lsp-smart-contracts]: <https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/>