---
lip: 11
title: BasicSocialRecovery
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-2-14
requires: ERC725, LSP0, LSP2, LSP6
---

## Simple Summary
This standard describes a **basic social recovery** contract that can recover access to [ERC725](https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md) contracts through the [LSP6-KeyManager](./LSP-6-KeyManager.md).

## Abstract
This standard provides a mechanism for recovering access to ERC725 contracts such as tokens, NFTs, and Universal Profiles by adding a new controller address through the Key Manager after a recovery process.

The social recovery contract should ensure a flexible and secure process where guardians, nominated by the owner, can vote for one address in each `recoverProcessId`. The address requesting recovery can choose a `recoverProcessId` where he reached the `guardiansThreshold` and after successfully providing the secret word which produces the same hash as the secret hash set by the owner, he will be granted the owner permissions in the recovered account and a new hash will be set and all previous `recoverProcessId` will be invalidated.

## Motivation
Any Key could be lost or leaked due to a certain accident, so it's not advised to rely on one singular key to control ERC725 contracts through the Key Manager and a social recovery contract is needed in this case.

In the case above, the user can simply reach out to his guardians and ask them to vote for a certain address. 
There are many possible choices for whom to select as a guardian. The three most common choices are:

- EOAs controlled by the wallet holder themselves (via paper mnemonics or cold storage devices)
- Friends and family members (EOAs or Universal Profiles)
- Institutions, which could vote for a provided address if they get a valid confirmation via phone number, email or video call

## Specification

ERC165 interface id: `0xcb81043b`

It's advised when deploying the contract and setting it up to start with the following order of functions:

- **`addGuardian(...)`**

- **`removeGuardian(...)`**

- **`setThreshold(...)`**

- **`setSecret(...)`**

Every contract that supports the LSP11SocialRecovery SHOULD implement:

### Methods

#### account

```solidity
function account() public view returns (address)
```

Returns the address of the linked account to recover.


#### isGuardian

```solidity
function isGuardian(address _address) public view returns (bool)
```

Returns _true_ if the provided address is a guardian, _false_ otherwise.

_Parameters:_

- `_address`: the address to query.


#### getGuardians

```solidity
function getGuardians() public view returns (address[] memory)
```

Returns the array of guardian addresses set.



#### getGuardiansThreshold

```solidity
function getGuardiansThreshold() public view returns (uint256)
```

Returns the minimum number of guardian votes needed for an address to recover the linked account.



#### getRecoverProcessesIds

```solidity
function getRecoverProcessesIds() public view returns (bytes32[] memory)
```

Returns all the recover processes ids that the guardians has voted in.

#### getGuardianVote

```solidity
function getGuardianVote(bytes32 recoverProcessId, address guardian) public view returns (address)
```

Returns the address for which the `guardian` has voted in the provided recoverProcessId.

_Parameters:_

- `recoverProcessId`: the recover process id in which the guardian has voted.

- `guardian`: the address of the guardian who voted.

#### addGuardian

```solidity
function addGuardian(address newGuardian) public
```

Adds a new guardian.

SHOULD be called only by the owner.

_Parameters:_

- `newGuardian`: the address of the guardian to set.


#### removeGuardian

```solidity
function removeGuardian(address currentGuardian) public
```

Removes an existing guardian.

SHOULD be called only by the owner.

_Parameters:_

- `currentGuardian`: the address of the guardian to remove.

#### setThreshold

```solidity
function setThreshold(uint256 newThreshold) public
```

Sets the number of guardian votes required to recover the linked account.

The number should be greater than 0 and less than the guardians count.

SHOULD be called only by the owner.

_Parameters:_

- `newThreshold`: the number of guardian votes required to recover the linked account.

#### setSecret

```solidity
function setSecret(bytes32 newHash) public
```

Sets the hash of the plainSecret needed to recover the account after reaching the recoverThreshold.

SHOULD be called only by the owner.

_Parameters:_

- `newHash`: the hash of the plainSecret.

#### voteToRecover

```solidity
function voteToRecover(bytes32 recoverProcessId, address addressToRecover) public
```

Votes to a `addressToRecover` address in a specific recoverProcessId.

Once the `addressToRecover` reach the recoverThreshold it will be able to call `recoverOwnership(..)` function and recover the linked account.

SHOULD be called only by the guardians.

_Parameters:_

- `recoverProcessId`: the recover Process Id in which the `addressToRecover` has been voted for.

- `addressToRecover`: the address to vote for in order to recover the linked account.

#### recoverOwnership

```solidity
function recoverOwnership(bytes32 recoverProcessId, string memory plainSecret, bytes32 newHash) public 
```

Recover the linked account by setting in All Permissions (combined) for the msg.sender after it reached the recoverThreshold and given the right plainSecret that produce the `secretHash`.

_Parameters:_

- `recoverProcessId`: the recover process id in which the `msg.sender` should have reached the threshold.

- `plainSecret`: the plain secret that should produce the `secretHash` with _keccak256_ function.

- `newHash`: the new secret hash to set.


### Setup

In order to allow the social recovery contract to recover the linked account and add new permissions, this contract should have `ADDPERMISSIONS` and `CHANGEPERMISSIONS` set inside the **linked account** under this ERC725Y Data Key.

```json
{
    "name": "AddressPermissions:Permissions:<address>",
    "key": "0x4b80742de2bf82acb3630000<address>",
    "keyType": "MappingWithGrouping",
    "valueType": "bytes32",
    "valueContent": "BitArray"
}
```

### Events

## Rationale

This standard was inspired by the current recovery process in some crypto wallets but this recovery process is a balance between a secret hash and guardians.

In this case, it is ensured that guardians can't act maliciously and would need a secret word to recover. The same goes for the secret word if it is exposed, only addresses who reached the guardiansThreshold can use it to recover an account.

A recoverProcessId is also created to ensure flexibility when recovering, so if guardians didn't reach consensus in a recoverProcessId, they can switch to another one. 

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/pull/114) repo.

## Interface Cheat Sheet

```solidity
interface ILSP11  /* is ERC165 */ {
         
    function account() external view returns (address);

    function isGuardian(address _address) external view returns (bool);

    function getGuardians() external view returns (address[] memory);
    
    function getGuardiansThreshold() external view returns (uint256);

    function getRecoverProcessesIds() external view returns (bytes32[] memory);

    function getGuardianVote(bytes32 recoverProcessId, address guardian) external view returns (address);

    function addGuardian(address newGuardian) external;  // onlyOwner

    function removeGuardian(address currentGuardian) external;  // onlyOwner
    
    function setThreshold(uint256 _guardiansThreshold) external;  // onlyOwner

    function setSecret(bytes32 secretHash) external;  // onlyOwner

    function voteToRecover(bytes32 recoverProcessId, address newOwner) external;  // onlyGuardians

    function recoverOwnership(bytes32 recoverProcessId, string memory plainSecret, bytes32 newHash) external;
    
}
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
