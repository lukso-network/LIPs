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

This schema describes how a set of [ERC725Y](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) key values can be described.

## Abstract

ERC725Y allow smart contracts to store key value stores (`bytes32` > `bytes`).
This schema allows to standardize the key values that can be used in ERC725Y sub standards.

## Motivation

This schema defines a way to make those key values automatically parsable, so a interface or smart contract knows how to read and interact with them. 

This schema is for example used in [ERC725](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md) based smart contracts like
[LSP3-UniversalProfile](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-3-UniversalProfile.md) and [LSP4-DigitalCertificate](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-4-DigitalCertificate.md).


## Specification

To make ERC725Y keys readable we define the following key value types:   
(Note: this set is not complete yet, and should be extended over time)

- `name`: Describes the name of the key, SHOULD compromise of the Standards name + sub type. e.g: `LSP2Name`
- `key`: the keccak256 hash of the name. This is the actual key that MUST be retrievable via `ERC725Y.getData(bytes32 key)`. e.g: `keccack256('LSP2Name') = 0xf9e26448acc9f20625c059a95279675b8f58ba4f06d262f83a32b4dd35dee019`
- `keyType`: Types that determine how the values should be interpreted. Valid types are:
    - [`Singleton`](#singleton): A simple key.
    - [`Array`](#array): An array spanning multiple ERC725Y keys.
    - [`Mapping`](#mapping): A key that maps two words.
    - [`Bytes20Mapping`](#bytes20mapping): A key that maps a word to an address.
    - [`Bytes20MappingWithGrouping`](#bytes20mappingwithgrouping): A key that maps a word, to a grouping word to an address.
- `valueType`: The type the content MUST be decoded with.
    - `string`: The bytes are a UTF8 encoded string
    - `address`: The bytes are an 20 bytes address
    - `uint256`: The bytes are a uint256
    - `bytes32`: The bytes are a 32 bytes
    - `bytes`: The bytes are a bytes
    - `string[]`: The bytes are a UTF8 encoded string array
    - `address[]`: The bytes are an 20 bytes address array
    - `uint256[]`: The bytes are a uint256 array
    - `bytes[]`: The bytes are a bytes array
    - `bytesN[]`: The bytes are a N bytes
- `valueContent`: The content in the returned value. Valid values are:
    - `Bytes`: The content are bytes. 
    - `BytesN`: The content are bytes with length N.
    - `Number`: The content is a number.
    - `String`: The content is a UTF8 string.
    - `Address`: The content is an address.
    - `Keccak256`: The content is an keccak256 32 bytes hash.
    - [`AssetURL`](#asseturl): The content contains the hash function, hash and link to the asset file.
    - [`JSONURL`](#jsonurl): The content contains the hash function, hash and link to the JSON file.
    - `URL`: The content is an URL encoded as UTF8 string.
    - `Markdown`: The content is structured Markdown mostly encoded as UTF8 string.
    - `0x1345ABCD...`: If the value content are specific bytes, than the returned value is expected to equal those bytes.
  
### Singleton

A simple key is constructed using `bytes32(keccak256(KeyName))`,

Below is an example of a Singleton key type:

```js
{
    "name": "MyKeyName",
    "key": "0x35e6950bc8d21a1699e58328a3c4066df5803bb0b570d0150cb3819288e764b2",
    "keyType": "Singleton",
    "valueContent": mixed,
    "valueType": mixed
}
```

### Array

An initial key of an array containing the array length constructed using `bytes32(keccak256(KeyName))`.
Subsequent keys consist of `bytes16(keccak256(KeyName)) + bytes16(uint128(ArrayElementIndex))`.

*The advantage of the `keyType` Array over using simple array elements like `address[]`, is that the amount of elements that can be stored is unlimited.
Storing an encoded array as a value, will reuqire a set amount of gas, which can exceed the block gas limit.*

If you require multiple keys of the same key type they MUST be defined as follows:

- The keytype name MUST have a `[]` add and then hashed
- The key hash MUST contain the number of all elements, and is required to be updated when a new key element is added.

For all other elements:

- The first 16 bytes are the first 16 bytes of the key hash
- The second 16 bytes is a `uint128` of the number of the element
- Elements start at number `0`

This would looks as follows for `LSP3IssuedAssets[]`:

- element number: key: `0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0`, value: `0x0000000000000000000000000000000000000000000000000000000000000002` (2 elements)
- element 1: key: `0x3a47ab5bd3a594c3a8995f8fa58d087600000000000000000000000000000000`, value: `0x123...` (element 0)
- element 2: key: `0x3a47ab5bd3a594c3a8995f8fa58d087600000000000000000000000000000001`, value: `0x321...` (element 1)
...


Below is an example of an Array key type:

```json
{
    "name": "LSP3IssuedAssets[]",
    "key": "0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0",
    "keyType": "Array",
    "valueContent": "Address", // describes the content of the elements
    "valueType": "address" // describes the content of the elements
}
```

#### Example

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

A mapping key is constructed using `bytes16(keccak256(FirstWord)) + bytes12(0) + bytes4(keccak256(LastWord))`,    

Below is an example of a mapping key type:

```js
{
    "name": "SupportedStandards:ERC725Account",
    "key": "0xeafec4d89fa9619884b6b89135626455000000000000000000000000afdeb5d6",
    "keyType": "Mapping",
    "valueContent": mixed,
    "valueType": mixed
}
```

### Bytes20Mapping

Bytes 20 mapping could be used to map words to addresses, or other bytes 20 long data.
An bytes mapping key is constructed using `bytes8(keccak256(FirstWord)) + bytes4(0) + bytes20(address)`.

e.g. `MyCoolAddress:<address>` > `0x22496f48a493035f 00000000 cafecafecafecafecafecafecafecafecafecafe`.

Below is an example of an bytes20 mapping key type:

```js
{
    "name": "MyCoolAddress:0xcafecafecafecafecafecafecafecafecafecafe",
    "key": "0x22496f48a493035f00000000cafecafecafecafecafecafecafecafecafecafe",
    "keyType": "Bytes20Mapping",
    "valueContent": mixed,
    "valueType": mixed
}
```

### Bytes20MappingWithGrouping

Bytes 20 mapping with grouping could be used to map two words to addresses, or other bytes 20 long data.
A mapping key, constructed using `bytes4(keccak256(FirstWord)) + bytes4(0) + bytes2(keccak256(SecondWord)) + bytes2(0) + bytes20(address)`,     

e.g. `AddressPermissions:Permissions:<address>` > `0x4b80742d 00000000 eced 0000 cafecafecafecafecafecafecafecafecafecafe`.

Below is an example of a mapping key type:

```js
{
    "name": "AddressPermissions:Permissions:cafecafecafecafecafecafecafecafecafecafe",
    "key": "0x4b80742d0000000082ac0000cafecafecafecafecafecafecafecafecafecafe",
    "keyType": "Bytes20MappingWithGrouping",
    "valueContent": mixed,
    "valueType": mixed
}
```

### AssetURL

The content is bytes containing the following format:
`bytes4(keccack256('hashFunction'))` + `bytes32(keccack256(assetBytes))` + `utf8ToHex('AssetURL')`

Known hash functions:

- `0x8019f9b1`: keccak256('keccak256(bytes)')

#### Example

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
`bytes4(keccack256('hashFunction'))` + `bytes32(keccack256(JSON.stringify(JSON)))` + `utf8ToHex('JSONURL')`

Known hash functions:

- `0x6f357c6a`: keccak256('keccak256(utf8)')

#### Example

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
`keyType` always describes *how* a key MUST be treated.    
and `valueType` describes how the value MUST be decoded. And `value` always describes *how* a value SHOULD be treated.

## Example

To allow interfaces to auto decode an ERC725Y key value store using the ERC725Y JSON Schema:

```json
[
    {
        "name": "SupportedStandards:ERC725Account",
        "key": "0xeafec4d89fa9619884b6b89135626455000000000000000000000000afdeb5d6",
        "keyType": "Mapping",
        "valueContent": "0xafdeb5d6",
        "valueType": "bytes"
    },
    {
        "name": "LSP3Profile",
        "key": "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5",
        "keyType": "Singleton",
        "valueContent": "JSONURL",
        "valueType": "bytes"
    },
    {
        "name": "LSP3IssuedAssets[]",
        "key": "0x3a47ab5bd3a594c3a8995f8fa58d0876c96819ca4516bd76100c92462f2f9dc0",
        "keyType": "Array",
        "valueContent": "Address",
        "valueType": "address",
    }
]
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
