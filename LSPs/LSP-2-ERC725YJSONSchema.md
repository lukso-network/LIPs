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
    - `Singleton`: A single key value store.
    - `Array`: Determines that the value of this key is the array length, and subsequent keys exist consisting of `bytes16(keyHash) + uint128(arrayElementIndex)`.
- `valueContent`: The content in the returned value. Valid values are:
    - `String`: The content is a generic UTF8 string.
    - `Address`: The content is an address.
    - `Keccak256`: The content is an keccak256 32 bytes hash.
    - `AssetURI`: The content is bytes containing the following format:
        - `bytes4(keccak256('hashFunctionName'))` + `bytes32(assetHash)` + `utf8ToHex('ipfs://QmQ2CN2VUdb5nVAz28R47aWP6BjDLPGNJaSBniBuZRs3Jt')`
        - Hash function bytes4 see below
    - `JSONURI`: The content is bytes containing the following format:
        - `bytes4(keccak256('hashFunctionName'))` + `bytes32(jsonHash)` + `utf8ToHex('ipfs://QmQ2CN2VUdb5nVAz28R47aWP6BjDLPGNJaSBniBuZRs3Jt')`
        - Hash function bytes4 see below
    - `URI`: The content is an URI encoded as UTF8 string.
    - `Markdown`: The content is structured Markdown mostly encoded as UTF8 string.
    - `0x134...`: If the value type is a specific hash than the return value is expected to equal that hash (This is used for specific e.g. `LSP4Type`).
- `valueType`: The type the content MUST be decoded with.
    - `string`: The bytes are a UTF8 encoded string
    - `address`: The bytes are an 20 bytes address
    - `uint256`: The bytes are a 32 bytes uint256
    - `bytes32`: The bytes are a 32 bytes
    - `bytes`: The bytes are a bytes
    
Special key types exist for **array elements**:

- `elementKey`: The first 16 bytes of the `key` hash of the root key.
- `elementKeyType`: The type of the element, MUST be `ArrayElement` for an array element.
- `elementValueContent`: Same as `valueContent` above.
- `elementValueType`: Same as `valueType` above.

Defined **hash functions**:

- `keccak256('keccak256(bytes)')` = `0x8019f9b1`
- `keccak256('keccak256(utf8)')` = `0x6f357c6a`


### Singleton

Below is an example of a Singleton key type:

```js
{
    "name": "LSPXyz",
    "key": "0x259e3e88c900103c8f1c9153b97074c18f74c5e4f27873f3a3ac6060dea44422", //keccak256(LSPXyz)
    "keyType": "Singleton",
    "valueContent": "String",
    "valueType": "string"
}
```

#### JSONURI Example

The follow shows an example of how to encode a JSON object:

```js
let json = JSON.stringify({
    myProperty: 'is a string',
    anotherProperty: {
        sdfsdf: 123456
    }
})

web3.utils.keccak256(json)
> '0x820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361'

// store the JSON anywhere and encode the URI
> web3.utils.utf8ToHex('ifps://QmYr1VJLwerg6pEoscdhVGugo39pa6rycEZLjtRPDfW84UAx')
'0x696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178'


// Generated JSONURI
0x6f357c6a +       820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361 + 696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178
^                  ^                                                                  ^
keccak256(utf8)   hash                                                               encoded URI

```

To decode, reverse the process:

```js

let data = myContract.methods.getData('0xsomeKey..').call()
> '0x6f357c6a820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178'

// slice the bytes to get its pieces
let hashFunction = data.slice(0, 10)
let hash = '0x' + data.slice(0, 74)
let uri = '0x' + data.slice(74)

// check if it uses keccak256
if(hashFunction === '0xb7845733') {
    // download the json file
    let json = await ipfsMini.catJSON(
        web3.utils.hexToUtf8(uri).replace('ipfs://','')
    );

    // compare hashes
    if(web3.utils.keccak256(JSON.stringify(json)) === hash)
        return
            ? json
            : false
}
```


### Array

If you require multiple keys of the same key type they MUST be defined as follows:

- The keytype name MUST have a `[]` add and then hashed
- The key hash MUST contain the number of all elements, and is required to be updated when a new key element is added.

For all other elements:
- The first 16 bytes are the first 16 bytes of the key hash
- The second 16 bytes is a `uint128` of the number of the element
- Elements start at number `0`

#### Example
This would looks as follows for `LSP2IssuedAssets[]`:
- element number: key: `0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9`, value: `0x0000000000000000000000000000000000000000000000000000000000000002` (2 elements)
- element 1: key: `0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000000`, value: `0x123...` (element 0)
- element 2: key: `0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000001`, value: `0x321...` (element 1)
...


Below is an example of an Array key type:

```js
{
    "name": "LSP2IssuedAssets[]",
    "key": "0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9",
    "keyType": "Array",
    "valueContent": "ArrayLength",
    "valueType": "uint256",
    "elementKey": "0xb8c4a0b76ed8454e098b20a987a980e6",
    "elementKeyType": "ArrayElement",
    "elementValue": "Address",
    "elementValueType": "address"
}
```

Example:
```solidity
key: keccak256('LSP2IssuedAssets[]') = 0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9
value: uint256 (array length) e.g. 0x0000000000000000000000000000000000000000000000000000000000000002

// array items

// element 0
key: 0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000000
value: 0xcafecafecafecafecafecafecafecafecafecafe

// element 1
key: 0xb8c4a0b76ed8454e098b20a987a980e600000000000000000000000000000001
value: 0xcafecafecafecafecafecafecafecafecafecafe
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
        "name": "LSP2Name",
        "key": "0xf9e26448acc9f20625c059a95279675b8f58ba4f06d262f83a32b4dd35dee019",
        "keyType": "Singleton",
        "valueContent": "String",
        "valueType": "string"
    },
    {
        "name": "LSP2Links",
        "key": "0xb95a64d66e66f5c0cd985e2c3cc93fbea7f9259eadbe81c3ab0ff4e68df564d6",
        "keyType": "Singleton",
        "valueContent": "URI",
        "valueType": "string"
    },
    {
        "name": "LSP2IssuedAssets[]",
        "key": "0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9",
        "keyType": "Array",
        "valueContent": "ArrayLength",
        "valueType": "uint256",
        "elementKey": "0xb8c4a0b76ed8454e098b20a987a980e6",
        "elementKeyType": "ArrayElement",
        "elementValueContent": "Address",
        "elementValueType": "address"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
