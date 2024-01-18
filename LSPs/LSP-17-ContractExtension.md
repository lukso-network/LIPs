---
lip: 17
title: Contract Extension
author: Yamen Merhi <@YamenMerhi>
discussions-to: https://discord.gg/E2rJPP4
status: Last Call
type: LSP
created: 2021-11-19
requires: ERC165
---

## Simple Summary

This standard describes a mechanism for adding additional functionality to a contract after it has been deployed, through the use of extensions.

## Abstract

This proposal introduces two contract types:

- **Extendable Contract:** A contract whose functionalities are extended.
- **Extension Contract:** A contract containing the additional functionalities that could be added to an extendable contract.

When the extendable contract receives a call for a function that is not part of its public interface, it forwards this call to an extension contract using its fallback function. The extension contract can access the original `msg.sender` and `msg.value` from the extendable contract by appending them to the calldata.

The extendable contract should map function selectors to addresses of extension contracts handling those functions.

## Motivation

After deploying a smart contract to the network, it is not possible to add new functionalities to it. This limitation is significant for smart contracts that aim to support a wider range of functionalities, especially those that may be standardized in the future.

Implementing a mechanism for attaching extensions to a specific contract not only makes the contract more extendable and able to support a wider range of functionalities over time, but it also enables the reusability of extensions across multiple contracts. This reduces the need for deploying multiple contracts with the same logic to the blockchain network, thus potentially decreasing chain congestion and reducing gas costs.

## LSP17Extendable Specification

### ERC165 Interface ID

**LSP17-Extendable** interface id according to [ERC165]: `0xa918fa6b`.

_This `bytes4` interface id is calculated as the first 4 bytes of the keccak256 of the word "LSP17Extendable" since there is no public functions available._

Smart contracts that adhere to the LSP17Extendable standard MUST include the `supportsInterface(..)` function, as specified in the [ERC165] standard, and MUST support the LSP17Extendable interfaceId.

### Behavior

#### Storing Extensions

The standard offers flexibility in how extensions are mapped and stored. It does not enforce a specific method for mapping function selectors to the addresses of extension contracts, nor does it require a specific method for setting and retrieving these addresses. This flexibility allows developers to choose the most suitable approach for their specific use case.

**Example of a Simple Mapping Approach**

A straightforward way to implement this mapping is through a simple mapping data type, and a simple function to set the address of the extension to the function selector. For instance:

```solidity
mapping (bytes4 => address) extensionStorage;

function setExtension(bytes4 functionSelector, address extension) {
  extensionStorage[functionSelector] = extension;
}
```

**Storing Extensions in ERC725Y Storage**

Contracts that conform to the ERC725Y standard COULD use an alternative approach to store extension information in the ERC725Y storage. The ERC725Y storage is a mapping from bytes32 to bytes, and the extension information can be structured as follows:

```json
{
  "name": "LSP17Extension:<bytes4>",
  "key": "0xcee78b4094da860110960000<bytes4>",
  "keyType": "Mapping",
  "valueType": "address",
  "valueContent": "Address"
}
```

In this structure, <bytes4> represents the function selector of the contract. For a specific function selector, such as 0xaabbccdd, the data key would be constructed as follows:

```js
0xcee78b4094da860110960000aabbccdd00000000000000000000000000000000;
```

To add an extension, users can call `setData(bytes32 dataKey, bytes dataValue)` with the data key representing the function selector and the data value being the address of the extension.

```js
dataKey: 0xcee78b4094da860110960000aabbccdd00000000000000000000000000000000
dataValue: [address of the extension]
```

This approach leverages the ERC725Y standard's key-value storage mechanism to maintain a mapping of function selectors to extension addresses, providing a standardized and interoperable method for managing extensions in contracts that support ERC725Y.

#### Calling Extensions

Whenever a function is called on an extendable contract and the function does not exist, the fallback function of the extendable contract MUST call the function on the extension mapped using the `CALL` opcode.

The calldata MUST be appended with 52 extra bytes as follows:

- The `msg.sender` calling the extendable contract without any pad, MUST be 20 bytes.
- The `msg.value` received to the extendable contract, MUST be uint256.

In case where the function selector does not correspond to a mapped extension within the extendable contract, the call SHOULD revert following the typical response observed when an a non existing function is called on a contract.

#### Sending Value to the Extensions

The standard does not dictate a mandatory approach regarding the handling of value (native tokens like LYX) sent along with a call to a function in an extendable contract. Specifically, it does not enforce whether this value should be forwarded to the extension contract or retained within the extendable contract. This decision is left to the discretion of each contract's implementation.

