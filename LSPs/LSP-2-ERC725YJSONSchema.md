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

**Table of Content**

- [Simple Summary](#simple-summary)
- [Abstract](#abstract)
- [Motivation](#motivation)
- [Specification](#specification)
  * [Data Key Name](#data-key-name)
  * [Data Key Hash](#data-key-hash)
  * [`keyType`](#-keytype-)
  * [`valueType`](#-valuetype-)
  * [`valueContent`](#-valuecontent-)
    + [valueContent in cases where `valueType` or `keyType` is an array](#valuecontent-in-cases-where--valuetype--or--keytype--is-an-array)
- [keyType](#keytype)
  * [Singleton](#singleton)
  * [Array](#array)
  * [Mapping](#mapping)
  * [MappingWithGrouping](#mappingwithgrouping)
- [ValueType](#valuetype)
  * [bytes[CompactBytesArray]](#bytes-compactbytesarray-)
  * [bytesN[CompactBytesArray]](#bytesn-compactbytesarray-)
  * [Tuples of `valueType`](#tuples-of--valuetype-)
- [ValueContent](#valuecontent)
  * [BitArray](#bitarray)
  * [AssetURL](#asseturl)
  * [JSONURL](#jsonurl)
- [Rationale](#rationale)
- [Implementation](#implementation)
- [Copyright](#copyright)

## Simple Summary

This schema defines how a single [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) data key-value pair can be described. It can be used as an abstract structure over the storage of an ERC725Y smart contract.

## Abstract

ERC725Y enables storing any data in a smart contract as `bytes32 => bytes` data key-value pairs.

Although this improves interaction with the data stored, it remains difficult to understand the layout of the contract storage. This is because both the data key and the value are addressed in raw bytes.

This schema allows to standardize those data keys and values so that they can be more easily accessed and interpreted. It can be used to create ERC725Y sub-standards, made of pre-defined sets of ERC725Y data keys.

## Motivation

A schema defines a blueprint for how a data store is constructed.

In the context of smart contracts, it can offer a better view of how the data is organised and structured within the contract storage.

Using a standardised schema over ERC725Y enables those data keys and values to be easily readable and automatically parsable. Contracts and interfaces can know how to read and interact with the storage of an ERC725Y smart contract.

The advantage of such schema is to allow interfaces or smart contracts to better decode (read, parse and interpret) the data stored in an ERC725Y contract. It is less error-prone due to knowing data types upfront. On the other hand, it also enables interfaces and contracts to know how to correctly encode data, before being set on an ERC725Y contract.

This schema is for example used in [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) based smart contracts like
[LSP3-UniversalProfile](./LSP-3-UniversalProfile-Metadata.md#implementation) and [LSP4-DigitalAsset-Metadata](./LSP-4-DigitalAsset-Metadata.md#implementation).

## Specification

> **Note:** described sets might not yet be complete, as they could be extended over time.

To make ERC725Y data keys readable, we describe a data key-value pair as a JSON object containing the following entries:

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

| Title                                 | Description                   |
|:--------------------------------------|:------------------------------|
|[`name`](#name)                        | the name of the data key      |
|[`key`](#key)                          | the **unique identifier** of the data key |
|[`keyType`](#keyType)                  | *How* the data key must be treated <hr> [`Singleton`](#Singleton) <br> [`Array`](#Array) <br> [`Mapping`](#mapping) <br> [`MappingWithGrouping`](#mappingwithgrouping) |
|[`valueType`](#valueType)              | *How* a value MUST be decoded <hr> `bool` <br> `string` <br> `address` <br> `uintN` <br> `intN` <br> `bytesN` <br> `bytes` <br> `uintN[]` <br> `intN[]` <br> `string[]` <br> `address[]` <br> `bytes[]` <br> [`bytes[CompactBytesArray]`](#bytescompactbytesarray) <br> [`bytesN[CompactBytesArray]`](#bytesn-compactbytesarray-) <br> Tuple: [`(valueType1,valueType2,...)`](#tuples-of--valuetype-) |
|[`valueContent`](#valueContent)| *How* a value SHOULD be interpreted <hr> `Boolean` <br> `String` <br> `Address` <br> `Number` <br> `BytesN` <br> `Bytes` <br> `Keccak256` <br> [`BitArray`](#BitArray) <br> `URL` <br> [`AssetURL`](#AssetURL) <br> [`JSONURL`](#JSONURL) <br> `Markdown` <br> `Literal` (*e.g.:* `0x1345ABCD...`) |

### Data Key Name

The `name` is the human-readable format of an ERC725Y data key. It's the basis which is used to generate the `32 bytes` key hash. Names can be arbitrarily chosen, but SHOULD highlight the meaning of content behind the data value.

In scenarios where an ERC725Y data key is part of an LSP Standard, the data key `name` SHOULD be comprised of the following: `LSP{N}{KeyName}`, where

- `LSP`: abbreviation for **L**UKSO **S**tandards **P**roposal.
- `N`: the **Standard Number** this data key refers to.
- `KeyName`: base of the data key name. Should represent the meaning of a value stored behind the data key.

*e.g.:* `MyCustomKeyName` or `LSP4TokenName`


### Data Key Hash

The `key` is a `bytes32` value that acts as the **unique identifier** for the data key, and is what is used to retrive the data value from a ERC725Y smart contract via `ERC725Y.getData(bytes32 dataKey)` or `ERC725Y.getData(bytes32[] dataKeys)`.

Usually `keccak256` hashing algorithm is used to generate the `bytes32` data key. However, *how* the data key is constructed varies, depending on the `keyType`.


### `keyType`

The `keyType` determines the format of the data key(s).

| `keyType`                     | Description                           | Example                        |
|-------------------------------|---------------------------------------|--------------------------------|
| [`Singleton`](#singleton)     | A simple data key                     | `bytes32(keccak256("MyKeyName"))`<br> --- <br> `MyKeyName` -->  `0x35e6950bc8d21a1699e58328a3c4066df5803bb0b570d0150cb3819288e764b2` |
| [`Array`](#array)             | An array spanning multiple ERC725Y data keys  | `bytes32(keccak256("MyKeyName[]"))` <br> --- <br> `MyKeyName[]` -->   `0x24f6297f3abd5a8b82f1a48cee167cdecef40aa98fbf14534ea3539f66ca834c`|
| [`Mapping`](#mapping)         | A data key that consist of 2 sections, where the last section can also be a dynamic value         | `bytes10(keccak256("MyKeyName"))` +<br>`bytes2(0)` +<br>`bytes20(keccak256("MyMapName") or <mixed type>)` <br> --- <br> `MyKeyName:MyMapName` -->  `0x35e6950bc8d21a1699e5000075060e3cd7d40450e94d415fb5992ced9ad8f058` |
| [`MappingWithGrouping`](#mappingwithgrouping)  | A data key that consist of 3 sections, where the last two sections can also be dynamic values | `bytes6(keccak256("MyKeyName"))` +<br>`bytes4(keccak256("MyMapName") or <mixed type>)` +<br>`bytes2(0)` +<br>`bytes20(keccak256("MySubMapName") or <mixed type>)` <br> --- <br> `MyKeyName:MyMapName:<address>` -->  `0x35e6950bc8d275060e3c0000cafecafecafecafecafecafecafecafecafecafe` |


### `valueType`

Describes the underlying data type(s) of a value stored under a specific ERC725Y data key. It refers to the type for the smart contract language like [Solidity](https://docs.soliditylang.org).

The `valueType` is relevant for interfaces to know how a value MUST be encoded/decoded. This include:

- how to decode a value fetched via `ERC725Y.getData(...)`
- how to encode a value that needs to be set via `ERC725Y.setData(...)`.

The `valueType` can also be useful for typecasting. It enables contracts or interfaces to know how to manipulate the data and the limitations behind its type. To illustrate, an interface could know that it cannot set the value to `300` if its `valueType` is `uint8` (max `uint8` allowed = `255`).

| `valueType`                    | Description |
|--------------------------------|-------------|
| `bool`                      | a value as either **true** or **false** |
| `string`                       | an UTF8 encoded string  |
| `address`                      | a 20 bytes long address |
| `uintN`                        | an **unsigned** integer (= only positive number) of size `N`  |
| `bytesN`                       | a bytes value of **fixed-size** `N`, from `bytes1` up to `bytes32` |
| `bytes`                        | a bytes value of **dynamic-size** |
| `uintN[]`                      | an array of **signed** integers |
| `string[]`                     | an array of UTF8 encoded strings |
| `address[]`                    | an array of addresses |
| `bytes[]`                      | an array of dynamic size bytes  |
| `bytesN[]`                     | an array of fixed size bytes  |
| [`bytes[CompactBytesArray]`](#bytescompactbytesarray)     | a compacted bytes array of dynamic size bytes  |
| `bytesN[CompactBytesArray]`    | a compacted bytes array of fixed size bytes  |
| Tuple: [`(valueType1,valueType2,...)`](#tuples-of--valuetype-) | a tuple of valueTypes|

### `valueContent`

The `valueContent` of a LSP2 Schema describes how to interpret the content of the returned *decoded* value.

Knowing how to interpret the data retrieved under a data key is is the first step in understanding how to handle it. Interfaces can use the `valueContent` to adapt their behaviour or know how to display data fetched from an ERC725Y smart contract.

As an example, a string could be interpreted in multiple ways, such as:
- a single word, or a sequence of words (*e.g.: "My Custom Token Name"*)
- an URL (*e.g.: "ipfs://QmW4nUNy3vtvr3DxZHuLfSLnhzKMe2WmgsUsEGPPFh8Ztp"*)

Using the following two LSP2 schemas as examples:

```json
{
    "name": "MyProfileDescription",
    "key": "0xd0f1819a38d741fce6a6b74406251c521768033029cd254f0f5cd29ca58f3390",
    "keyType": "Singleton",
    "valueType": "string",
    "valueContent": "String"
},
{
    "name": "MyWebsite",
    "key": "0x449560072375b299bab5a695ea268c32c52d4820e4458e5f02f308c588e6715a",
    "keyType": "Singleton",
    "valueType": "string",
    "valueContent": "URL"
}
```

An interface could decode both values retrieved under these data keys as `string`, but:
- display the profile description as plain text.
- display the website URL as an external link.

Valid `valueContent` are:

| `valueContent`    | Description  |
|---|---|
| `Boolean`         | a boolean value (`true` or `false`) |
| `String`          | an UTF8 encoded string |
| `Address`         | an address |
| `Number`          | a Number (positive or negative, depending on the `keyType`)  |
| `BytesN`          | a bytes value of **fixed-size** `N`, from `bytes1` up to `bytes32`  |
| `Bytes`           | a bytes value of **dynamic-size** |
| `Keccak256`       | a 32 bytes long hash digest, obtained from the keccak256 hashing algorithm |
| `BitArray`        | an array of single `1` or `0` bits |
| `URL`             | an URL encoded as an UTF8 string |
| [`AssetURL`](#asseturl)   | The content contains the hash function, hash and link to the asset file  |
| [`JSONURL`](#jsonurl)     |  hash function, hash and link to the JSON file |
| `Markdown`        | a structured Markdown mostly encoded as UTF8 string  |
| `0x1345ABCD...`   | a **literal** value, when the returned value is expected to equal some specific bytes |

The `valueContent` field can also define a tuple of value contents (for instance, when the `valueType` is a tuple of types, as described above). In this case, each value content MUST be defined between parentheses. For instance: `(Bytes4,Number)`.

This is useful for decoding tools, to know how to interpret each value type in the tuple.

#### valueContent in cases where `valueType` or `keyType` is an array

In the case where:

a) the `keyType` is an [`Array`](#array).
b) _or_ the [`valueType`](#valuetype) is an array `[]` ([compacted](#bytescompactbytesarray) or not).

the `valueContent` describes how to interpret **each entry in the array**, not the whole array itself. Therefore the `valueContent` field MUST NOT include `[]`.

We can use the LSP2 Schema below as an example to better understand. This LSP2 Schema below defines a data key that represents a list of social media profiles related to a user.

Reading the ERC725Y storage using this data key will return an array of abi-encoded `string[]`. Therefore the interface should use the `valueType` to decode the retrieved value. The `valueContent` however defines that each string in the array must be interpreted as a social media URL.

```json
{
    "name": "MySocialMediaProfiles",
    "key": "0x161761c54f6b013a4b4cbb1247f703c94ae5dfe32081554ad861781f48d47513",
    "keyType": "Singleton",
    "valueType": "string[]",
    "valueContent": "URL"
}
```

## keyType

### Singleton

A **Singleton** data key refers to a simple data key. It is constructed using `bytes32(keccak256("KeyName"))`,

Below is an example of a Singleton data key type:

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

A data key of **Array** type MUST have the following requirements:

- The `name` of the data key MUST have a `[]` (square brackets) at the end.
- The `key` itself MUST be the keccak256 hash digest of the **full data key `name`, including the square brackets `[]`**
- The value stored under the full data key hash MUST contain the total number of elements (= array length). It MUST be updated every time a new element is added or removed to/from the array.
- The value stored under the full data key hash **MUST be stored as `uint256`** (32 bytes long, padded left with leading zeros).

**Construction:**

For the **Array** `keyType`, the initial `key` contains the total number of elements stored in the Array (= array length). It is constructed using `bytes32(keccak256(KeyName))`.

Each Array element can be accessed through its own `key`. The `key` of an Array element consists of `bytes16(keccak256(KeyName)) + bytes16(uint128(ArrayElementIndex))`, where:
- `bytes16(keccak256(KeyName))` = The first 16 bytes are the keccak256 hash of the full Array data key `name` (including the `[]`) (e.g.: `LSP12IssuedAssets[]`)
- `bytes16(uint128(ArrayElementIndex))` = the position (= index) of the element in the array (**NB**: elements index access start at `0`)

> **Note:** an ERC725Y data key of keyType Array can contain up to `max(uint128)` elements. This is because the index part of an Array keyType is 16 bytes long, which is equivalent to a `uint128`.

*example:*

Below is an example for the **Array** data key named `LSP12IssuedAssets[]`.

- total number of elements:
  - key: `0x7c8c3416d6cda87cd42c71ea1843df28ac4850354f988d55ee2eaa47b6dc05cd`,
  - value: `0x0000000000000000000000000000000000000000000000000000000000000002` (2 elements)
- element 1: key: `0x7c8c3416d6cda87cd42c71ea1843df2800000000000000000000000000000000`, value: `0x123...` (index 0)
- element 2: key: `0x7c8c3416d6cda87cd42c71ea1843df2800000000000000000000000000000001`, value: `0x321...` (index 1)
...

```json
{
    "name": "LSP12IssuedAssets[]",
    "key": "0x7c8c3416d6cda87cd42c71ea1843df28ac4850354f988d55ee2eaa47b6dc05cd",
    "keyType": "Array",
    "valueType": "address", // describes the type of each element
    "valueContent": "Address" // describes the value of each element
}
```

```solidity
key: keccak256('LSP12IssuedAssets[]') = 0x7c8c3416d6cda87cd42c71ea1843df28ac4850354f988d55ee2eaa47b6dc05cd
value: uint256 (array length) e.g. 0x0000000000000000000000000000000000000000000000000000000000000002

// array items

// 1st element (index 0)
key: 0x7c8c3416d6cda87cd42c71ea1843df2800000000000000000000000000000000
value: 0xcafecafecafecafecafecafecafecafecafecafe

// 2nd element (index 1)
key: 0x7c8c3416d6cda87cd42c71ea1843df2800000000000000000000000000000001
value: 0xcafecafecafecafecafecafecafecafecafecafe
```

### Mapping

A **Mapping** data key is constructed using:

`bytes10(keccak256("MyKeyName"))` + `bytes2(0)` + `bytes20(keccak256("MyMapName") or <mixed type>)`.

`<mixed type>` can be one of `uint<M>`, `address`, `bool` or `bytes<M>` types.

- `uint<M>`, `bool`  will be left padded and left-cut, if larger than `20 bytes`.
- `bytes<M>` and `address` and static word hashes (`bytes32`) will be left padded, but right-cut, if larger than `20 bytes`.

*example:*

```js
// Examples:
MyKeyName:MyMapName // 0x35e6950bc8d21a1699e58328a3c4066df5803bb0b570d0150cb3819288e764b2 + 0x75060e3cd7d40450e94d415fb5992ced9ad8f058649e805951f558364152f9ed
"0x35e6950bc8d21a1699e5000075060e3cd7d40450e94d415fb5992ced9ad8f058"

MyKeyName:<address> // 0xcafecafecafecafecafecafecafecafecafecafe
"0x35e6950bc8d21a1699e50000cafecafecafecafecafecafecafecafecafecafe"

MyKeyName:<uint32> // 4081242941
"0x35e6950bc8d21a1699e5000000000000000000000000000000000000f342d33d"


MyKeyName:<bytes4> // 0xabcd1234
"0x35e6950bc8d21a1699e5000000000000000000000000000000000000abcd1234"

MyKeyName:<bytes32> // 0xaaaabbbbccccddddeeeeffff111122223333444455556666777788889999aaaa
"0x35e6950bc8d21a1699e50000aaaabbbbccccddddeeeeffff1111222233334444"

MyKeyName:<bool> // true
"0x35e6950bc8d21a1699e500000000000000000000000000000000000000000001"


// ERC725Y JSON schema
{
    "name": "FirstWord:<bytes4>",
    "key": "0xf49648de3734d6c545820000<bytes4>",
    "keyType": "Mapping",
    "valueType": "...",
    "valueContent": "..."
}
```

### MappingWithGrouping

A **MappingWithGrouping** data key is constructed using:

`bytes6(keccak256("MyKeyName"))` + `bytes4(keccak256("MyMapName") or <mixed type>)` + `bytes2(0)` + `bytes20(keccak256("MySubMapName") or <mixed type>)`.

`<mixed type>` can be one of `uint<M>`, `address`, `bool` or `bytes<M>` types.

- `uint<M>`, `bool`  will be left padded and left-cut, if it's larger than the max bytes of that section.
- `bytes<M>` and `address` and static word hashes (`bytes32`) will be left padded, but right-cut, if it's larger than the max bytes of that section.


e.g. `AddressPermissions:Permissions:<address>` > `0x4b80742de2bf 82acb363 0000 cafecafecafecafecafecafecafecafecafecafe`.

*example:*
```js
// Examples:
MyKeyName:MyMapName:MySubMapName // 0x35e6950bc8d21a1699e58328a3c4066df5803bb0b570d0150cb3819288e764b2 + 0x75060e3cd7d40450e94d415fb5992ced9ad8f058649e805951f558364152f9ed + 0x221cba00b07da22c3775601ffea5d3406df100dbb7b1c86cb2fe3739f0fe79a1
"0x35e6950bc8d275060e3c0000221cba00b07da22c3775601ffea5d3406df100db"

MyKeyName:MyMapName:<address>
"0x35e6950bc8d275060e3c0000cafecafecafecafecafecafecafecafecafecafe"

// For more examples static examples see the "Mapping" examples

MyKeyName:<bytes2>:<uint32> // ffff 4081242941
"0x35e6950bc8d20000ffff000000000000000000000000000000000000f342d33d"

MyKeyName:<address>:<address> // 0xabcdef11abcdef11abcdef11abcdef11ffffffff, 0xcafecafecafecafecafecafecafecafecafecafe
"0x35e6950bc8d2abcdef110000cafecafecafecafecafecafecafecafecafecafe"

MyKeyName:MyMapName:<bytes32> // 0xaaaabbbbccccddddeeeeffff111122223333444455556666777788889999aaaa
"0x35e6950bc8d275060e3c0000aaaabbbbccccddddeeeeffff1111222233334444"

MyKeyName:<bytes32>:<bool> // 0xaaaabbbbccccddddeeeeffff111122223333444455556666777788889999aaaa
"0x35e6950bc8d2aaaabbbb00000000000000000000000000000000000000000001"


// ERC725Y JSON schema
{
    "name": "AddressPermissions:Permissions:<address>",
    "key": "0x4b80742de2bf82acb3630000<address>",
    "keyType": "MappingWithGrouping",
    "valueType": "...",
    "valueContent": "..."
}
```


## ValueType

### bytes[CompactBytesArray]

A `bytes[CompactBytesArray]` represents an array of `bytes` values _encoded in a compact way_. The elements contained in the array are `bytes` values with different dynamic lengths.

In a compact bytes array of `bytes`, each element is prefixed with 2 bytes to specify its length.

For instance, `0xaabbccdd` in a `bytes[CompactBytesArray]` is encoded as `0x0004aabbccdd`, where:
- `0x0004` = `4` represents the total number of `bytes` in `0xaabbccdd`.
- `0xaabbccdd` is the actual value of the element.

> **Note:** the maximum length of each element is 65535, because two bytes (equivalent to a `uint16`) are used to store the length of each element and the maximum value of a `uint16` is 65535.


_example_

If we want to have the following bytes as elements in the compacted bytes array:

```
[
    0xaabbccdd,                     // element 1 length is 4 in hex:    0x04
    0xcafecafecafecafecafecafecafe, // element 2 length is 14 in hex:   0x0E
    0xff                            // element 3 length is 1 in hex:    0x01
]
```

The representation of these dynamic elements in a compacted bytes array would be:

`0x0004 aabbccdd 000e cafecafecafecafecafecafecafe 0001 ff` > `0x0004aabbccdd000ecafecafecafecafecafecafecafe0001ff`

### bytesN[CompactBytesArray]

Like a `bytes[CompactBytesArray]` a `bytesN[CompactBytesArray]` represents an array of `bytesN` values _encoded in a compact way_. The difference is that all the elements contained in the array have the same length `N`.

In a compact bytes array of `bytesN`, each element is prefixed with 1 byte that specify the length `N`.

For instance, in a `bytes8[CompactBytesArray]` an entry like `0x1122334455667788` is encoded as `0x00081122334455667788`, where:
- `0x0008` = `8` to represent that `0x1122334455667788` contains 8 bytes.
- `0x1122334455667788` is the actual value of the element.

> **Note:** because two bytes are used to store the length of each element, the maximum `N` length allowed is 65535 (two bytes are equivalent to the maximum value of a `uint16` is 65535)

_example:_

If we want to have the following `bytes8` elements encoded as a `bytes8[CompactBytesArray]`:

```
[
    0x1122334455667788,
    0xcafecafecafecafe,
    0xbeefbeefbeefbeef
]
```

We will obtain the following:

`0x0008 1122334455667788 0008 cafecafecafecafe 0008 beefbeefbeefbeef` > `0x000811223344556677880008cafecafecafecafe0008beefbeefbeefbeef`.

Where each byte `0x0008` in the final encoded value represents the length `N` of each element.

```
  vvvv                vvvv                vvvv
0x000811223344556677880008cafecafecafecafe0008beefbeefbeefbeef
```

### Tuples of `valueType`

The `valueType` can also be a **tuple of types**. In this case, the value stored under the ERC725Y data key is a mixture of multiple values concatenated together (the values are just _"glued together"_).

LSP2 tuples of `valueTypes` are different than tuples according to Solidity. **In Solidity, values defined in the tuple are padded. In the case of LSP2 they are not.**

In the case of tuple of `valueType`s, the types MUST be defined between parentheses, comma separated without parentheses.

```
(valueType1,valueType2,valueType3,...)
```

_example 1:_

For a schema that includes the following tuple as `valueType`.

```json
{
    "name": "...",
    "key": "...",
    "keyType": "...",
    "valueType": "(bytes4,bytes8)",
    "valueContent": "..."
}
```

And the following values:
- `bytes4` value = `0xcafecafe`
- `bytes8` value = `0xbeefbeefbeefbeef`

The tuple of `valueType` MUST be encoded as:

```
0xcafecafebeefbeefbeefbeef
```

_example 2:_

For a schema that includes the following tuple as `valueType`.

```json
{
    "name": "...",
    "key": "...",
    "keyType": "...",
    "valueType": "(bytes8,address)",
    "valueContent": "..."
}
```

And the following values:
- `bytes4` value = `0xca11ab1eca11ab1e`
- `bytes8` value = `0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5`

The tuple of `valueType` MUST be encoded as:

```
0xca11ab1eca11ab1e95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5
```

_example 3:_

For a schema that includes the following tuple as `valueType`.

```json
{
    "name": "...",
    "key": "...",
    "keyType": "...",
    "valueType": "(address,uint128,bytes4,bool,bytes)",
    "valueContent": "..."
}
```

And the following values:
- `address` value = `0x388C818CA8B9251b393131C08a736A67ccB19297`
- `uint128` value = the number `5,918` (`0x0000000000000000000000000000171E` in hex)
- `bytes4` value = `0xf00df00d`
- `bool` value = true (`0x01` in hex)
- `bytes` value = `0xcafecafecafecafecafecafecafe`

```
0x388C818CA8B9251b393131C08a736A67ccB192970000000000000000000000000000171Ef00df00d01afecafecafecafecafecafecafe
```


## ValueContent

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

As the data key `name` suggests, it defines a list of (user-defined) permissions, where each permission maps to a single bit at position `n`.
- When a bit at position `n` is set (`1`), the permission defined at position `n` will be set.
- When a bit at position `n` is not set (`0`), the permission defined at position `n` will not be set.

Since the `valueType` is of type `bytes1`, this data key can hold 8 user-defined permissions.

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

The idea is to always read the value of a **BitArray** data key as binary digits, while its content is always written as a `bytes1` (in hex) in the ERC725Y contract storage.

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

The structure of the data key value layout as JSON allows interfaces to auto decode these data key values as they will know how to decode them.

## Implementation

Below is an example of an ERC725Y JSON Schema containing 3 x ERC725Y data keys.

Using such schema allows interfaces to auto decode and interpret the values retrieved from the ERC725Y data key-value store.

```json
[
    {
        "name": "SupportedStandards:LSP3UniversalProfile",
        "key": "0xeafec4d89fa9619884b60000abe425d64acd861a49b8ddf5c0b6962110481f38",
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
        "name": "LSP12IssuedAssets[]",
        "key": "0x7c8c3416d6cda87cd42c71ea1843df28ac4850354f988d55ee2eaa47b6dc05cd",
        "keyType": "Array",
        "valueType": "address",
        "valueContent": "Address"
    }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
