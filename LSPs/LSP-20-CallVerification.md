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

The `lsp20VerifyCall(..)` and `lsp20VerifyCallResult(..)` functions work in tandem to verify certain conditions before and after the execution of a function within the same transaction. To optimize gas costs and improve efficiency, the `callHash` parameter is introduced in the `lsp20VerifyCallResult(..)` function.

`lsp20VerifyCall(..)` takes the `caller`, `value`, and `data` as parameters and is invoked before the execution of the targeted function. Based on the return value of this function, it is determined whether `lsp20VerifyCallResult(..)` will run.

Instead of passing the same parameters (caller, value, data) along with the result of the executed function to `lsp20VerifyCallResult(..)`, the `callHash` parameter is used. The `callHash` is the keccak256 hash of the concatenated `lsp20VerifyCall(..)` parameters. Since both functions are invoked in the same transaction, a user can hash these parameters in `lsp20VerifyCall(..)` and store them under the hash. Later, the stored values can be retrieved using the `callHash` provided in `lsp20VerifyCallResult(..)`.

This approach has been adopted because passing the same parameters again would be expensive in terms of gas costs, and it's not always necessary for the user to access these parameters in `lsp20VerifyCallResult(..)`. If a user needs to use these parameters, they should store them in the contract storage during the `lsp20VerifyCall(..)` invocation.

Example: Reentrancy Check

In a case where the parameters are not relevant for `lsp20VerifyCallResult(..)`, such as checking for reentrancy, the first `lsp20VerifyCall(..)` function will be checking for reentrancy and will set the reentrancy flag to true. Then, `lsp20VerifyCallResult(..)` can simply set the reentrancy flag back to false without needing access to the original parameters.

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

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[lukso-network/lsp-smart-contracts]: <https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/>