Contracts that conform to the ERC725Y standard COULD use a boolean indicator to specify the intended behavior for forwarding value. The structure for storing extension contracts and this indicator in the ERC725Y standard is as follows:

```json
{
  "name": "LSP17Extension:<bytes4>",
  "key": "0xcee78b4094da860110960000<bytes4>",
  "keyType": "Mapping",
  "valueType": "(address, bool)",
  "valueContent": "(Address, Boolean)"
}
```

In this data structure:

<bytes4> represents the function selector called on the account contract. For instance, for the selector `0xaabbccdd`, the data key would be:

```js
0xcee78b4094da860110960000aabbccdd00000000000000000000000000000000;
```

The boolean at the end of the data structure is utilized to indicate whether the value received by the extendable contract should be forwarded to the extension or remain within the extendable contract.

For example, if this boolean is set to true (represented as a `0x01` hex byte), it indicates that the value received should be forwarded to the extension:

```js
        address of the extension
  vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
0xcafecafecafecafecafecafecafecafecafecafe01
                                          ^^
                                         true
```

> See [LSP2-ERC725YJSONSchema] to learn how to encode the data key, and the [**Mapping**](./LSP-2-ERC725YJSONSchema.md#mapping) section to learn the padding rules.

#### Supporting InterfaceIds

In extendable contracts that implement the ERC165 standard, the `supportsInterface` function should be designed to additionally check for extended interfaceIds. This means that beyond the contract's native supported interfaceId, the function should also check support of extended interfaceIds.

The `supportsInterface` function should call the `supportsInterface` function on the extension mapped to its function selector and return true or false based on the result.

## LSP17Extension Specification

**LSP17-Extension** interface id according to [ERC165]: `0xcee78b40`.

_This `bytes4` interface id is calculated as the first 4 bytes of the keccak256 of the word "LSP17Extension" since there is no public functions available._

Smart contracts that adhere to the LSP17Extension standard MUST include the `supportsInterface(..)` function, as specified in the [ERC165] standard, and MUST support the LSP17Extension interfaceId.

### Overview

Normally, contract functions use `msg.sender` and `msg.value` global variables for validation in Solidity. However, when an extendable contract calls an extension using the CALL opcode, the `msg.sender` on the extension contract will always be the address of the extendable contract.

To access the original `msg.sender` and `msg.value` sent to the extendable contract, the extendable contract will append them as extra calldata and extension contract can use the following functions to retrieve them within the extension:

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

The original calldata sent to the extendable contract can be retrieved using this function:

```solidity
function _extendableMsgData() internal view virtual returns (bytes memory) {
    return msg.data[:msg.data.length - 52];
}
```

If a validation mechanism exists in the extension contract, it should depend on the `_extendableMsgSender()`, `_extendableMsgValue()` or `_extendableMsgData()` functions instead of the `msg.sender` and `msg.value` global variables, as anyone can call the extendable contract and trigger a call to the extensions.

## Security Considerations

A function selector clash can occur when two different function signatures hash to the same four-byte hash. Users need to take extra care to avoid adding functions that map to a function selector already existing.

## Rationale

### CALL vs DELEGATECALL

The design of this standard was inspired by [EIP-2535 Diamonds, Multi-Facet Proxy], which also proposes a way to add functionality to a smart contract through the use of facets (extensions). However, EIP-2535 uses the DELEGATECALL opcode to execute the function on the extension contract, allowing it to access the storage of the extendable contract.

This proposal, on the other hand, uses the CALL opcode to forward the function call to the extension contract. This design decision was made to enhance security by mitigating the risk of malicious actors exploiting the selfdestruct functionality or altering the storage of the extendable contract.

### Accessing Caller's information

By appending the `msg.sender` and `msg.value` to the calldata when forwarding the function call from the extendable to the extension contract, this proposal allows the extension contract to know the address of the caller and the value associated with the call.

This design decision ensures that the extension contract can maintain context of the original call and allows the extension contract to make proper decisions based on the call context.

### Extending InterfaceIds

In addition to adding new functionalities, it is crucial to extend the interfaceIds of a contract as many contracts check for the support of an interfaceId of a standard before invoking its functions. Therefore, simply extending the functions of a contract is not sufficient.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP17ContractExtension/) repository.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: https://eips.ethereum.org/EIPS/eip-165
[EIP-2535 Diamonds, Multi-Facet Proxy]: https://eips.ethereum.org/EIPS/eip-2535
