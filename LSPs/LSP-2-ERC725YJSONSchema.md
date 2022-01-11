---
lip: 2
title: ERC725Y JSON Schema
author: Fabian Vogelsteller <fabian@lukso.network> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2020-07-01
requires: ERC725Y
---


## Simple Summary

This schema defines how a single [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key-value pair can be described. It can be used as an abstract structure over the storage of an ERC725Y smart contract.

## Abstract

ERC725Y enables storing any data in a smart contract as `bytes32 => bytes` key-value pairs.

Although this improves interaction with the data stored, it remains difficult to understand the layout of the contract storage. This is because both the key and the value are addressed in raw bytes.

This schema allows to standardize those keys and values so that they can be more easily accessed and interpreted. It can be used to create ERC725Y sub-standards, made of pre-defined sets of ERC725Y keys.

## Motivation

A schema defines a blueprint for how a data store is constructed.

In the context of smart contracts, it can offer a better view of how the data is organised and structured within the contract storage.

Using a standardised schema over ERC725Y enables those keys and values to be easily readable and automatically parsable. Contracts and interfaces can know how to read and interact with the storage of an ERC725Y smart contract.

The advantage of such schema is to allow interfaces or smart contracts to better decode (read, parse and interpret) the data stored in an ERC725Y contract. It is less error-prone due to knowing data types upfront. On the other hand, it also enables interfaces and contracts to know how to correctly encode data, before being set on an ERC725Y contract.

This schema is for example used in [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) based smart contracts like
[LSP3-UniversalProfile](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-3-UniversalProfile-Metadata.md) and [LSP4-DigitalAsset-Metadata](https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-4-DigitalAsset-Metadata.md).

## Specification

> **Note:** described sets might not yet be complete, as they could be extended over time.

To make ERC725Y keys readable, we describe a key-value pair as a JSON object containing the following entries:

```json
{
    "name": "...",
    "key": "...",
    "keyType": "...",
    "valueType": "...",
    "valueContent": "..."
}
```

The table below describes each entries with their available options. 

| Title | Description |
|:----|:----|
|[`name`](#name)| the name of the key |
|[`key`](#key)| the **unique identifier** of the key |
|[`keyType`](#keyType)| *How* the key must be treated <hr> [`Singleton`](#Singleton) <br> [`Array`](#Array) <br> [`Mapping`](#Mapping) <br> [`Bytes20Mapping`](#Bytes20Mapping) <br> [`Bytes20MappingWithGrouping`](#Bytes20MappingWithGrouping) |
|[`valueType`](#valueType)| *How* a value MUST be decoded <hr> `boolean` <br> `string` <br> `address` <br> `uintN` <br> `intN` <br> `bytesN` <br> `bytes` <br> `uintN[]` <br> `intN[]` <br> `string[]` <br> `address[]` <br> `bytes[]` |
|[`valueContent`](#valueContent)| *How* a value SHOULD be interpreted <hr> `Boolean` <br> `String` <br> `Address` <br> `Number` <br> `BytesN` <br> `Bytes` <br> `Keccak256` <br> [`BitArray`](#BitArray) <br> `URL` <br> [`AssetURL`](#AssetURL) <br> [`JSONURL`](#JSONURL) <br> `Markdown` <br> `Literal` (*e.g.:* `0x1345ABCD...`) |

### `name`

The `name` is the human-readable format of the ERC725Y key. It aims to abstract the representation of the ERC725Y key and defines what the key represents. In most cases, it SHOULD highlight the intent behind the key.

In scenarios where an ERC725Y key is part of an LSP Standard, the key `name` SHOULD be comprised of the following: `LSP{N}{KeyName}`, where

- `LSP`: abbreviation for **L**UKSO **S**tandards **P**roposal.
- `N`: the **Standard Number** this key refers to.
- `KeyName`: base of the key name. Should represent the meaning of a value stored behind the key.

*e.g.:* `MyColourTheme` (not part of any LSP Standard), `LSP4TokenName` (part of a LSP standard)


### `key`

The `key` is a `bytes32` value that acts as the **unique identifier** for the key. It is the actual key that MUST be used to retrieve the value stored in the contract storage, via `ERC725Y.getData(bytes32 key)`.

The standard `keccak256` hashing algorithm is used to generate this identifier. However, *how* the identifier is constructed varies, depending on the `keyType`:

- for `Singleton` keys: the hash of the key name (*e.g.:* `keccak256('MyKeyName') = 0x35e6950bc8d21a1699e58328a3c4066df5803bb0b570d0150cb3819288e764b2`)
- for `Array` keys (see [`Array`](#array) section for more details)
  - an initial key containing the array length.
  - subsequent keys for array index access.
- for mapping keys, see each mapping type separately below.


### `keyType`

The `keyType` determines how the value(s) should be interpreted.

| `keyType` | Description  | Example |
|---|---|---|
| [`Singleton`](#singleton)  | A simple key  | `bytes32(keccak256("MyKeyName"))`<br> --- <br> `MyKeyName` -->  `0x35e6950bc8d21a1699e58328a3c4066df5803bb0b570d0150cb3819288e764b2` |
| [`Array`](#array)  | an array spanning multiple ERC725Y keys  | `bytes32(keccak256("MyKeyName[]"))` <br> --- <br> `MyKeyName[]` -->   `0x24f6297f3abd5a8b82f1a48cee167cdecef40aa98fbf14534ea3539f66ca834c`|
| [`Mapping`](#mapping)  | a key that map two words  | `bytes16(keccak256("MyKeyName"))` + `bytes12(0)` + `bytes4(keccak256("MapName"))` <br> --- <br> `MyKeyName:MapName` -->  `0x24f6297f3abd5a8b82f1a48cee167cde000000000000000000000000e6041813` |
| [`Bytes20Mapping`](#bytes20mapping)  | a key that maps a word to a `bytes20` value, such as (but not restricted to) an `address` | `bytes8(keccak256("MyKeyName"))` + `bytes4(0)` +  `bytes20(dynamicValue)` <br> --- <br> `MyKeyName:cafecafecafecafecafecafecafecafecafecafe` -->  `0x35e6950bc8d21a1600000000cafecafecafecafecafecafecafecafecafecafe` |
| [`Bytes20MappingWithGrouping`](#bytes20mappingwithgrouping)  | a key that maps a word to another word to a `bytes20` value, such as (but not restricted to) an `address`  | `bytes4(keccak256("MyKeyName"))` + `bytes4(0)` + `bytes2(keccak256("MapName"))` + `bytes2(0)` +  `bytes20(dynamicValue)` <br> --- <br> `MyKeyName:MapName:cafecafecafecafecafecafecafecafecafecafe` -->  `0x35e6950b00000000e6040000cafecafecafecafecafecafecafecafecafecafe` |


### `valueType`

Describes the underlying data type of a value stored under a specific ERC725Y key. It refers to the type for the smart contract language like [Solidity](https://docs.soliditylang.org).

The `valueType` is relevant for interfaces to know how a value MUST be encoded/decoded. This include:

- how to decode a value fetched via `ERC725Y.getData(...)`
- how to encode a value that needs to be set via `ERC725Y.setData(...)`. 

The `valueType` can also be useful for typecasting. It enables contracts or interfaces to know how to manipulate the data and the limitations behind its type. To illustrate, an interface could know that it cannot set the value to `300` if its `valueType` is `uint8` (max `uint8` allowed = `255`).

| `valueType` | Description |
|---|---|
| `boolean`  | a value as either **true** or **false** |
| `string`  | an UTF8 encoded string  |
| `address`  | a 20 bytes long address |
| `uintN`  | an **unsigned** integer (= only positive number) of size `N`  |
| `intN`  |a **signed** integer (= either positive or negative number) of size `N` |
| `bytesN`  | a bytes value of **fixed-size** `N`, from `bytes1` up to `bytes32` |
| `bytes`  | a bytes value of **dynamic-size** |
| `uintN[]`  | an array of **signed** integers |
| `intN[]`  | an array of **unsigned** integers |
| `string[]`  | an array of UTF8 encoded strings |
| `address[]`  | an array of addresses   |
| `bytes[]`   | an array of dynamic size bytes  |
| `bytesN[]`  | an array of fixed size bytes  |

### `valueContent`

Describes how to interpret the content of the returned *decoded* value.

To illustrate, a string could be interpreted in multiple ways, such as:
- a single word, or a sequence of words (*e.g.: "My Custom Token Name"*)
- an URL (*e.g.: "ipfs://QmW4nUNy3vtvr3DxZHuLfSLnhzKMe2WmgsUsEGPPFh8Ztp"*)

Valid `valueContent` are:

| `valueContent` | Description  |
|---|---|
| `String`  | an UTF8 encoded string |
| `Address`  | an address |
| `Number`  | a Number (positive or negative, depending on the `keyType`)  |
| `BytesN`  | a bytes value of **fixed-size** `N`, from `bytes1` up to `bytes32`  |
| `Bytes`  | a bytes value of **dynamic-size** |
| `Keccak256`  | a 32 bytes long hash digest, obtained from the keccak256 hashing algorithm |
| `BitArray`  | an array of single `1` or `0` bits |
| `URL`  | an URL encoded as an UTF8 string |
| [`AssetURL`](#asseturl)  | The content contains the hash function, hash and link to the asset file  |
| [`JSONURL`](#jsonurl)  |  hash function, hash and link to the JSON file |
| `Markdown`  | a structured Markdown mostly encoded as UTF8 string  |
| `0x1345ABCD...`  | a **literal** value, when the returned value is expected to equal some specific bytes |


---


### Singleton

A **Singleton** key refers to a simple key. It is constructed using `bytes32(keccak256("KeyName"))`,

Below is an example of a Singleton key type:

```json
{
    "name": "MyKeyName",
    "key": "0x35e6950bc8d21a1699e58328a3c4066df5803bb0b570d0150cb3819288e764b2",
    "keyType": "Singleton",
    "valueType": "...",
    "valueContent": "..."
}
```

`keccak256("MyKeyName")` = `0x`**`35e6950bc8d21a1699e58328a3c4066df5803bb0b570d0150cb3819288e764b2`**

### Array

An array of elements, where each element has the same `valueType`.

> *The advantage of the `keyType` Array over a standard array of elements like `address[]`, is that the amount of elements that can be stored is unlimited.
> Storing an encoded array as a value, will require a set amount of gas, which can exceed the block gas limit.*

**Requirements:**

A key of **Array** type MUST have the following requirements:

- The `name` of the key MUST have a `[]` (square brackets).
- The `key` itself MUST be the keccak256 hash digest of the **full key `name`, including the square brackets `[]`**
- The value stored under the full key hash MUST contain the total number of elements (= array length). It MUST be updated every time a new element is added to the array.
- The value stored under the full key hash **MUST be stored as `uint256`** (32 bytes long, padded left with leading zeros).

**Construction:**

For the **Array** `keyType`, the initial `key` contains the total number of elements stored in the Array (= array length). It is constructed using `bytes32(keccak256(KeyName))`.

Each Array element can be accessed through its own `key`. The `key` of an Array element consists of `bytes16(keccak256(KeyName)) + bytes16(uint128(ArrayElementIndex))`, where:
- `bytes16(keccak256(KeyName))` = The first 16 bytes are the keccak256 hash of the full Array key `name` (including the `[]`) (e.g.: `LSP3IssuedAssets[]`)
- `bytes16(uint128(ArrayElementIndex))` = the position (= index) of the element in the array (**NB**: elements index access start at `0`)

*example:*

Below is an example for the **Array** key named `LSP3IssuedAssets[]`.

- element number: key: `0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0`, value: `0x0000000000000000000000000000000000000000000000000000000000000002` (2 elements)
- element 1: key: `0x3a47ab5bd3a594c3a8995f8fa58d087600000000000000000000000000000000`, value: `0x123...` (element 0)
- element 2: key: `0x3a47ab5bd3a594c3a8995f8fa58d087600000000000000000000000000000001`, value: `0x321...` (element 1)
...

```json
{
    "name": "LSP3IssuedAssets[]",
    "key": "0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0",
    "keyType": "Array",
    "valueType": "address", // describes the type of each elements
    "valueContent": "Address" // describes the value of each elements
}
```

```solidity
key: keccak256('LSP3IssuedAssets[]') = 0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0
value: uint256 (array length) e.g. 0x0000000000000000000000000000000000000000000000000000000000000002

// array items

// element 0
key: 0x3a47ab5bd3a594c3a8995f8fa58d087600000000000000000000000000000000
value: 0xcafecafecafecafecafecafecafecafecafecafe

// element 1
key: 0x3a47ab5bd3a594c3a8995f8fa58d087600000000000000000000000000000001
value: 0xcafecafecafecafecafecafecafecafecafecafe
```

### Mapping

A **Mapping** key is constructed using `bytes16(keccak256("FirstWord")) + bytes12(0) + bytes4(keccak256("SecondWord"))`.  

*example:*

```json
{
    "name": "FirstWord:SecondWord",
    "key": "0xeafec4d89fa9619884b6b89135626455000000000000000000000000abe425d6",
    "keyType": "Mapping",
    "valueType": "...",
    "valueContent": "..."
}
```


- `keccak256("FirstWord")` = `0x`**`f49648de3734d6c5458244ad87c893b5`**`0e6367d2cfa4670eddec109d1fc952e0` (**first 16 bytes** of the hash)
- `keccak256("SecondWord")` = `0x`**`53022d37`**`21822ca6332135de9e7b98f9a82eb1051d3095d2e259b45149c9b634` (**first 4 bytes** of the hash)


### Bytes20Mapping

**Bytes20Mapping** could be used to map words to `bytes20` long data, such as `addresses`. Such key type can be useful when the second word in the mapping is too long and makes the key greater than 32 bytes.

A **Bytes20Mapping** mapping key is constructed using `bytes8(keccak256(FirstWord)) + bytes4(0) + bytes20(address)`.

*e.g.:* `MyCoolAddress:<address>` > `0x22496f48a493035f 00000000 cafecafecafecafecafecafecafecafecafecafe`

```json
{
    "name": "MyCoolAddress:cafecafecafecafecafecafecafecafecafecafe",
    "key": "0x22496f48a493035f00000000cafecafecafecafecafecafecafecafecafecafe",
    "keyType": "Bytes20Mapping",
    "valueType": "...",
    "valueContent": "..."
}
```

### Bytes20MappingWithGrouping

A **Bytes20MappingWithGrouping** key could be used to map two words to addresses, or other bytes 20 long data.
This key is constructed using `bytes4(keccak256(FirstWord)) + bytes4(0) + bytes2(keccak256(SecondWord)) + bytes2(0) + bytes20(address)`,     

e.g. `AddressPermissions:Permissions:<address>` > `0x4b80742d 00000000 eced 0000 cafecafecafecafecafecafecafecafecafecafe`.

Below is an example of a mapping key type:

```json
{
    "name": "AddressPermissions:Permissions:cafecafecafecafecafecafecafecafecafecafe",
    "key": "0x4b80742d0000000082ac0000cafecafecafecafecafecafecafecafecafecafe",
    "keyType": "Bytes20MappingWithGrouping",
    "valueType": "...",
    "valueContent": "..."
}
```

### BitArray

A BitArray describes an array that contains a sequence of bits (`1`s and `0`s).

Each bit can be either set (`1`) or not (`0`). The point of the BitArray `valueContent` is that there are only two possible values, so they can be stored in one bit.

A BitArray can be used as a mapping of values to states (on/off, allowed/disallowed, locked/unlocked, valid/invalid), where the max number of available values that can be mapped is *n* bits.

*example:*

The example shows how a `BitArray` value can be read and interpreted.

```json
{
    "name": "MyPermissions",
    "key": "0xaacedf1d8b2cc85524a881760315208fb03c6c26538760922d6b9dee915fd66a",
    "keyType": "Singleton",
    "valueType": "bytes1",
    "valueContent": "BitArray"
}
```

As the key `name` suggests, it defines a list of (user-defined) permissions, where each permission maps to a single bit at position `n`.
- When a bit at position `n` is set (`1`), the permission defined at position `n` will be set.
- When a bit at position `n` is not set (`0`), the permission defined at position `n` will not be set.

Since the `valueType` is of type `bytes1`, this key can hold 8 user-defined permissions.

For instance, for the following permissions:

| `SIGN` | `TRANSFER VALUE` | `DEPLOY` | `DELEGATE CALL` | `STATIC CALL` | `CALL` | `SET DATA` | `CHANGE OWNER` |
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| `0` / `1` | `0` / `1` | `0` / `1` | `0` / `1` | `0` / `1` | `0` / `1` | `0` / `1` | `0` / `1` |

Setting only the permission `SET DATA` will result in the following `bytes1` value (and its binary representation)

```
> Permission SET DATA = permissions set to 0000 0010
`0x02` (4 in decimal)
```

| `SIGN` | `TRANSFER VALUE` | `DEPLOY` | `DELEGATE CALL` | `STATIC CALL` | `CALL` | `SET DATA` | `CHANGE OWNER` |
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| `0` | `0` | `0` | `0` | `0` | `0` | `1` | `0` |

Setting multiple permissions like `TRANSFER VALUE + CALL + SET DATA` will result in the following `bytes1` value (and its binary representation)

```
> Permissions set to 0100 0110
`0x46` (70 in decimal)

```

| `SIGN` | `TRANSFER VALUE` | `DEPLOY` | `DELEGATE CALL` | `STATIC CALL` | `CALL` | `SET DATA` | `CHANGE OWNER` |
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| `0` | `1` | `0` | `0` | `0` | `1` | `1` | `0` |

The idea is to always read the value of a **BitArray** key as binary digits, while its content is always written as a `bytes1` (in hex) in the ERC725Y contract storage.

### AssetURL

The content is bytes containing the following format:
`bytes4(keccack256('hashFunction'))` + `bytes32(keccack256(assetBytes))` + `utf8ToHex('AssetURL')`

Known hash functions:

- `0x8019f9b1`: keccak256('keccak256(bytes)')

*example:*

The following shows an example of how to encode an AssetURL:

```js
const hashFunction = web3.utils.keccak256('keccak256(bytes)').substr(0, 10)
> '0x8019f9b1'

// Local file read
let hash = web3.utils.keccak256(fs.readFileSync('./file.png'))
> '0xd47cf10786205bb08ce508e91c424d413d0f6c48e24dbfde2920d16a9561a723'

// or browser fetch
const assetBuffer = await fetch('https://ipfs.lukso.network/ipfs/QmW4nUNy3vtvr3DxZHuLfSLnhzKMe2WmgsUsEGPPFh8Ztp').then(async (response) => {
    return response.arrayBuffer().then((buffer) => new Uint8Array(buffer));
  });

hash = web3.utils.keccak256(assetBuffer)
> '0xd47cf10786205bb08ce508e91c424d413d0f6c48e24dbfde2920d16a9561a723'

// store the asset file anywhere and encode the URL
const url = web3.utils.utf8ToHex('ipfs://QmW4nUNy3vtvr3DxZHuLfSLnhzKMe2WmgsUsEGPPFh8Ztp')
> '0x697066733a2f2f516d57346e554e7933767476723344785a48754c66534c6e687a4b4d6532576d67735573454750504668385a7470'

// final result (to be stored on chain)
const AssetURL = hashFunction + hash.substring(2) + url.substring(2)
                 ^              ^                   ^
                 0x8019f9b1   + d47cf10786205bb0... + 697066733a2f2...

// structure of the AssetURL
0x8019f9b1 +       d47cf10786205bb08ce508e91c424d413d0f6c48e24dbfde2920d16a9561a723 + 697066733a2f2f516d57346e554e7933767476723344785a48754c66534c6e687a4b4d6532576d67735573454750504668385a7470
^                  ^                                                                  ^
keccak256(utf8)    hash                                                               encoded URL

// example value
0x8019f9b1d47cf10786205bb08ce508e91c424d413d0f6c48e24dbfde2920d16a9561a723697066733a2f2f516d57346e554e7933767476723344785a48754c66534c6e687a4b4d6532576d67735573454750504668385a7470
```

### JSONURL

The content is bytes containing the following format:     
`bytes4(keccak256('hashFunction'))` + `bytes32(keccak256(JSON.stringify(JSON)))` + `utf8ToHex('JSONURL')`

Known hash functions:

- `0x6f357c6a`: keccak256('keccak256(utf8)')

*example:*

The following shows an example of how to encode a JSON object:

```js
const json = JSON.stringify({
    myProperty: 'is a string',
    anotherProperty: {
        sdfsdf: 123456
    }
})

const hashFunction = web3.utils.keccak256('keccak256(utf8)').substr(0, 10)
> '0x6f357c6a'

const hash = web3.utils.keccak256(json)
> '0x820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361'

// store the JSON anywhere and encode the URL
const url = web3.utils.utf8ToHex('ifps://QmYr1VJLwerg6pEoscdhVGugo39pa6rycEZLjtRPDfW84UAx')
> '0x696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178'

// final result (to be stored on chain)
const JSONURL = hashFunction + hash.substring(2) + url.substring(2)
                ^              ^                   ^
                0x6f357c6a   + 820464ddfac1be... + 696670733a2f2...
              
// structure of the JSONURL
0x6f357c6a +       820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361 + 696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178
^                  ^                                                                  ^
keccak256(utf8)    hash                                                               encoded URL

// example value
0x6f357c6a820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178


```

To decode, reverse the process:

```js

const data = myContract.methods.getData('0xsomeKey..').call()
> '0x6f357c6a820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178'

// slice the bytes to get its pieces
const hashFunction = data.slice(0, 10)
const hash = '0x' + data.slice(0, 74)
const url = '0x' + data.slice(74)

// check if it uses keccak256
if(hashFunction === '0x6f357c6a') {
    // download the json file
    const json = await ipfsMini.catJSON(
        web3.utils.hexToUtf8(url).replace('ipfs://','')
    );

    // compare hashes
    if(web3.utils.keccak256(JSON.stringify(json)) === hash)
        return
            ? json
            : false
}
```


## Rationale

The structure of the key value layout as JSON allows interfaces to auto decode these key values as they will know how to decode them.

## Implementation

Below is an example of an ERC725Y JSON Schema containing 3 x ERC725Y keys.

Using such schema allows interfaces to auto decode and interpret the values retrieved from the ERC725Y key-value store.

```json
[
    {
        "name": "SupportedStandards:LSP3UniversalProfile",
        "key": "0xeafec4d89fa9619884b6b89135626455000000000000000000000000abe425d6",
        "keyType": "Mapping",
        "valueType": "bytes4",
        "valueContent": "0xabe425d6"
    },
    {
        "name": "LSP3Profile",
        "key": "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5",
        "keyType": "Singleton",
        "valueType": "bytes",
        "valueContent": "JSONURL"
    },
    {
        "name": "LSP3IssuedAssets[]",
        "key": "0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0",
        "keyType": "Array",
        "valueType": "address",
        "valueContent": "Address"
    }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
