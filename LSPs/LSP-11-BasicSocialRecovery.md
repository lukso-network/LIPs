---
lip: 11
title: BasicSocialRecovery
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-2-14
requires: ERC165, ERC725, LSP2, LSP6
---

## Simple Summary

This standard describes a **basic social recovery** contract that can recover access to [ERC725] contracts through a [LSP6-KeyManager](./LSP-6-KeyManager.md).

## Abstract

This standard provides a mechanism for recovering access to ERC725 contracts such as tokens, NFTs, and Universal Profiles by adding a new controller address through the Key Manager after a recovery process.

The social recovery contract should ensure a flexible and secure process where guardians, nominated by the owner, can select one address. The address after reaching the `guardiansThreshold` and after successfully providing the secret word which produces the same hash as the secret hash set by the owner, will be granted the owner permissions in the recovered target and a new hash will be set and a new recovery counter will be created.

## Motivation

Any Key could be lost or leaked due to a certain accident, so it is not advised to rely on a singular key to control ERC725 contracts through the Key Manager and a social recovery contract is needed in this case.

In the case above, the user can reach out to his guardians and ask them to vote for a specific address. 
There are many possible options for whom to select as a guardian. The three most common options are:

- EOAs controlled by the wallet holder themselves (via paper mnemonics or cold storage devices)
- Friends and family members (EOAs or Universal Profiles)
- Institutions, which could vote for a provided address if they get a valid confirmation via phone number, email or video call

## Specification

LSP11 interface id according to [ERC165]: 0x049a28f1.

### Methods

Smart contracts implementing the LSP11 standard MUST implement all of the functions listed below:

#### target

```solidity
function target() external view returns (address)
```

Returns the address of the linked ERC725 contract to recover.

#### getRecoveryCounter

```solidity
function getRecoveryCounter() external view returns (uint256)
```

Returns the number of finished successful recovery processes.

#### getGuardians

```solidity
function getGuardians() external view returns (address[] memory)
```

Returns the array of guardian addresses set.

#### isGuardian

```solidity
function isGuardian(address _address) external view returns (bool)
```

Returns _true_ if the provided address is a guardian, _false_ otherwise.

_Parameters:_

- `_address`: the address to query.

#### getGuardiansThreshold

```solidity
function getGuardiansThreshold() external view returns (uint256)
```

Returns the minimum number of guardians selection required by an address to start a recovery process.


#### getRecoverySecretHash

```solidity
function getRecoverySecretHash() external view returns (bytes32)
```

Returns the recovery secret hash set by the owner.


#### getGuardianChoice

```solidity
function getGuardianChoice(address guardian) external view returns (address)
```

Returns the address that a `guardian` selected for target recovery.

_Parameters:_

- `guardian`: the address that `guardian` has selected.

#### addGuardian

```solidity
function addGuardian(address newGuardian) external
```

