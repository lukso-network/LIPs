---
lip: 27
title: Token Bound Profile
author: Valentine Orga <valentineorga@gmail.com>, Tanto Defi <tantodefi@proton.me>, SLEEPY SIGN <sign@sleepynft.com>
status: Draft
type: LSP
category: Core
created: 2024-09-14
requires: LSP0, LSP8
---

## Simple Summary

LIP-27 introduces a standard for creating Token Bound Profiles (TBP) using **LSP8 Identifiable Digital Assets** and **Universal Profiles (LSP0)**. This standard enables LSP8 tokens to be associated with a Universal Profile, facilitating token-based ownership and interaction.

## Abstract

This proposal adapts the idea of **EIP-6551 (Token Bound Accounts)** for the Lukso ecosystem. Instead of using ERC721 tokens, LIP-27 leverages **LSP8 tokens** to bind each token to its own Universal Profile.

Key components include:

- A **Registry Contract** that maps LSP8 token identifiers to their respective Universal Profiles.
- A modified **Universal Profile** contract that restricts execution rights to the token owner.

## Motivation

As NFTs and tokenized assets proliferate, there is a need for tokens to have autonomous profiles capable of holding assets, executing contracts, and interacting with decentralized applications. **LIP-27** facilitates this functionality within the Lukso ecosystem using **LSP8 tokens** and **Universal Profiles**.

This approach enhances the utility of tokens by allowing each token to have its own programmable, self-sovereign profile, while maintaining compatibility with Lukso’s standards for identity (**LSP0**) and digital assets (**LSP8**).

## Specification

### Overview

The system consists of two primary components:

1. A **singleton registry** for Token Bound Profiles.
2. A common **Universal Profile implementation** modified to support LSP8 ownership, while adhering to the `LSP0-ERC725Account` interface.

### Registry Contract

The **Registry Contract** maps each LSP8 token to a unique Universal Profile. This ensures that for each LSP8 token, there is a corresponding Universal Profile.

#### Registry Interface

```solidity
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
     * @dev The registry must revert with ProfileCreationFailed error if the CREATE2 operation fails.
     */
    error ProfileCreationFailed();

    /**
     * @dev Creates a token-bound profile for a non-fungible token.
     * If a profile already exists, returns the address without calling CREATE2.
     *
     * Emits an LSP27ProfileCreated event.
     *
     * @return profile The address of the token-bound profile.
     */
    function createProfile(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external returns (address profile);

    /**
     * @dev Returns the computed token-bound profile address for a non-fungible token.
     *
     * @return profile The address of the token-bound profile.
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

### Universal Profile Modifications

The existing **Universal Profile (LSP0)** implementation will remain largely unchanged, but its logic will be modified to support LSP8 token ownership.

#### Constructor

```solidity
constructor(address _tokenContract, bytes32 _id) payable;
```

- **Purpose**: Initializes the Universal Profile, allowing for funding upon deployment and setting the LSP8 token as the profile's owner.

#### Owner Function

```solidity
function owner() public view virtual returns (address);
```

- **Purpose**: The ownership of the Universal Profile is determined by calling the `tokenOwnerOf()` function from the LSP8 contract. Ownership is transferred along with the token transfer.

#### Transfer Ownership

```solidity
function transferOwnership(address newOwner) public;
```

- **Purpose**: Ownership of the Universal Profile is transferred by transferring the associated LSP8 token, instead of updating the state within the Universal Profile contract.

#### Renounce Ownership

```solidity
function renounceOwnership() public;
```

- **Purpose**; This function permanently deletes the token contract and ID from storage, leaving the profile without an owner.

## Rationale

The rationale for this proposal stems from the increasing complexity of digital assets and the need for a flexible, token-bound profile system that enables more nuanced token ownership and interaction capabilities.

By leveraging **LSP8 Identifiable Digital Assets** and **LSP0 Universal Profiles**, we can create a framework for **Token Bound Profiles** that fits seamlessly within the Lukso ecosystem.

This approach offers several advantages:

- **Seamless Integration**: Token Bound Profiles build upon existing Lukso standards (LSP0 and LSP8), making them compatible with the ecosystem's existing infrastructure.
- **Programmable Ownership**: By binding ownership to LSP8 tokens, profiles are automatically controlled by token holders without requiring manual intervention.
- **Flexible Interactions**: This system allows tokens to interact with decentralized applications (dApps) and manage assets autonomously via their associated profiles.

## Backwards Compatibility

LIP-27 is fully compatible with existing **LSP0** and **LSP8** standards. It introduces no breaking changes to the Universal Profile or Identifiable Digital Asset contracts.

- **LSP0 (Universal Profile)**: The modifications to the Universal Profile contract under LIP-27 are backward compatible and do not alter the existing interface. The contract logic is adapted to incorporate LSP8 token ownership without disrupting the standard functionality.
- **LSP8 (Identifiable Digital Assets)**: LIP-27 utilizes LSP8 tokens as the basis for token-bound profiles. The proposal aligns with the LSP8 standard and does not introduce any breaking changes to the existing token mechanics.

Overall, LIP-27 extends the capabilities of existing standards while ensuring full compatibility and continuity within the Lukso ecosystem.

## Security Considerations

### Fraud Prevention

In order to enable trustless sales of token bound accounts, decentralized marketplaces will need to implement safeguards against fraudulent behavior by malicious account owners.

Consider the following potential scam:

- Alice owns an LSP8 token X, which owns token bound account Y.
- Alice deposits 10 LYX into account Y.
- Bob offers to purchase token X for 11 LYX via a decentralized marketplace, assuming he will receive the 10 ETH stored in account Y along with the token.
- Alice withdraws 10 LYX from the token bound account and immediately accepts Bob’s offer.
- Bob receives token X, but account Y is empty.

To mitigate fraudulent behavior by malicious account owners, decentralized marketplaces should implement protection against these sorts of scams. Here are a few mitigation strategies to consider:

- **Attach the current token bound account state to the marketplace order**: If the state of the account has changed since the order was placed, consider the offer void. This functionality would need to be supported at the marketplace level.
- **Attach a list of asset commitments to the marketplace order**: This list should include assets expected to remain in the token bound account when the order is fulfilled. If any of the committed assets have been removed since the order was placed, consider the offer void. This would also need to be implemented by the marketplace.
- **Submit the order to the decentralized market via an external smart contract**: This contract can perform the above checks before validating the order signature, allowing for safe transfers without marketplace support.
- **Implement a locking mechanism on the token bound account**: Prevent malicious owners from extracting assets while the account is locked.

Preventing fraud is outside the scope of this proposal.

### Ownership Cycles

All assets held in a token bound account may become inaccessible if an ownership cycle is created. For example:

- An LSP8 token could be transferred to its own token bound account. If this occurs, both the LSP8 token and all assets stored in the token bound account would be permanently inaccessible, as the token bound account is incapable of executing a transaction that transfers the LSP8 token.

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
