---
lip: 26
title: Simple Following System
author: Fabian Vogelsteller <fabian@lukso.network>, Kat Banas <kat@universaleverything.io>
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2024-06-29
requires: ERC165, ERC725Y, LSP1
---

## Simple Summary

This standard describes a [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data key that lists addresses, which the the contract follows. This can mainly be used for [ERC725Account](./LSP-0-ERC725Account.md) profiles, but also to describe other types of smart contracts following each other.

## Abstract

The array data key describes a list of addresses the contract is following, like other [ERC725Account](./LSP-0-ERC725Account.md) profiles. Apps can use this data to curate a profiles home page based on the profiles, protocols and other smart contracts it is following.

To create a list of followers for a certain profile or smart contract indexing services are required, which scan all following data changed event and build up complex follower graphs.

## Motivation

With on chain profiles, there is a need for a simple follower system, that allows apps to curate home screens and content for profiles. While this follower relation can also be used for more complex social systems as basis.

Storing the accounts that a profile or smart contract is intersted in keeps that information in the control of the user, or owner of the smart contract (should one exists) and allows apps to read that data.

## Specification

Every contract that supports the follower standard SHOULD add the following [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data keys:

### ERC725Y Data Keys


#### LSP26Following[]

Contains list of addresses that the smart contract is following.

```json
{
  "name": "LSP26Following[]",
  "key": "0x9014dcb856a4ff0ef13272ad445bd659deeedeca41220b63da2ad6099e785aaf",
  "keyType": "Array",
  "valueType": "address",
  "valueContent": "Address"
}
```


## Rationale

Adding a list of addresses that are followed to a smart contract can be used in various ways to create more social and engaging user interfaces. This is especially relevant for universal profiles, but not limited to.

This data key is mainly used as a means to allow your followers to be taken from one app to another. What experiences and results this will have depends on the respective apps and how they want to use that information.

## Implementation


ERC725Y VerifiableURI Schema `LSP26Following`:

```json
[
  {
    "name": "LSP26Following[]",
    "key": "0x9014dcb856a4ff0ef13272ad445bd659deeedeca41220b63da2ad6099e785aaf",
    "keyType": "Array",
    "valueType": "address",
    "valueContent": "Address"
  }
]
```

### LSP1 Hooks:

The follower COULD choose to inform the receiving profile of the following action by calling the [universalReceiver(...)] function on the followed smart contract (in case it exists) with the parameters below:

`typeId`: `keccak256('LSP26_FollowNotification')` > `0x386072cc5a50xaf96ff3c56c159effba9b1c5f5ae938b7814a3fd73ed46ffcadbdecf47e5c6c48e61263b434c722725f21031cd06e7c552cfaa06db5de8a320dbc`
`data`: The `address` of the follower.


## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
