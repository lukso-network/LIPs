---
lip: 17
title: Contract Extension
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-11-19
requires: ERC725Y
---


## Simple Summary

This standard describes a way to extend contract's functionalities even after deployment by forwarding the call to extension contracts.
 
## Abstract

This proposal defines two types of contracts:
- an extendable contract which functionalities are extended.
- an extension contract that extend the functionalities of the extendable contract.

When the extendable contract receives a call for a function not implemented in its public interface, it can forward this call to an extension contract. This forwarding occurs through the fallback function. The extension contract can then receive the calldata of the initial message call, appended with the `msg.sender` and the `msg.value` initially received.

The extendable contract should map function selectors (bytes4) to extension contract addresses that implement these functions being called.

## Motivation

After deploying a contract, there is no possible way to add new native functions into the bytecode of the deployed contract. This represents a limitation for smart contracts, for instance, with smart contract-based accounts that could evolve over time and need specific functions to support future usecases and standards.

The extensions added can be removed or replaced in any time in the future making the extendable contract highly customizable and able to suit any behavior needed. 

The contracts applying the extendable logic can re-use deployed extensions contract. Instead of mass deploying contracts to the blockchain with the same logic that are already existing on the blockchain, extensions contract can be re-used by extendable contract.


## LSP17Extendable Specification

**LSP17-Extendable** interface id according to [ERC165]: `0xa918fa6b`.

_This `bytes4` interface id is calculated as the first 4 bytes of the keccak256 of the word "LSP17Extendable" since there is no public functions available._

Smart contracts implementing the LSP17Extendable standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support the LSP17Extendable interface id.


### Overview

Whenever a function is called on an extendable contract and the function does not exist, the fallback function of the extendable contract MUST call the function on the extension mapped using the `CALL` opcode. The calldata MUST be appended with 52 extra bytes as follows:

- The `msg.sender` calling the extendable contract without any pad, MUST be 20 bytes.
- The `msg.value` received to the extendable contract, MUST be 32 bytes.


If the extendable contract supports [ERC725Y], the extension address MUST be stored under the data key attached below:

```json
{
    "name": "LSP17Extension:<bytes4>",
    "key": "0xcee78b4094da860110960000<bytes4>",
    "keyType": "Mapping",
    "valueType": "address",
    "valueContent": "Address"
}
```

> <bytes4\> is the `functionSelector` called on the account contract. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

The [DataChanged] event MUST be emitted whenever an extension is added/changed/removed.

The LSP17ContractExtension does not enforce a specific way to store the extension address based on the bytes4 function selector. As an example, a mapping from function selectors to extensions, (eg: `mapping(bytes4 => address)`) can be used, but any other data structure can be used to map function selector to extension contract addresses.

If the extendable contract does not support ERC725Y, the [ExtensionChanged] event MUST be emitted whenever an extension is added/changed/removed.

### Events

#### ExtensionChanged

```solidity
event ExtensionChanged(bytes4 indexed functionSelector, address indexed extension);
```

MUST be emitted when an extension is added/changed/removed.

> In case the extendable contract supports [ERC725Y], there is no need to emit the ExtensionChanged event.



## LSP17Extension Specification

**LSP17-Extension** interface id according to [ERC165]: `0xcee78b40`.

_This `bytes4` interface id is calculated as the first 4 bytes of the keccak256 of the word "LSP17Extension" since there is no public functions available._

Smart contracts implementing the LSP17Extension standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support the LSP17Extension interface id.


### Overview

Normally, some contract functions operates on validation of `msg.sender` and `msg.value` which are accessibe using global variables in solidity. Given the fact that the extendable contract will call the extension using the [CALL] opcode, the `msg.sender` on the extension contract will be the address of the extendable contract. The `msg.sender` of the extendable contract and the `msg.value` sent to the extendable contract will be appended as extra calldata sent to the extension contract and can be retreived using these functions:

```solidity
function _extendableMsgSender() internal view virtual returns (address) {
    return address(bytes20(msg.data[msg.data.length - 52:msg.data.length - 32]));
}
```

```solidity
function _extendableMsgValue() internal view virtual returns (uint256) {
    return uint256(bytes32(msg.data[msg.data.length - 32:]));
}
```

The original calldata sent to the extendable contract can be retreived using this function:

```solidity
function _extendableMsgData() internal view virtual returns (bytes memory) {
    return msg.data[:msg.data.length - 52];
}
```

The validation mechanism should be diffferent for extensions, and depend on these variables not on the `msg.sender` and `msg.value` globally accessible from the extension.


## Security Considerations

A function selector clash can occurs when two different function signatures hash to the same four-byte hash. Users needs to take extra care to avoid adding functions that map to a function selector already existing. 

## Rationale



## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP17ContractExtension/) repository.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[LSP1-UniversalReceiver]: <./LSP-1-UniversalReceiver.md>
[LSP2-ERC725YJSONSchema]: <./LSP-2-ERC725YJSONSchema.md>
