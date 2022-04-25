---
lip: 10
title: ReceivedVaults
author: 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-12-1
requires: LSP2
---

## Simple Summary
This standard describes a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key-value pairs that can be used to store addresses of received vaults in a [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) smart contract.

## Abstract
The following two keys (including their ERC725Y JSON schema) are proposed to represent vaults owned by a smart contract:
- `LSP10ReceivedVaults[]` to hold an array of vault addresses
- `LSP10ReceivedVaultsMap` to hold a mapping of the index in the former array and the interface ID of the standard used by the vault. This enables to quickly differentiate vaults standards apart without the need to query each vault smart contract separately. 

The key `LSP10ReceivedVaultsMap` also helps to prevent adding duplications to the array, when automatically added via smart contract (e.g. a [LSP1-UniversalReceiverDelegate](./LSP-1-UniversalReceiver.md)).

## Motivation
To be able to display received vaults in a profile we need to keep track of all received vaults contract addresses. This is important for [LSP3 UniversalProfile](./LSP-3-UniversalProfile.md), but also Assets smart contracts via [LSP5-ReceivedAssets](./LSP-5-ReceivedAssets.md) Standard.

## Specification

Every contract that supports the LSP9Vault standard SHOULD have the following keys:

### ERC725Y Keys


#### LSP10Vaults[]

References issued smart contract vaults.

```json
{
    "name": "LSP10Vaults[]",
    "key": "0x55482936e01da86729a45d2b87a6b1d3bc582bea0ec00e38bdb340e3af6f9f06",
    "keyType": "Array",
    "valueContent": "Address",
    "valueType": "address"
}
```


#### LSP10VaultsMap

References issued smart contract vaults.

The `valueContent` MUST be constructed as follows: `bytes8(indexNumber) + bytes4(standardInterfaceId)`. 

```json
{
    "name": "LSP10VaultsMap:<address>",
    "key": "0x192448c3c0f88c7f00000000<address>",
    "keyType": "Bytes20Mapping",
    "valueContent": "Mixed",
    "valueType": "bytes"
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
        "name": "LSP10VaultsMap:<address>",
        "key": "0x192448c3c0f88c7f00000000<address>",
        "keyType": "Bytes20Mapping",
        "valueContent": "Mixed",
        "valueType": "bytes"
    },
    {
        "name": "LSP10Vaults[]",
        "key": "0x55482936e01da86729a45d2b87a6b1d3bc582bea0ec00e38bdb340e3af6f9f06",
        "keyType": "Array",
        "valueContent": "Address",
        "valueType": "address"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
