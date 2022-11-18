---
lip: 15
title: TransactionRelayServiceAPI
author: Hugo Masclet <git@hugom.xyz>, Callum Grindle <callumgrindle@gmail.com>
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2022-10-05
---

## Simple Summary

A Transaction Relay Service API for consistency across all Transaction Relay Service providers.

## Abstract

The [LSP-6-KeyManager](./LSP-6-KeyManager.md) proposes an [`executeRelayCall()`](./LSP-6-KeyManager.md#executerelaycall) function. It allows anybody to execute `_calldata` payload on a set ERC725 X or Y smart contract, given they have a signed message from a valid executor. This opens the way to Transaction Relay Services which send transactions on behalf of a user to cover their gas costs. 

This document describes the API for a Transaction Relay Service.

## Motivation
Standardizing the Transaction Relay Service API enables applications to be compatible with all Transaction Relay Services which may be built, and avoids a situation where specific applications are only compatible with specific Transaction Relay Services. This is essential for an open marketplace of Transaction Relay Services where a user can select the service which best fits their needs.

## Specification

### API


#### POST `/execute`

Executes a signed transaction on behalf of a Universal Profile using `executeRelayCall()`.

##### Request body

```json
{
  "address": "0xBB645D97B0c7D101ca0d73131e521fe89B463BFD", // Address of the UP
  "transaction": {
    "abi": "0x7f23690c5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000596f357c6aa5a21984a83b7eef4cb0720ac1fcf5a45e9d84c653d97b71bbe89b7a728c386a697066733a2f2f516d624b43744b4d7573376741524470617744687a32506a4e36616f64346b69794e436851726d3451437858454b00000000000000",
    "signature": "0x43c958b1729586749169599d7e776f18afc6223c7da21107161477d291d497973b4fc50a724b1b2ab98f3f8cf1d5cdbbbdf3512e4fbfbdc39732229a15beb14a1b",
    "nonce": 1 // KeyManager nonce
  },
}
```

##### Response

```json
{
  "transactionHash": "0xBB645D97B0c7D101ca0d73131e521fe89B463BFD",
}
```

#### POST `/quota`

Returns the available quota left for a registered Universal Profile.

- `signature` is the result of signing a hash calculated as an EIP-712 hash where the message is keccak256(`address`, `timestamp`). 
- `address` is the controller address with permissions on the Universal Profile used to create the signature value. 
- `timestamp` represents the time the signature was created. Must be +/- 300 seconds from current time to be considered a valid request. Value should be `int`, `int256`, `uint` or `uint256`.

##### Request body

```json
{
  "address": "0xBB645D97B0c7D101ca0d73131e521fe89B463BFD",
  "timestamp": 1656408193,
  "signature": "0xf480c87a352d42e49112257cc6afab0ff8365bb769424bb42e79e78cd11debf24fd5665b03407d8c2ce994cf5d718031a51a657d4308f146740e17e15b9747ef1b"
}
```

##### Response

```json
{
  "quota": 1543091, // You have YYY left
  "unit": "gas", // could be "lyx", "transactionCount"
  "totalQuota": 5000000, // total gas for the month
  "resetDate": 1656408193
}
```

- `quota` shows available balance left in units defined by `unit`
- `unit` could be `gas`, `lyx` or `transactionCount` depending on the business model
- `totalQuota` reflects total limit. i.e. available + used quota since reset
- `resetDate` gives date that available quota will reset, e.g. a monthly allowance

> Quota systems could also use a Pay As You Go model, in which case totalQuota and resetData can be omitted


## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
