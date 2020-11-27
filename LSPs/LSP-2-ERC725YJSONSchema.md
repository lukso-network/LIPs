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
    - `Array`: Determines that the value of this key is the array length, and subsequent keys consist of `bytes16(keyHash) + uint128(arrayElementIndex)`.
- `valueContent`: The content in the returned value. Valid values are:
    - `Number`: The content is a number.
    - `String`: The content is a UTF8 string.
    - `Address`: The content is an address.
    - `Keccak256`: The content is an keccak256 32 bytes hash.
    - `AssetURL`: The content is bytes containing the following format:
        - `bytes4(keccak256('hashFunctionName'))` + `bytes32(assetHash)` + `utf8ToHex('AssetURL')`
        - Hash function bytes4 see below
    - `JSONURL`: The content is bytes containing the following format:
        - `0x6f357c6a` + `bytes32(jsonHash)` + `utf8ToHex('JSONURL')`
        - Hash function bytes4 see below
    - `URL`: The content is an URL encoded as UTF8 string.
    - `Markdown`: The content is structured Markdown mostly encoded as UTF8 string.
    - `0x1345ABCD...`: If the value content are specific bytes, than the returned value is expected to equal those bytes.
- `valueType`: The type the content MUST be decoded with.
    - `string`: The bytes are a UTF8 encoded string
    - `address`: The bytes are an 20 bytes address
    - `uint256`: The bytes are a uint256
    - `bytes32`: The bytes are a 32 bytes
    - `bytes`: The bytes are a bytes
    - `string[]`: The bytes are a UTF8 encoded string array
    - `address[]`: The bytes are an 20 bytes address array
    - `uint256[]`: The bytes are a uint256 array
    - `bytes32[]`: The bytes are a 32 bytes array
    - `bytes[]`: The bytes are a bytes array
    
Special key types exist for **array elements**:

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

#### JSONURL Example

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

// store the JSON anywhere and encode the URL
> web3.utils.utf8ToHex('ifps://QmYr1VJLwerg6pEoscdhVGugo39pa6rycEZLjtRPDfW84UAx')
'0x696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178'


// Generated JSONURL
0x6f357c6a +       820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361 + 696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178
^                  ^                                                                  ^
keccak256(utf8)    hash                                                               encoded URL

```

To decode, reverse the process:

```js

let data = myContract.methods.getData('0xsomeKey..').call()
> '0x6f357c6a820464ddfac1bec070cc14a8daf04129871d458f2ca94368aae8391311af6361696670733a2f2f516d597231564a4c776572673670456f73636468564775676f3339706136727963455a4c6a7452504466573834554178'

// slice the bytes to get its pieces
let hashFunction = data.slice(0, 10)
let hash = '0x' + data.slice(0, 74)
let url = '0x' + data.slice(74)

// check if it uses keccak256
if(hashFunction === '0xb7845733') {
    // download the json file
    let json = await ipfsMini.catJSON(
        web3.utils.hexToUtf8(url).replace('ipfs://','')
    );

    // compare hashes
    if(web3.utils.keccak256(JSON.stringify(json)) === hash)
        return
            ? json
            : false
}
```


### Array

*The advantage of the `keyType` Array over using simple array elements like `address[]`, is that the amount of elements that can be stored is unlimited.
Storing an encoded array as a value, will reuqire a set amount of gas, which can exceed the block gas limit.*

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
    "valueContent": "Number",
    "valueType": "uint256",
    "elementValueContent": "Address",
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
        "valueContent": "URL",
        "valueType": "string"
    },
    {
        "name": "LSP2IssuedAssets[]",
        "key": "0xb8c4a0b76ed8454e098b20a987a980e69abe3b1a88567ae5472af5f863f8c8f9",
        "keyType": "Array",
        "valueContent": "Number",
        "valueType": "uint256",
        "elementValueContent": "Address",
        "elementValueType": "address"
    }
]
```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
