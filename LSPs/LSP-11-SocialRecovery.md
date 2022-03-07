---
lip: 11
title: SocialRecovery
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-2-14
requires: ERC725, LSP0, LSP2, LSP6
---

## Simple Summary
This standard describes a `SocialRecovery` contract that can recover access to [ERC725](#) contracts through the [LSP6-KeyManager](#).

## Abstract
This standard allows for recovering access to ERC725 contracts such as tokens, NFTs, and Universal Profiles by adding a new address to control them through the Key Manager after a recovery process.

The social recovery contract should provide the most flexible and secure process, where the guardians, set originally by the owner, can vote to one address in each recoverProcessId. The address willing to recover can choose a recoverProcessId where he reached the guardiansThreshold and after successfully providing the right secret word, that produces the hash already set by the owner, he will be granted the owner permissions in the account recovered and a new hash will be set and all previous recoverProcessId will be invalidated.

## Motivation
Any Key could be lost or leaked due to a certain accident, so it's not advised to rely on one singular key to control ERC725 contracts through the Key Manager and a social recovery contract is needed in this case.

In the case above, the user can simply reach out to his guardians and ask them to vote for a certain address. 
There are many possible choices for whom to select as a guardian. The three most common choices are:

- Other devices (or paper mnemonics) owned by the wallet holder themselves
- Friends and family members (EOAs or Universal Profiles)
- Institutions, which would vote for the address provided if they get a confirmation of your phone number or email or perhaps in high-value cases to verify you personally by video call

## Specification

ERC165 interface id: `0xffffffff`

It's advised when deploying the contract and setting it up to start with the following order of functions:

- **`addGuardian(...)`**

- **`removeGuardian(...)`**

- **`setThreshold(...)`**

- **`setSecret(...)`**

Every contract that supports the LSP11SocialRecovery SHOULD implement:

### Methods

#### addGuardian

#### removeGuardian

#### voteToRecover

#### setSecret

#### setThreshold

#### recoverOwnership

#### allGuardians

#### isGuardian

#### guardiansCount

#### guardians

#### universalReceiver


### Events

## Rationale

This standard was inspired by the current recovery process in some crypto wallets but this recovery process is a balance between a secret word and guardians.

In this case, you can ensure that you're guardians can't act maliciously and would need a secret word to recover. The same goes for the secret word if it's exposed, only addresses who reached the guardiansThreshold can recover using it.

A recoverProcessId is also created to ensure flexibility when recovering, so if guardians didn't reach consensus in a recoverProcessId, they can switch to another one. 

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/tree/main/contracts/LSP11SocialRecovery/) repo.

## Interface Cheat Sheet

```solidity
interface ILSP11  /* is ERC165 */ {
         
    
    
}
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
