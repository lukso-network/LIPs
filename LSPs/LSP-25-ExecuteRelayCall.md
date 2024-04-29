---
lip: 25
title: Execute Relay Call
author: Jean Cavallera (@CJ42)
discussions-to: <URL>
status: Draft
type: LSP
created: 2023-08-09
requires: ERC165
---

**Table of Content**

- [Simple Summary](#simple-summary)
- [Abstract](#abstract)
- [Motivation](#motivation)
- [Specification](#specification)
  - [Methods](#methods)
    - [getNonce](#getnonce)
    - [executeRelayCall](#executerelaycall)
    - [executeRelayCallBatch](#executerelaycallbatch)
  - [Signature Format](#signature-format)
  - [Multi-Channel Nonces](#multi-channel-nonces)
    - [What are multi-channel nonces?](#what-are-multi-channel-nonces)
    - [Problem of Sequential Nonces](#problem-of-sequential-nonces)
    - [Benefits of multi-channel nonces](#benefits-of-multi-channel-nonces)
    - [How nonces are represented across channels?](#how-nonces-are-represented-across-channels)
  - [Rationale](#rationale)
- [Implementation](#implementation)
- [Interface Cheat Sheet](#interface-cheat-sheet)
- [Copyright](#copyright)

# Simple Summary

This standard describes an interface and a signature scheme that can be used to integrate meta-transactions (transactions where users do not pay for the gas) inside a smart contract.

# Abstract

LSP25 introduces a framework for implementing meta-transactions within smart contracts, enabling users to interact with contracts without needing to pay gas fees themselves. This standard is especially useful in various contexts, such as Universal Profiles, token transfers, NFTs, and voting systems, where delegates can execute transactions on behalf of users. By standardizing the interface for meta-transactions, LSP 25 facilitates gas-less transactions across applications like digital marketplaces or Universal Profiles, easing the onboarding process for new users who may not hold native tokens.

The key features of LSP 25 include functions to get nonces for transaction signing and to execute single or batched relay calls with signatures. This allows transactions to be executed on behalf of users, with the gas fees covered by another party. A notable innovation introduced by LSP 25 is the concept of multi-channel nonces, which addresses the limitations of sequential nonces and allows for out-of-order execution of transactions. This flexibility benefits both users and relayers, providing a more efficient and user-friendly transaction experience.

By adopting LSP 25, developers can simplify user interactions with their dApps, enhancing the user experience and potentially increasing adoption. The standard's design decisions, such as the exclusion of gas parameters in the signature format to minimize complexity, reflect a balance between usability and security considerations.

Meta transactions in web3 are used in many different context. From interacting with Universal Profiles to transferring tokens and NFTs to voting systems, where delegates can submit transactions on behalf of other users and pay for the gas cost.

# Motivation

By having a common smart contract interface, applications and protocols can implement the LSP25 Execute Relay Call standard to start implementing gas-less transaction. This can be beneficial for protocols and applications like Digital Marketplaces or Universal Profile that want to onboard new users without requiring users to hold native tokens.

# Specification

**LSP25-ExecuteRelayCall** interface id according to [ERC165]: `0x5ac79908`

Smart contracts implementing the LSP25 standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support the [ERC165] and LSP25 interface ids.

## Methods

### getNonce

```solidity
function getNonce(address signer, uint128 channel) external view returns (uint256)
```

Returns the latest nonce for a signer on a specific channel. A signer can choose a channel number arbitrarily and use this nonce to sign a calldata payload that can be executed as a meta-transaction by any address via [executeRelayCall](#executeRelayCall) function.

_Parameters:_

- `signer`: the address of the signer of the transaction.
- `channel` : the channel which the signer wants to use for executing the transaction.

_Returns:_ `uint256` , the current nonce.

Calldata payloads signed with incremental nonces on the same channel for the same signer are executed in order. e.g, in channel X, the second calldata payload signed with the second nonce will not be successfully executed until the first calldata payload signed with the first nonce has been executed.

Calldata payloads signed with nonces on different channels are executed independently from each other, regardless of when they got executed or if they got executed successfully or not. e.g, the calldata payload signed with the fourth nonce on channel X can be successfully executed even if the calldata payload signed with the first nonce of channel Y:

- was executed before.
- was executed and reverted.

> X and Y can be any arbitrary number between 0 and 2^128.

Read [what are multi-channel nonces](#what-are-multi-channel-nonces).

### executeRelayCall

```solidity
function executeRelayCall(
    bytes memory signature,
    uint256 nonce,
    uint256 validityTimestamps,
    bytes memory payload
)
    external
    payable
    returns (bytes memory)
```

Allows anybody to execute a calldata `payload` given they have a valid signature from a signer. The signature MUST be formed according to the [LSP25 Signature specification format](#signature-format).

_Parameters:_

- `signature`: A 65 bytes long ethereum signature.
- `nonce`: MUST be the nonce of the address that signed the message. This can be obtained via the `getNonce(address address, uint256 channel)` function.
- `validityTimestamps`: Two `uint128` timestamps concatenated together. The first timestamp determines from when the calldata payload can be executed, and the second timestamp determines a deadline after which the payload is no longer valid. If `validityTimestamps` is `0`, the payload is valid indefinitely at any point in time and the checks for the timestamps are skipped.
  payload can be executed, the second timestamp determines a deadlines after which the calldata payload is not valid anymore. If validityTimestamps is `0`, the calldata payload is valid at indefinitely at any point in time and the checks for the timestamps are skipped.
- `payload`: The abi-encoded function call to be executed. This could be a function to be called on the current contract implementing LSP25 or an external target contract.

_Returns:_ `bytes`. If the call succeeded, these `bytes` MUST be the returned data as abi-decoded bytes of the function call defined by the `payload` parameter. Otherwise revert with a reason-string.

_Requirements:_

- The address recovered from the signature and the digest signed MUST have **permission(s)** for the action(s) being executed. Check [Permissions](#permissions) to know more.
- The nonce passed to the function MUST be a valid nonce according to the [multi-channel nonce](#what-are-multi-channel-nonces) section.
- MUST send the value passed by the caller to the call on the linked target contract.

See the section [**Signature Format**](#signature-format) below to learn how to sign LSP25 Execute Relay Call meta-transactions.

> **Note:** Non payable functions will revert in case of calling them and passing value along the call.

### executeRelayCallBatch

```solidity
function executeRelayCallBatch(
    bytes[] memory signatures,
    uint256[] memory nonces,
    uint256[] memory validityTimestamps,
    uint256[] memory values,
    bytes[] memory payloads
)
    external
    payable
    returns (bytes[] memory)
```

Allows anybody to execute a batch of calldata `payloads` given they have valid signatures from signers. Each signature MUST be formed according to the [LSP25 Signature specification format](#signature-format).

_Parameters:_

- `signatures`: An array of bytes65 ethereum signature.
- `nonce`: An array of nonces from the address/es that signed the digests. This can be obtained via the `getNonce(address address, uint256 channel)` function.
- `values`: An array of native token amounts to transfer to the linked [target](#target) contract alongside the call on each iteration.
- `validityTimestamps`: An array of `uint256` formed of Two `uint128` timestamps concatenated, the first timestamp determines from when the calldata payload can be executed, the second timestamp delimits the end of the validity of the calldata payload. If validityTimestamps is `0`, the checks of the timestamps are skipped.
- `payloads`: An array of calldata payloads to be executed on the linked [target](#target) contract on each iteration.

_Returns:_ `bytes[]` , an array of returned as abi-decoded array of `bytes[]` of the linked target contract, if the calls succeeded, otherwise revert with a reason-string.

_Requirements:_

- MUST comply to the requirements of the [`executeRelayCall(bytes,uint256,bytes)`](#executerelaycall) function.
- Each array parameters provided to the function MUST have the same length.
- The sum of each element of the `values` array MUST be equal to the total value sent to the function.
- Each nonces passed to the function MUST be a valid nonce according to the [multi-channel nonce](#what-are-multi-channel-nonces) section.
- MUST send the value passed by the caller to the call on the linked target contract.

## Signature Format

In order to submit relay calls successfully, users MUST sign the relay calls to be executed according to the specification below.

The hash digest that MUST be signed MUST be constructed according to the [version 0 of EIP-191] with the following format:

```
0x19 <0x00> <Implementation address> <LSP25_VERSION> <chainId> <nonce> <validityTimestamps> <value> <calldata>
```

The table below breakdown each parameters in details:

| Value                    | Type      | Description                                                                                                                                                                                                                                                                |
| ------------------------ | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `0x19`                   | `bytes1`  | byte intended to ensure that the `signed_data` is not valid RLP.                                                                                                                                                                                                           |
| `0x00`                   | `bytes1`  | version `0` of [EIP191].                                                                                                                                                                                                                                                   |
| `Implementation address` | `address` | The address of the contract implementing LSP25 that will execute the calldata.                                                                                                                                                                                             |
| `LSP25_VERSION`          | `uint256` | Version relative to the LSP25ExecuteRelayCall standard defined equal to `25`.                                                                                                                                                                                              |
| `chainId`                | `uint256` | The chainId of the blockchain where the Key Manager is deployed.                                                                                                                                                                                                           |
| `nonce`                  | `uint256` | The nonce to sign the calldata with.                                                                                                                                                                                                                                       |
| `validityTimestamps`     | `uint256` | Two `uint128` timestamps concatenated, the first timestamp determines from when the calldata payload can be executed, the second timestamp delimits the end of the validity of the calldata payload. If validityTimestamps is 0, the checks of the timestamps are skipped. |
| `value`                  | `uint256` | The amount of native token to transfer to the linked target contract alongside the call.                                                                                                                                                                                   |
| `calldata`               | `bytes`   | The abi-encoded function call to be executed.                                                                                                                                                                                                                              |

These parameters **MUST be packed encoded** (not zero padded, leading `0`s are removed), then hashed with keccak256 to produce the hash digest.

For signing, users should apply the same steps and sign the final hash obtained at the end.

## Multi-Channel Nonces

### What are multi-channel nonces?

This concept was taken from <https://github.com/amxx/permit#out-of-order-execution>.

Using nonces prevent old signed transactions from being replayed again (replay attacks). A nonce is an arbitrary number that can be used just once in a transaction.

### Problem of Sequential Nonces

With native transactions, nonces are strictly sequential. This means that messages with sequential nonces must be executed in order. For instance, in order for message number 4 to be executed, it must wait for message number 3 to complete.

However, **sequential nonces come with the following limitation**:

Some users may want to sign multiple message, allowing the transfer of different assets to different recipients. In that case, the recipient want to be able to use / transfer their assets whenever they want, and will certainly not want to wait on anyone before signing another transaction.

This is where **out-of-order execution** comes in.

### Benefits of multi-channel nonces

Out-of-order execution is achieved by using multiple independent channels. Each channel's nonce behaves as expected, but different channels are independent. This means that messages 2, 3, and 4 of `channel 0` must be executed sequentially, but message 3 of channel 1 is independent, and only depends on message 2 of `channel 1`.

The benefit is that the signer key can determine for which channel to sign the nonces. Relay services will have to understand the channel the signer choose and execute the transactions of each channel in the right order, to prevent failing transactions.

### How nonces are represented across channels?

The LSP25 standard allows out-of-order execution of messages by using nonces through multiple channels.

Nonces are represented as `uint256` from the concatenation of two `uint128` : the `channelId` and the `nonceId`.

- left most 128 bits : `channelId`
- right most 128 bits: `nonceId`

![multi-channel-nonce](https://user-images.githubusercontent.com/31145285/133292580-42817340-104e-48c5-832b-533842b98d26.jpg)

<p align="center"><i> Example of multi channel nonce, where channelId = 5 and nonceId = 1 </i></p>

The current nonce can be queried using the function:

```solidity
function getNonce(address _address, uint256 _channel) public view returns (uint256)
```

Since the `channelId` represents the left-most 128 bits, using a minimal value like 1 will return a huge `nonce` number: `2**128` equal to `3402823669209384634633746074317682114`**`56`**.

After the signed transaction is executed the `nonceId` will be incremented by `+1`, this will increment the `nonce` by 1 as well because the nonceId represents the first 128 bits of the nonce so it will be `3402823669209384634633746074317682114`**`57`**.

```solidity
_nonces[signer][nonce >> 128]++
```

`nonce >> 128` represents the channel which the signer chose for executing the transaction. After looking up the nonce of the signer at that specific channel it will be incremented by 1 `++`.<br>

For sequential messages, users could use channel `0` and for out-of-order messages they could use channel `n`.

**Important:** It's up to the user to choose the channel that he wants to sign multiple sequential orders on it, not necessary `0`.

## Rationale

There are several factors that motivated the design of LSP25 Execute Relay Call to be developed as its own standard.

Firstly, the idea of meta transaction aims to simplify user transactions on the LUKSO network. Users can send payments and transact between each other without having to worry about gas fees. This simplifies the process of using the LUKSO network, which in turns increase and promote user adoption.

Secondly, gasless Meta-Transactions can assist in minimizing the cost of utilizing the LUKSO network, which is especially essential for low-budget users. This enables protocols and dApps building on LUKSO to offer a better experience for their users or customers.

Finally, by adopting a generic standard for meta transactions, any protocol or dApp can implement gas-less transactions by simply adopting the standard, without relying on custom built solution. This also improve inter-operability between contracts and protocols, since different contracts and different applications rely on the same standard and contract API/ABI to send execute relay calls (= meta transactions) between each others.

## Design decision

Several implementation of meta-transactions add the `gas` parameter in the data of the call to be signed. This is aimed to prevent gas griefing attacks, where a malicious relayer can manipulate the behaviour of the called contract by controlling the gas provided for the transaction.

In the LSP25 standard, the signature format does not require to include the supplied gas. The reasons for this design are the following:

- this add more complexity on the user or dApp interface side, requiring the user/interface to add more logic to provide the gas parameter and sign it.
- when using meta transactions, the user must trust the relayer in the first place, to allow the relayer (an address of a peer or a service) to execute signed transactions on its behalf.

However, not adding the gas parameter implies some considerations that applications that implement the LSP25 standard should be aware of:

- Not including the `gas` parameter allows the relayer to deternine the gas amount for the transaction.
- If the provided gas is insufficient, the entire transaction could revert, which is the expected behaviour.
- Implementations should be aware of the impact if the contract being called behaves differently based on the gas supplied. A malicious relayer could effectively control that behaviour by adjusting the specified gas when submitting the transaction to the network.

Implementations of the LSP25 standard can add the `gas` parameter in the `data` parameter of the signature format to mitigate these risks listed above.

# Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](#)

# Interface Cheat Sheet

```solidity
interface ILSP25 /* is ERC165 */  {

  function getNonce(address from, uint128 channelId) external view returns (uint256);

  function executeRelayCall(
    bytes calldata signature,
    uint256 nonce,
    uint256 validityTimestamps,
    bytes calldata payload
  )
    external
    payable
    returns (bytes memory);

  function executeRelayCallBatch(
    bytes[] calldata signatures,
    uint256[] calldata nonces,
    uint256[] calldata validityTimestamps,
    uint256[] calldata values,
    bytes[] calldata payloads
  )
    external
    payable
    returns (bytes[] memory);
}
```

# Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: https://eips.ethereum.org/EIPS/eip-165
[version 0 of EIP-191]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-191.md#version-0x00
[EIP191]: https://eips.ethereum.org/EIPS/eip-191
