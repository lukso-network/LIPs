---
lip: 26
title: Follower System
author: Fabian Vogelsteller <fabian@lukso.network>, Kat Banas <kat@universaleverything.io>
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2024-06-29
requires: ERC165, LSP1
---

## Simple Summary

This standard describes a blockchain smart contract registry that allows storing two lists of addresses:

1. A list of addresses that an address is following. (follows)
2. A list of addresses that follow an address. (followers)

This can be used primarily for smart contract accounts, such as [ERC725Account](./LSP-0-ERC725Account.md), but also for any smart contracts and EOAs.

## Abstract

The arrays describe two lists of addresses, follows and followers, primarily [ERC725Account](./LSP-0-ERC725Account.md) profiles. Apps can use this data to curate a profiles home page based on the profiles, protocols and other smart contracts it is following.

One can access the two distinctive lists of followers by using the functions [`getFollowsByIndex`](#getFollowsByIndex) & [`getFollowersByIndex`](#getFollowersByIndex). The two functions are built with pagination in mind.

Indexing services are not required to create the lists of followers, but can be used to ease the access to the information when huge amount of data is needed, e.g. to build up complex follower graphs.

## Motivation

With on chain profiles, there is a need for a simple follower system, that allows apps to curate home screens and content for profiles. While this follower relation can also be used for more complex social systems as basis.

Storing the addresses that a profile, smart contract or EOA is interested in keeps that information in the control of the user, or owner of the smart contract (should one exists) and allows apps to read that data.

## Specification

### Methods

#### follow

```solidity
function follow(address addr) external;
```

Follow a specific address.
Emits [`Follow`](#follow-1) event when following an address.

**LSP1 Hooks:**

- If the followed address supports [LSP1-UniversalReceiver] interface, SHOULD call the follower's [`universalReceiver(...)`] function with the default parameters below:

  - `typeId`: `keccak256('LSP26FollowerSystem_FollowNotification')` > `0x71e02f9f05bcd5816ec4f3134aa2e5a916669537ec6c77fe66ea595fabc2d51a`
  - `data`: The data sent SHOULD be packed encoded and contain the address that starts following.

#### followBatch

```solidity
function followBatch(address[] memory addresses) external;
```

Follow a list of addresses.
Emits [`Follow`](#follow-1) event when following each address in the list.

#### unfollow

```solidity
function unfollow(address addr) external;
```

Unfollow a specific address.
Emits [`Unfollow`](#Unfollow-1) event when unfollowing an address.

**LSP1 Hooks:**

- If the followed address supports [LSP1-UniversalReceiver] interface, SHOULD call the follower's [`universalReceiver(...)`] function with the default parameters below:

  - `typeId`: `keccak256('LSP26FollowerSystem_UnfollowNotification')` > `0x9d3c0b4012b69658977b099bdaa51eff0f0460f421fba96d15669506c00d1c4f`
  - `data`: The data sent SHOULD be packed encoded and contain the address that unfollows.

#### unfollowBatch

```solidity
function unfollowBatch(address[] memory addresses) external;
```

Unfollow a list of addresses.
Emits [`Unfollow`](#Unfollow-1) event when unfollowing each address in the list.

#### isFollowing

```solidity
function isFollowing(address follower, address addr) external view returns (bool);
```

Check if an address is following a specific address.

#### followerCount

```solidity
function followerCount(address addr) external view returns (uint256);
```

Get the number of followers for an address.

#### followingCount

```solidity
function followingCount(address addr) external view returns (uint256);
```

Get the number of addresses an address is following.

#### getFollowsByIndex

```solidity
function getFollowsByIndex(address addr, uint256 startIndex, uint256 endIndex) external view returns (address[] memory);
```

Get the list of addresses the given address is following within a specified range.

#### getFollowersByIndex

```solidity
function getFollowersByIndex(address addr, uint256 startIndex, uint256 endIndex) external view returns (address[] memory);
```

Get the list of addresses that follow an address within a specified range.

### Events

#### Follow

```solidity
event Follow(address follower, address addr);
```

MUST be emitted when following an address.

#### Unfollow

```solidity
event Unfollow(address unfollower, address addr);
```

MUST be emitted when unfollowing an address.

## Rationale

Adding a list of addresses that are followed to a smart contract can be used in various ways to create more social and engaging user interfaces. This is especially relevant for universal profiles, but not limited to.

Storing followers in a single decentralized registry allows followers to be taken from one app to another. What experiences and results this will have depends on the respective apps and how they want to use that information.

## Usage

Decentralized registry of followers

## Reference Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts] repository.

## Interface Cheat Sheet

```solidity
interface ILSP26 {

    event Follow(address follower, address addr);

    event Unfollow(address unfollower, address addr);

    function follow(address addr) external;

    function followBatch(address[] memory addresses) external;

    function unfollow(address addr) external;

    function unfollowBatch(address[] memory addresses) external;

    function isFollowing(address follower, address addr) external view returns (bool);

    function followerCount(address addr) external view returns (uint256);

    function followingCount(address addr) external view returns (uint256);

    function getFollowsByIndex(address addr, uint256 startIndex, uint256 endIndex) external view returns (address[] memory);

    function getFollowersByIndex(address addr, uint256 startIndex, uint256 endIndex) external view returns (address[] memory);

}
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[lsp1-universalreceiver]: ./LSP-1-UniversalReceiver.md
[lukso-network/lsp-smart-contracts]: https://github.com/lukso-network/lsp-smart-contracts/tree/develop/packages/lsp26-contracts/contracts/LSP26FollowerSystem.sol
