---
lip: 10
title: Received Vaults
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-12-1
requires: LSP2
---

## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data key-value pairs that can be used to store addresses of received vaults in a [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract.

## Abstract
The following two data keys (including their ERC725Y JSON schema) are proposed to represent vaults owned by a smart contract:
- `LSP10Vaults[]` to hold an array of vault addresses
- `LSP10VaultsMap` to hold a mapping of the index in the former array and the interface ID of the standard used by the vault. This enables to quickly differentiate vaults standards apart without the need to query each vault smart contract separately. 

The data key `LSP10VaultsMap` also helps to prevent adding duplications to the array, when automatically added via smart contract (e.g. a [LSP1-UniversalReceiverDelegate](./LSP-1-UniversalReceiver.md)).

## Motivation
To be able to display received vaults in a profile we need to keep track of all received vaults contract addresses. This is important for [LSP3 UniversalProfile](./LSP-3-UniversalProfile.md), but also Assets smart contracts via [LSP5-ReceivedAssets](./LSP-5-ReceivedAssets.md) Standard.

## Specification

Every contract that supports the LSP9Vault standard SHOULD have the following data keys:

### ERC725Y Data Keys


#### LSP10Vaults[]

References issued smart contract vaults.

```json
{
    "name": "LSP10Vaults[]",
    "key": "0x55482936e01da86729a45d2b87a6b1d3bc582bea0ec00e38bdb340e3af6f9f06",
    "keyType": "Array",
    "valueType": "address",
    "valueContent": "Address"
}
```


#### LSP10VaultsMap

References owned [LSP9Vaults](./LSP-9-Vault.md). This data key exists so that smart contracts can detect whether the address of a vault is present in the `LSP10Vaults[]` array without looping all over it on-chain. Moreover, it helps to identify at which index in the `LSP10Vaults[]` the vault address is located for easy access and to change or remove this specific vault from the array. Finally, it also allows dectecting the interface supported by the vault.

The data value MUST be constructed as follows: `bytes4(standardInterfaceId) + bytes8(indexNumber)`. Where:
- `standardInterfaceId` = the [ERC165 interface ID](https://eips.ethereum.org/EIPS/eip-165) of a [LSP9Vaults](./LSP-9-Vault.md): `0xfd4d5c50`.
- `indexNumber` = the index in the [`LSP10Vaults[]` Array](#lsp10vaults)

Value example: `0xfd4d5c50000000000000000c` (interfaceId: `0xfd4d5c50`, index position `0x000000000000000c = 12`).

```json
{
    "name": "LSP10VaultsMap:<address>",
    "key": "0x192448c3c0f88c7f238c0000<address>",
    "keyType": "Mapping",
    "valueType": "(bytes4,uint128)",
    "valueContent": "(Bytes4,Number)"
}
```

## Rationale

## Implementation

An implementation can be found in the [lukso-network/standards-scenarios](https://github.com/lukso-network/lsp-universalprofile-smart-contracts/tree/develop/contracts/LSP1UniversalReceiver/LSP1UniversalReceiverDelegateVault);
Below is the ERC725Y JSON interface of the `LSP10ReceivedVaults`.

ERC725Y JSON Schema `LSP10ReceivedVaults`:
```json
[
    {
        "name": "LSP10Vaults[]",
        "key": "0x55482936e01da86729a45d2b87a6b1d3bc582bea0ec00e38bdb340e3af6f9f06",
        "keyType": "Array",
        "valueType": "address",
        "valueContent": "Address"
    },
    {
        "name": "LSP10VaultsMap:<address>",
        "key": "0x192448c3c0f88c7f238c0000<address>",
        "keyType": "Mapping",
        "valueType": "(bytes4,uint128)",
        "valueContent": "(Bytes4,Number)"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
