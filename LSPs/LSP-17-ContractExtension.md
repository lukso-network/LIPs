---
lip: 17
title: ContractExtension
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

This proposal defines two types of contracts, the extendable and the extensions contract. An extendable contract is a contract that in case of being called with a function that does not exist, it calls an extension contract ,through the fallback function, with the calldata received appended with the `msg.sender` and `msg.value` of the extendable contract as extra calldata.

The extendable contract should map function selectors (bytes4) to extensions (address) that implement these functions being called.

## Motivation

After deploying a contract, there is no possible way to integrate native functions into the bytecode of the deployed contract. This represents a limitation that smart contract have specially with smart contract based account that could evolve by time and needs to have specific function to support future usecases and standards.

The extensions added can be removed or replaced in any time in the future making the extendable contract highly customizable and able to suit any behavior needed. 

The contracts applying the extendable logic can re-use deployed extensions contract. Instead of mass deploying contracts to the blockchain with the same logic that are already existing on the blockchain, extensions contract can be re-used by extendable contract.


## LSP17Extendable Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

**LSP17-Extendable** interface id according to [ERC165]: `0xa918fa6b`.

_This `bytes4` interface id is calculated as the first 4 bytes of the keccak256 of the word "LSP17Extendable" since there is no public functions available._

Smart contracts implementing the LSP17Extendable standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support the LSP17Extendable interface id.


### Overview

Whenever a function is called on an extendable contract and the function does not exist, the fallback function of the extendable contract MUST call the function on the extension mapped using `CALL` opcode appended with extra 52 bytes of calldata as follows:

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

The [DataChanged] event MUST be emitted whenever an extension is added/changed/removed.

The LSP17ContractExtension do not enforce a specific way to store the extension address based on the bytes4 function selector. It could be an explicit mapping from function selectors to extensions, eg: `mapping(bytes4 => address)`.

If the extendable contract does not support ERC725Y, the [ExtensionChanged] event MUST be emitted whenever an extension is added/changed/removed.

### fallback Function

Here is an illustrative example of how the extendable contract's fallback function might be implemented:

```solidity

fallback() external payable {

    // If the msg.data is shorter than 4 bytes
    // do not check for an extension and return
    if (msg.data.length < 4) return;

    // If there is a function selector
    // Up to the extendable contract to implement
    // `_getExtension` function in custom way
    address extension = _getExtension(msg.sig);

    // if no extension was found, return
    if (extension == address(0)) return;

    // solhint-disable no-inline-assembly
    // if the extension was found, call the extension with the msg.data
    // appended with bytes20(address) and bytes32(msg.value)
    assembly {
        calldatacopy(0, 0, calldatasize())

        // The msg.sender address is shifted to the left by 12 bytes to remove the padding
        // Then the address without padding is stored right after the calldata
        mstore(calldatasize(), shl(96, caller()))

        // The msg.value is stored right after the calldata + msg.sender
        mstore(add(calldatasize(), 20), callvalue())

        // Add 52 bytes for the msg.sender and msg.value appended at the end of the calldata
        let success := call(gas(), extension, 0, 0, add(calldatasize(), 52), 0, 0)

        // Copy the returned data
        returndatacopy(0, 0, returndatasize())

        switch success
        // call returns 0 on failed calls
        case 0 {
            revert(0, returndatasize())
        }
        default {
            return(0, returndatasize())
        }
    }
}
```

### Events

#### ExtensionChanged

```solidity
event ExtensionChanged(bytes4 indexed functionSelector, address indexed extension);
```

MUST be emitted when an extension is added/changed/removed.

> In case the extendable contract supports [ERC725Y], there is no need to emit the ExtensionChanged event.



## LSP17Extension Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

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