Adds a guardian of the target. MUST fire the [AddedGuardian](#guardianadded) event.

_Parameters:_

- `newGuardian`: the address of the guardian to set.

_Requirements:_

- MUST be called only by the owner.

#### removeGuardian

```solidity
function removeGuardian(address currentGuardian) external
```

Removes an existing guardian of the target. MUST fire the [RemovedGuardian](#guardianremoved) event.

_Parameters:_

- `currentGuardian`: the address of the guardian to remove.

_Requirements:_

- MUST be called only by the owner.

#### setGuardiansThreshold

```solidity
function setGuardiansThreshold(uint256 newThreshold) external
```

Sets the minimum number of selection by the guardians required so that an address can recover ownership to the linked target contract. MUST fire the [GuardianThresholdChanged](#guardiansthresholdchanged) event.

If the GuardiansThreshold is equal to 0, the social recovery contract will act as a password recovery contract.

_Parameters:_

- `newThreshold`: the threshold to set.

_Requirements:_

- MUST be called only by the owner.

#### setRecoverySecretHash

```solidity
function setRecoverySecretHash(bytes32 newSecretHash) external
```

Sets the hash of the plainSecret needed to recover the target after reaching the guardians threshold. MUST fire the [SecretHashChanged](#secrethashchanged) event.

_Parameters:_

- `newHash`: the hash of the plainSecret.

_Requirements:_

- MUST be called only by the owner.

- MUST not be bytes32(0).

#### selectNewController

```solidity
function selectNewController(address addressSelected) external
```

Select an address to be a potentiel controller address if he reaches the guardian threshold and provide the correct plainSecret. MUST fire the [SelectedNewController](#selectednewcontroller) event.

_Parameters:_

- `addressSelected`: The address selected by the guardian.

_Requirements:_

- MUST be called only by the guardians.

#### recoverOwnership

```solidity
function recoverOwnership(address recoverer, string memory plainSecret, bytes32 newHash) external 
```

Increment the recovery counter and recovers the ownership permissions in the linked target for the recoverer if he has reached the guardiansThreshold and given the right plainSecret that produce the `secretHash`. MUST fire the [RecoveryProcessSuccessful](#recoverprocesssuccessful) event and the [SecretHashChanged](#secrethashchanged) event.

_Parameters:_

- `recoverer`: the address of the recoverer.

- `plainSecret`: the plain secret that should produce the `secretHash` with _keccak256_ function.

- `newHash`: the new secret hash to set for the future recovery process.

_Requirements:_

- MUST have provided the right `plainSecret` that produces the secretHash originally set by the owner.

### Events

#### GuardianAdded

```solidity
event GuardianAdded(address indexed newGuardian);
```

MUST be emitted when setting a new guardian for the target.

#### GuardianRemoved

```solidity
event GuardianRemoved(address indexed removedGuardian);
```

MUST be emitted when removing an existing guardian for the target.

#### GuardiansThresholdChanged

```solidity
event GuardiansThresholdChanged(uint256 indexed guardianThreshold);
```

MUST be emitted when changing the guardian threshold.

#### SecretHashChanged

```solidity
event SecretHashChanged(bytes32 indexed secretHash);
```

MUST be emitted when changing the secret hash.

#### SelectedNewController

```solidity
event SelectedNewController(uint256 indexed currentRecoveryCounter, address indexed guardian, address indexed addressSelected);
```

MUST be emitted when a guardian select a new potentiel controller address for the linked target.

#### RecoveryProcessSuccessful

```solidity
event RecoveryProcessSuccessful(uint256 indexed recoveryCounter, address indexed newController, bytes32 indexed newSecretHash, address[] guardians);
```

MUST be emitted when the recovery process is finished by the controller who reached the guardian threshold and submitted the string that produce the secretHash

### Setup

In order to allow the social recovery contract to recover the linked target and add new permissions, the linked target should have an [LSP6-KeyManager](./LSP-6-KeyManager.md) as owner and the social recovery contract should have `ADDPERMISSIONS` and `CHANGEPERMISSIONS` permissions set inside the **linked target** under this ERC725Y data key.

```json
{
    "name": "AddressPermissions:Permissions:<address>",
    "key": "0x4b80742de2bf82acb3630000<address>",
    "keyType": "MappingWithGrouping",
    "valueType": "bytes32",
    "valueContent": "BitArray"
}
```

## Rationale

This standard was inspired by the current recovery process in some crypto wallets with a balance between relying on the guardians and a secret hash.

In this case, it is ensured that guardians can't act maliciously and would need a secret word to recover. The same goes for the secret word if it is exposed, only addresses who reached the guardiansThreshold can use it to recover the target.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/pull/114) repository.

## Interface Cheat Sheet

```solidity
interface ILSP11  /* is ERC165 */ {

    event GuardianAdded(address indexed newGuardian);

    event GuardianRemoved(address indexed removedGuardian);

    event GuardiansThresholdChanged(uint256 indexed guardianThreshold);

    event SecretHashChanged(bytes32 indexed secretHash);

    event SelectedNewController(
        uint256 indexed recoveryCounter,
        address indexed guardian,
        address indexed controllerSelected
    );

    event RecoveryProcessSuccessful(
        uint256 indexed recoveryCounter,
        address indexed newController,
        bytes32 indexed newSecretHash,
        address[] guardians
    );


    function target() external view returns (address);

    function getRecoveryCounter() external view returns (uint256);

    function getGuardians() external view returns (address[] memory);

    function isGuardian(address _address) external view returns (bool);

    function getGuardiansThreshold() external view returns (uint256);
    
    function getRecoverySecretHash() external view returns (bytes32);

    function getGuardianChoice(address guardian) external view returns (address);

    function addGuardian(address newGuardian) external;

    function removeGuardian(address currentGuardian) external;

    function setRecoverySecretHash(bytes32 newRecoverSecretHash) external;

    function setGuardiansThreshold(uint256 guardiansThreshold) external;

    function selectNewController(address addressSelected) external;

    function recoverOwnership(address recoverer, string memory plainSecret, bytes32 newHash) external;
    
}
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[ERC725]: <https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md>
