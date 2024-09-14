---
lip: 27
title: Token Bound Profile
author: Valentine Orga <valentineorga@gmail.com>, Tanto Defi <tandodefi@proton.me>
status: Draft
type: LSP
category: Core
created: 2024-09-14
requires: LSP0, LSP8
---

## Simple Summary

LIP-27 introduces a standard for creating Token Bound Profiles (TBA) using LSP8 Identifiable Digital Assets and Universal Profiles (LSP0) on the Lukso blockchain. This proposal allows each LSP8 token to be associated with a Universal Profile, enabling token-based ownership and interactions.

## Abstract

This proposal adapts the idea of EIP-6551 (Token Bound Profiles) for the Lukso ecosystem. Instead of using ERC721, LIP-27 leverages LSP8 tokens to bind each token to its own Universal Profile.

Key components of this proposal include:

- A Registry Contract that maps LSP8 token identifiers to their respective Universal Profiles.
- A modified Universal Profile contract that limits execution rights to the owner of the token.

## Motivation

With the rise of NFTs and tokenized assets, there is a growing need for tokens to have autonomous profiles that can hold assets, execute contracts, and interact with decentralized applications. LIP-27 provides a flexible and secure way to achieve this within the Lukso ecosystem by using LSP8 tokens and Universal Profiles.

This system enhances token utility by allowing each token to have its own programmable, self-sovereign profile while maintaining compatibility with Lukso's standards for identity (LSP0), and digital assets (LSP8).

## Specification

### Overview

The system outlined in this proposal has two main components:

- A singleton registry for token bound profiles
- A common implementation for token bound profiles. This implementation will not change the interface of the `LSP0-ERC725Account` standard but will modify it's logic to support LSP8 ownership.

### Registry

A Registry Contract is used to map each LSP8 token to a unique Universal Profile. This registry ensures that for each LSP8 token, there is a corresponding Universal Profile.

The registry must implement the following interface:

```typescript
interface ILSP27Registry {
    /**
     * @dev The registry must emit the LSP27ProfileCreated event upon successful profile creation.
     */
    event LSP27ProfileCreated(
        address profile,
        address indexed implementation,
        bytes32 salt,
        uint256 chainId,
        address indexed tokenContract,
        uint256 indexed tokenId
    );

    /**
     * @dev The registry must revert with ProfileCreationFailed error if the create2 operation fails.
     */
    error ProfileCreationFailed();

    /**
     * @dev Creates a token bound profile for a non-fungible token.
     *
     * If profile has already been created, returns the profile address without calling create2.
     *
     * Emits LSP27ProfileCreated event.
     *
     * @return profile The address of the token bound profile
     */
    function createProfile(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external returns (address profile);

    /**
     * @dev Returns the computed token bound profile address for a non-fungible token.
     *
     * @return profile The address of the token bound profile
     */
    function profile(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external view returns (address profile);
}
```

### Universal Profile

The existing implementation of the Universal Profile interface won't change but the logic of the `constructor` and `LSP14Ownable2Step` functions will have to be modified to support the LSP8 token ownership.

#### Methods

These are the functions and modifications on the Universal Profile contract to support the LSP27 standard.

##### constructor

```typescript
constructor(address _tokenContract, bytes32 _id) payable;
```

The constructor allows funding the profile during deployment and also sets the LSP8 token as the owner of the Universal Profile.

##### owner

```typescript
function owner() public view virtual returns (address);
```

The owner is read from the LSP8 contract by calling the `tokenOwnerOf()` function in the token contract. This ensures that ownership of the profile is transferred by mere transfer of the LSP8 token.

##### transferOwnership

```typescript
function transferOwnership(address newOwner) public;
```

To transfer ownership of the profile is to transfer the LSP8 token by calling the `transfer()` function in the token contract. We need not keep track of the current owner in state.

##### renounceOwnership

```typescript
function renounceOwnership() public;
```

This will delete the LSP8 token contract and id from storage which will leave the profile without an owner permanently.

## Rationale

The rationale for this proposal stems from the increasing complexity of digital assets and the need for a flexible, token-bound profile system that enables more nuanced token ownership and interaction capabilities.

By adapting LSP8 Identifiable Digital Assets and LSP0 Universal Profiles, we can create a framework for Token Bound Profiles that fits seamlessly within the Lukso ecosystem. Using LSP6 for access control ensures that the token owner is always in control of the associated Universal Profile, maintaining security and transparency.

## Backwards Compatibility

LIP-27 is fully compatible with existing LSP0, LSP6, and LSP8 standards. It introduces no breaking changes to the Universal Profile or Identifiable Digital Asset contracts.

## Security Considerations

### Fraud Prevention

In order to enable trustless sales of token bound accounts, decentralized marketplaces will need to implement safeguards against fraudulent behavior by malicious account owners.

Consider the following potential scam:

- Alice owns an LSP8 token X, which owns token bound account Y.
- Alice deposits 10ETH into account Y
- Bob offers to purchase token X for 11ETH via a decentralized marketplace, assuming he will receive the 10ETH stored in account Y along with the token
- Alice withdraws 10ETH from the token bound account, and immediately accepts Bob’s offer
- Bob receives token X, but account Y is empty
- To mitigate fraudulent behavior by malicious account owners, decentralized marketplaces should implement protection against these sorts of scams at the marketplace level. Contracts which implement this LIP may also implement certain protections against fraudulent behavior.

Here are a few mitigations strategies to be considered:

- Attach the current token bound account state to the marketplace order. If the state of the account has changed since the order was placed, consider the offer void. This functionality would need to be supported at the marketplace level.
- Attach a list of asset commitments to the marketplace order that are expected to remain in the token bound account when the order is fulfilled. If any of the committed assets have been removed from the account since the order was placed, consider the offer void. This would also need to be implemented by the marketplace.
- Submit the order to the decentralized market via an external smart contract which performs the above logic before validating the order signature. This allows for safe transfers to be implemented without marketplace support.
- Implement a locking mechanism on the token bound account implementation that prevents malicious owners from extracting assets from the account while locked
  Preventing fraud is outside the scope of this proposal.

Preventing fraud is outside the scope of this proposal.

### Ownership Cycles

All assets held in a token bound account may be rendered inaccessible if an ownership cycle is created. The simplest example is the case of an LSP8 token being transferred to its own token bound account. If this occurs, both the LSP8 token and all of the assets stored in the token bound account would be permanently inaccessible, since the token bound account is incapable of executing a transaction which transfers the LSP8 token.

Application clients and account implementations wishing to adopt this proposal are encouraged to implement measures that limit the possibility of ownership cycles.

## References

1. **EIP-6551: Non-fungible Token Bound Accounts**  
   A standard on Ethereum that enables ERC-721 tokens to control smart contract accounts. It allows each NFT to own assets and interact with contracts via a token-bound account.  
   [EIP-6551](https://eips.ethereum.org/EIPS/eip-6551)

2. **LUKSO LSP0 - Universal Profile**  
   Universal Profile is a key component of the LUKSO ecosystem, enabling individuals and organizations to create a smart contract-based profile for asset management and interaction within the network.  
   [LSP0 - Universal Profile](https://docs.lukso.tech/contracts/overview/UniversalProfile/)

3. **LUKSO LSP8 - Identifiable Digital Assets**  
   LSP8 is a token standard for unique, non-fungible assets on LUKSO, analogous to ERC-721. It serves as the foundation for the token-bound account system proposed in LIP-27.  
   [LSP8 - Identifiable Digital Assets](https://docs.lukso.tech/contracts/overview/DigitalAssets)
