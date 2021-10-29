---
lip: 8
title: Identifiable Digital Asset
author: Claudio Weck <claudio@fanzone.media>, Fabian Vogelsteller <fabian@lukso.network>, Matthew Stevens <@mattgstevens>, Ankit Kumar <@ankitkumar9018>
discussions-to: https://discord.gg/E2rJPP4 (LUKSO), https://discord.gg/PQvJQtCV (FANZONE)
status: Draft
type: LSP
created: 2021-09-02
requires: LSP1, LSP2, LSP4, ERC165, ERC725Y
---

<!--You can leave these HTML comments in your merged LIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new LIPs. Note that an LIP number will be assigned by an editor. When opening a pull request to submit your LIP, please use an abbreviated title in the filename, `lip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->
A standard interface for identifiable digital assets, allowing for tokens to be uniquely traded and given metadata using [ERC725Y][ERC725].

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
This standard defines an interface for tokens that are identified with a `tokenId`, based on [ERC721][ERC721]. A `bytes32` value is used for `tokenId` to allow many uses of token identification including numbers, contract addresses, and hashed values (ie. serial numbers).

This standard defines a set of key value stores that are useful to know what the `tokenId` represents, and metadata for each `tokenId`.

## Motivation
<!--The motivation is critical for LIPs that want to change the Lukso protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->

This standard aims to support use cases not covered by [LSP7 DigitalAsset][LSP7], by using a `tokenId` instead of an amount of tokens to mint, burn, and transfer tokens. Each `tokenId` may have metadata (either as a on-chain [ERC725Y][ERC725] contract or off-chain JSON) in addition to the [LSP4 DigitalAsset-Metadata][LSP4#erc725ykeys] metadata of the smart contract that mints the tokens. In this way a minted token benefits from the flexibility & upgradability of the [ERC725Y][ERC725] standard, and transfering a token carries the history of ownership and metadata updates. This is beneficial for a new generation of NFTs.

A commonality with [LSP7 DigitalAsset][LSP7] is desired so that the two token implementations use similar naming for functions, events, and using hooks to notify token senders and receivers using LSP1.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (go-ethereum, parity, cpp-ethereum, ethereumj, ethereumjs, and [others](https://github.com/ethereum/wikwi/wiki/Clients)).-->

### ERC725Y Keys

These are the expected keys for the LSP8 contract which mints tokens.

This standard expects the keys from [LSP4 DigitalAsset-Metadata.][LSP4#erc725ykeys].

#### LSP8TokenIdType

TODO: make this look like an enum

What the `tokenId` represents in this contract, to be stored in the [ERC725Y][ERC725] of the contract which mints tokens.

Expected values are represented by the enum:

- 1 -> `uint256`: a number, which may be an incrementing count where each minted token is assigned the next number.
- 2 -> `address`: another contract.
- 3 -> `bytes32`: a hashed value (ie. serial number).

```json
{
    "name": "LSP8TokenIdType",
    "key": "0x715f248956de7ce65e94d9d836bfead479f7e70d69b718d47bfe7b00e05b4fe4",
    "keyType": "Singleton",
    "valueContent": "Number",
    "valueType": "uint256"
}
```

This SHOULD not be changeable, and set only during initialization of the token.

#### LSP8MetadataAddress:TokenId

When a metadata contract is created for a tokenId, the address COULD be stored in the minting contract storage.

```json
{
    "name": "LSP8MetadataAddress:0x20BytesTokenIdHash",
    "key": "0x73dcc7c3c4096cdc00000000cafecafecafecafecafecafecafecafecafecafe",
    "keyType": "Bytes20Mapping",
    "valueContent": Mixed,
    "valueType": mixed
}
```

For construction of the Bytes20Mapping key see: [LSP2 ERC725Y JSON Schema][LSP2#bytes20mapping]

#### LSP8MetadataJSON:TokenId

When metadata JSON is created for a tokenId, the URL COULD be stored in the minting contract storage.

```json
{
    "name": "LSP8MetadataJSON:0x20BytesTokenIdHash",
    "key": "0x9a26b4060ae7f7d500000000cafecafecafecafecafecafecafecafecafecafe",
    "keyType": "Bytes20Mapping",
    "valueContent": JSONURL,
    "valueType": bytes
}
```
For construction of the Bytes20Mapping key see: [LSP2 ERC725Y JSON Schema][LSP2#bytes20mapping]
For construction of the JSONURL value see: [LSP2 ERC725Y JSON Schema][LSP2#jsonurl]

---
(TODO: discussion if there are other keys to include in the standard for the contract which mints tokens)
---


#### LSP8TokenIdMetadataMintedBy

The `address` of the contract which minted this tokenId, to be stored in the [ERC725Y][ERC725] of a `tokenId` metadata conract.

```json
{
    "name": "LSP8TokenIdMetadata:MintedBy",
    "key": "0xa0093ef0f6788cc87a372bbd12cf83ae7eeb2c85b87e43517ffd5b3978d356c9",
    "keyType": "Singleton",
    "valueContent": "Address",
    "valueType": "address"
}
```

#### LSP8TokenIdMetadataTokenId

The `bytes32` of the `tokenId` this metadata is for, to be stored in the [ERC725Y][ERC725] of a `tokenId` metadata conract.

```json
{
    "name": "LSP8TokenIdMetadata:TokenId",
    "key": "0x51ea539c2c3a29af57cb4b60be9d43689bfa633dba8613743d1be7fb038d36c3",
    "keyType": "Singleton",
    "valueContent": "Bytes32",
    "valueType": "bytes32"
}
```

---
(TODO: discussion if there are other TokenIdMetadata keys to include in the standard)
---

### ERC725Y keys for off-chain tokenId metadata

#### LSP8TokenIdMetadata

The description of the asset.

```json
{
    "name": "LSP4Metadata",
    "key": "0x9afb95cacc9f95858ec44aa8c3b685511002e30ae54415823f406128b85b238e",
    "keyType": "Singleton",
    "valueContent": "JSONURL",
    "valueType": "bytes"
}
```

For construction of the JSONURL value see: [LSP2 ERC725Y JSON Schema][LSP2#jsonurl]

The linked JSON file SHOULD have the following format:

```json
{
    "LSP8TokenIdMetadata": {
        "mintedBy": "address",
        "tokenId": "bytes32",
    }
}
```

---
(TODO: discussion if there are other TokenIdMetadata keys to include in the JSON document standard)
---

### Methods

#### totalSupply

```solidity
function totalSupply() external view returns (uint256);
```

Returns the number of existing tokens.

**Returns:** `uint256` the number of existing tokens.

#### balanceOf
```solidity
function balanceOf(address tokenOwner) external view returns (uint256);
```

Returns the number of tokens owned by `tokenOwner`.

_Parameters:_

- `tokenOwner` the address to query.

**Returns:** `uint256` the number of tokens owned by this address.

#### tokenOwnerOf

```solidity
function tokenOwnerOf(bytes32 tokenId) external view returns (address);
```

Returns the `tokenOwner` address of the `tokenId` token.

_Parameters:_

- `tokenId` the token to query.

_Requirements:_

- `tokenId` must exist

**Returns:** `address` the token owner.

#### tokenIdsOf

```solidity
function tokenIdsOf(address tokenOwner) external view returns (bytes32[] memory);
```

Returns the list of `tokenIds` for the `tokenOwner` address.

_Parameters:_

- `tokenOwner` the address to query.

**Returns:** `bytes32[]` the list of owned token ids.

#### authorizeOperator

```solidity
function authorizeOperator(address operator, bytes32 tokenId) external;
```

Makes `operator` address an operator of `tokenId`.

MUST emit an [AuthorizedOperator event](#authorizedoperator).

_Parameters:_

- `operator` the address to authorize as an operator.
- `tokenId` the token to enable operator status to.

_Requirements:_

- `tokenId` must exist
- caller must be current `tokenOwner` of `tokenId`.
- `operator` cannot be calling address.
- `operator` cannot be the zero address.

#### revokeOperator

```solidity
function revokeOperator(address operator, bytes32 tokenId) external;
```

Removes `operator` address as an operator of `tokenId`.

MUST emit a [RevokedOperator event](#revokedoperator).

_Parameters:_

- `operator` the address to revoke as an operator.
- `tokenId` the token to disable operator status to.

_Requirements:_

- `tokenId` must exist
- caller must be current `tokenOwner` of `tokenId`.
- `operator` cannot be calling address.
- `operator` cannot be the zero address.

#### isOperatorFor

```solidity
function isOperatorFor(address operator, bytes32 tokenId) external view returns (bool);
```

Returns whether `operator` address is an operator of `tokenId`.
Operators can send and burn tokens on behalf of their owners. The tokenOwner is their own operator.

_Parameters:_

- `operator` the address to query operator status for.
- `tokenId` the token to query.

_Requirements:_

- `tokenId` must exist
- caller must be current `tokenOwner` of `tokenId`.

**Returns:** `address` the token owner.

#### getOperatorsOf

```solidity
function getOperatorsOf(bytes32 tokenId) external view returns (address[] memory);
```

Returns all `operator` addresses of `tokenId`.

_Parameters:_

- `tokenId` the token to query.

_Requirements:_

- `tokenId` must exist
- caller must be current `tokenOwner` of `tokenId`.
- `operator` cannot be calling address.

**Returns:** `address[]` the list of operators.

#### transfer

```solidity
function transfer(address from, address to, bytes32 tokenId, bool force, bytes memory data) external;
```

Transfers `tokenId` token from `from` to `to`. The `force` parameter will be used when notifying the token sender and receiver.

MUST emit a [Transfer event](#transfer) when transfer was successful.

_Parameters:_

- `from` the sending address.
- `to` the receiving address.
- `tokenId` the token to transfer.
- `force` when set to true, `to` may be any address; when set to false `to` must be a contract that supports [LSP1 UniversalReceiver][LSP1] and successfully processes a call to `universalReceiver(bytes32 typeId, bytes memory data)`.
- `data` additional data the caller wants included in the emitted event, and sent in the hooks to `from` and `to` addresses.

_Requirements:_

- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `tokenId` token must be owned by `from`.
- If the caller is not `from`, it must be an operator of `tokenId`.

#### transferBatch

```solidity
function transferBatch(address[] memory from, address[] memory to, bytes32[] memory tokenId, bool force, bytes[] memory data) external;
```

Transfers many tokens based on the list `from`, `to`, `tokenId`. If any transfer fails, the call will revert.

MUST emit a [Transfer event](#transfer) for each transfered token.

_Parameters:_

- `from` the list of sending addresses.
- `to` the list of receiving addresses.
- `tokenId` the list of tokens to transfer.
- `force` when set to true, `to` may be any address; when set to false `to` must be a contract that supports [LSP1 UniversalReceiver][LSP1] and successfully processes a call to `universalReceiver(bytes32 typeId, bytes memory data)`.
- `data` the list of additional data the caller wants included in the emitted event, and sent in the hooks to `from` and `to` addresses.

_Requirements:_

- `from`, `to`, `tokenId` lists are the same length.
- no values in `from` can be the zero address.
- no values in `to` can be the zero address.
- each `tokenId` token must be owned by `from`.
- If the caller is not `from`, it must be an operator of each `tokenId`.

### Events

#### Transfer

```solidity
event Transfer(address operator, address indexed from, address indexed to, bytes32 indexed tokenId, bool force, bytes data);
```

MUST be emitted when `tokenId` token is transferred from `from` to `to`.

#### AuthorizedOperator

```solidity
event AuthorizedOperator(address indexed operator, address indexed tokenOwner, bytes32 indexed tokenId);
```

MUST be emitted when `tokenOwner` enables `operator` for `tokenId`.

#### RevokedOperator

```solidity
event RevokedOperator(address indexed operator, address indexed tokenOwner, bytes32 indexed tokenId);
```

MUST be emitted when `tokenOwner` disables `operator` for `tokenId`.

## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->

There should be a base token standard that allows tracking unique assets for the LSP ecosystem of contracts, which will allow common tooling and clients to be built. Existing tools and clients that expect [ERC721][ERC721] can be made to work with this standard by using "compatability" contract extensions that match the desired interface.

### Token Identifier

Every token is identified by a unique `bytes32 tokenId` which SHALL NOT change for the life of the contract. The pair `(contract address, uint256 tokenId)` is globally unique and a fully-qualified identifier for a specific asset on-chain. While some implementations may find it convenient to use the tokenId as an `uint256` that is incremented for each minted token, callers SHALL NOT assume that tokenIds have any specific pattern to them, and MUST treat the tokenId as a "black box". Also note that a tokenId MAY become invalid (when burned).

The choice of `bytes32 tokenId` allows a wide variety of applications including numbers, contract addresses, and hashed values (ie. serial numbers).

### Operators

To clarify the ability of an address to access tokens from another address, `operator` was chosen as the name for functions, events and variables in all cases. This is originally from [ERC777][ERC777] standard and replaces the `approve` functionality from [ERC721][ERC721].

### Token Transfers

There is only one transfer function, which is aware of operators. This deviates from [ERC721][ERC721] and [ERC777][ERC777] which added functions specifically for the token owner to use, and for those with access to tokens. By having a single function to call this makes it simple to move tokens, and the caller will be exposed in the `Transfer` event as an indexed value.

### Usage of hooks

When a token is changing owners (minting, transfering, burning) an attempt is made to notify the token sender and receiver using [LSP1 UniversalReceiver][LSP1] interface. The implementation uses `_notifyTokenSender` and `_notifyTokenReceiver` as the internal functions to process this.

The `force` parameter sent during `function transfer` SHOULD be used when notifying the token receiver, to determine if it must support [LSP1 UniversalReceiver][LSP1]. This is used to prevent accidental token transfers, which may results in lost tokens: non-contract addresses could be a copy paste issue, contracts not supporting [LSP1 UniversalReceiver][LSP1] might not be able to move tokens.

## Implementation
<!--The implementations must be completed before any LIP is given status "Final", but it need not be completed before the LIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->

A implementation can be found in the [lukso-network/lsp-smart-contracts][LSP8Core.sol];

## Interface Cheat Sheet

```solidity
interface ILSP8 is /* IERC165 */ {

