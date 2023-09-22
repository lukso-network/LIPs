---
lip: 17
title: Contract Extension
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-11-19
requires: ERC165
---

## Simple Summary

This standard describes a mechanism for adding additional functionality to a contract after it has been deployed, through the use of extensions.
 
## Abstract

This proposal defines two types of contracts:

- an extendable contract which functionalities are extended.
- an extension contract which contains the functionality that will be added to the extendable contract.

When the extendable contract is called with a function that is not part of its public interface, it can forward this call to an extension contract, through the use of its fallback function.

The extension contract function is able to access the original `msg.sender` and `msg.value` of the extendable contract by appending them to the calldata of the call to the extension.

The extendable contract SHOULD map function selectors to extension contract addresses that handle those functions.

## Motivation

After deploying a smart contract to the network, it is not possible to add new functionalities to it. This limitation is significant for smart contracts that aim to support a wider range of functionalities, especially those that may be standardized in the future.

Implementing a mechanism for attaching extensions to a specific contract not only makes the contract more extendable and able to support a wider range of functionalities over time, but it also enables the reusability of extensions across multiple contracts. This reduces the need for deploying multiple contracts with the same logic to the blockchain network, thus potentially decreasing chain congestion and reducing gas costs.

## LSP17Extendable Specification

**LSP17-Extendable** interface id according to [ERC165]: `0xa918fa6b`.

_This `bytes4` interface id is calculated as the first 4 bytes of the keccak256 of the word "LSP17Extendable" since there is no public functions available._

Smart contracts that adhere to the LSP17Extendable standard MUST include the `supportsInterface(..)` function, as specified in the [ERC165] standard, and MUST support the LSP17Extendable interfaceId.

They SHOULD also check whether the interface being queried is supported within the `supportsInterface(..)` extension, if it exists.

Whenever a function is called on an extendable contract and the function does not exist, the fallback function of the extendable contract MUST call the function on the extension mapped using the `CALL` opcode. The calldata MUST be appended with 52 extra bytes as follows:

- The `msg.sender` calling the extendable contract without any pad, MUST be 20 bytes.
- The `msg.value` received to the extendable contract, MUST be 32 bytes.

The standard does not enforce a specific method for mapping function selectors to the addresses of the extension contracts, nor does it require specific methods for setting and querying the addresses of the extensions.

As an example, a mapping of function selectors to extension contracts can be used, such as a `mapping(bytes4 => address)`. However, any other data structure can also be used to map function selectors to extension contract addresses.

If the contract implementing the LSP17 standard is an ERC725Y contract, the extension contracts COULD be stored under the following ERC725Y data key:

```json
{
    "name": "LSP17Extension:<bytes4>",
    "key": "0xcee78b4094da860110960000<bytes4>",
    "keyType": "Mapping",
    "valueType": "address",
    "valueContent": "Address"
}
```

The <bytes4\> is the `functionSelector` called on the account contract. For instance, for the selector `0xaabbccdd`, the data key above would be constructed as:

```
0xcee78b4094da860110960000aabbccdd00000000000000000000000000000000
```

Check [LSP2-ERC725YJSONSchema] to learn how to encode the data key, and the [**Mapping**](./LSP-2-ERC725YJSONSchema.md#mapping) section to learn the padding rules.

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

The design of this standard was inspired by [EIP-2535 Diamonds, Multi-Facet Proxy], which also proposes a way to add functionality to a smart contract through the use of facets (extensions). However, EIP-2535 uses the DELEGATECALL opcode to execute the function on the extension contract, allowing it to access the storage of the extendable contract.

This proposal, on the other hand, uses the CALL opcode to forward the function call to the extension contract. This design decision was made to enhance security by mitigating the risk of malicious actors exploiting the selfdestruct functionality or altering the storage of the extendable contract.

By appending the `msg.sender` and `msg.value` to the calldata when forwarding the function call from the extendable to the extension contract, this proposal allows the extension contract to know the address of the caller and the value associated with the call.

This design decision ensures that the extension contract can maintain context of the original call and allows the extension contract to make proper decisions based on the call context.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP17ContractExtension/) repository.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[EIP-2535 Diamonds, Multi-Facet Proxy]: <https://eips.ethereum.org/EIPS/eip-2535>