    // ERC173

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address);

    function renounceOwnership() public virtual onlyOwner;

    function transferOwnership(address newOwner) public override onlyOwner;


    // ERC725Y

    event DataChanged(bytes32 indexed key, bytes value);

    function getData(bytes32 _key) public view override virtual returns (bytes memory _value);

    function setData(bytes32 _key, bytes memory _value) external override onlyOwner;


    // LSP8

    event Transfer(address operator, address indexed from, address indexed to, bytes32 indexed tokenId, bool force, bytes data);

    event AuthorizedOperator(address indexed operator, address indexed tokenOwner, bytes32 indexed tokenId);

    event RevokedOperator(address indexed operator, address indexed tokenOwner, bytes32 indexed tokenId);

    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner) external view returns (uint256);

    function tokenOwnerOf(bytes32 tokenId) external view returns (address);

    function tokenIdsOf(address tokenOwner) external view returns (bytes32[] memory);

    function authorizeOperator(address operator, bytes32 tokenId) external;

    function revokeOperator(address operator, bytes32 tokenId) external;

    function isOperatorFor(address operator, bytes32 tokenId) external view returns (bool);

    function getOperatorsOf(bytes32 tokenId) external view returns (address[] memory);

    function transfer(address from, address to, bytes32 tokenId, bool force, bytes memory data) external;

    function transferBatch(address[] memory from, address[] memory to, bytes32[] memory tokenId, bool force, bytes[] memory data) external;
}

```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).


[ERC721]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md>
[ERC725]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md>
[ERC777]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-777.md>
[LSP1]: <https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md>
[LSP2#jsonurl]: <https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#jsonurl>
[LSP2#bytes20mapping]: <https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-2-ERC725YJSONSchema.md#bytes20mapping>
[LSP4#erc725ykeys]: <https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-4-DigitalAsset-Metadata.md#erc725ykeys>
[LSP7]: <https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-7-DigitalAsset.md>
[LSP8]: <https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-8-IdentifiableDigitalAsset.md>
[LSP8Core.sol]: <https://github.com/lukso-network/lsp-smart-contracts/blob/main/contracts/LSP8/LSP8Core.sol>
