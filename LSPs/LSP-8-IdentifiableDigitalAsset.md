---
lip: 8
title: Identifiable Digital Asset
author: Claudio Weck <claudio@fanzone.media>, Fabian Vogelsteller <fabian@lukso.network>, Matthew Stevens <@mattgstevens>, Ankit Kumar <@ankitkumar9018>
discussions-to: https://discord.gg/E2rJPP4 (LUKSO), https://discord.gg/PQvJQtCV (FANZONE)
status: Draft
type: LSP
created: 2021-09-02
requires: ERC165, ERC725Y, LSP1, LSP2, LSP4, LSP17
---

<!--You can leave these HTML comments in your merged LIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new LIPs. Note that an LIP number will be assigned by an editor. When opening a pull request to submit your LIP, please use an abbreviated title in the filename, `lip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary

<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->

The LSP8 Identifiable Digital Asset Standard defines a standard interface for uniquely identifiable digital assets. It allows tokens to be uniquely traded and given with metadata using [ERC725Y][erc725] and [LSP4](./LSP-4-DigitalAsset-Metadata.md#lsp4metadata).

## Abstract

<!--A short (~200 word) description of the technical issue being addressed.-->

This standard defines a digital asset standard that can represent non-fungible tokens (NFTs).

Key functionalities of this asset standard include:

- **Flexible Asset Representation**: The tokenId defined in the standard is `bytes32` allowing different tokenId identification including numbers, contract addresses, and any other unique identifiers (_e.g:_ serial numbers, NFTs with unique names, hash values, etc...).

- **Dynamic Information Attachment**: Leverages [ERC725Y] to add generic information to the asset and to each tokenId even post-deployment according to the LSP4-DigitalAssetMetadata standard.

- **Secure Transfers**: By checking whether the recipient is capable of handling the asset before the actual transfer, it avoids loss and transfer of tokens to uncontrolled addresses.

- **Transfer Interaction**: Notifies the operator, sender, and the recipient about the transfer, allowing users to be informed about the incoming asset and decide how to react accordingly (e.g., denying the token, forwarding it, etc.).

- **Future-Proof Functionalities**: Through [LSP17-ContractExtension], allows the asset to be extended and support new standardized functions and interface IDs over time.

- **Asset Flexibility and Discoverability**: Offers several flexible features, such as batch transfers and the ability to add several operators, as well as the ability to discover them.

## Motivation

<!--The motivation is critical for LIPs that want to change the Lukso protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->

The motivation for developing this new digital asset standard can be organized into several key points, each showing a specific limitation of current token standards:

- **Limited Asset Representation**: Current NFT standards represent tokenId as a simple `uint256` type with no indication about how to parse it, making the NFT very limited.

- **Limited Asset Metadata**: Current token standards offer limited metadata attachment capabilities, typically confined to basic elements like `name`, `symbol`, and `tokenURI`. This limitation is particularly restrictive for assets that require verifiable, on-chain metadata – such as details about creators, the community behind the token, or dynamic attributes that allow an NFT to evolve.

- **No Interaction and Notification**: Traditional token standards lack in terms of interaction, particularly in notifying recipients about transfers. As a result, users cannot be unaware of incoming tokens and lose the opportunity to respond, for example, react to transfers, whether to deny, accept, or forward the tokens.

- **Limited Functionalities**: Many tokens are confined to the functionalities they possess at deployment, making them rigid and unable to adapt to new requirements or standards.

- **Risk of asset loss**: A common issue with current assets is the risk of loss due to transfers to incorrect or uncontrolled addresses as these standards does not check whether the recipient is able to handle the asset or not.

- **Limited Features**: The limitation of having only one operator and the absence of batch transfer capabilities or even the discoveribility of tokens a user own restricts and provide bad user experience. Users need to rely on centralized indexers to know which tokens they own, need to do several transactions to do a batch of transfers, and cannot have more than one operator.

## Specification

[ERC165] interface id: `0xecad9f75`

The LSP8 interface ID is calculated as the XOR of the LSP8 interface (see [interface cheat-sheet below](#interface-cheat-sheet)) and the [LSP17 Extendable interface ID](./LSP-17-ContractExtension.md#erc165-interface-id).

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
function authorizeOperator(address operator, bytes32 tokenId, bytes memory operatorNotificationData) external;
```

Makes `operator` address an operator of `tokenId`.

MUST emit an [OperatorAuthorizationChanged event](#OperatorAuthorizationChanged).

_Parameters:_

- `operator` the address to authorize as an operator.
- `tokenId` the token to enable operator status to.
- `operatorNotificationData` the data to send when notifying the operator via LSP1.

_Requirements:_

- `tokenId` must exist
- caller must be current `tokenOwner` of `tokenId`.
- `operator` cannot be calling address.
- `operator` cannot be the zero address.

**LSP1 Hooks:**

- If the operator is a contract that supports LSP1 interface, it SHOULD call operator's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: `keccak256('LSP8Tokens_OperatorNotification')` > `0x8a1c15a8799f71b547e08e2bcb2e85257e81b0a07eee2ce6712549eef1f00970`
  - `data`: The data sent SHOULD be abi encoded and contain the `tokenOwner` (address), `tokenId` (bytes32), `isAuthorized` (boolean), and the `operatorNotificationData` (bytes) respectively.

<br>

#### revokeOperator

```solidity
function revokeOperator(address operator, bytes32 tokenId, bool notify, bytes memory operatorNotificationData) external;
```

Removes `operator` address as an operator of `tokenId`.

MUST emit a [OperatorRevoked event](#OperatorRevoked).

_Parameters:_

- `operator` the address to revoke as an operator.
- `tokenId` the token to disable operator status to.
- `operatorNotificationData` the data to send when notifying the operator via LSP1.

_Requirements:_

- `tokenId` must exist
- caller must be current `tokenOwner` of `tokenId`.
- `operator` cannot be calling address.
- `operator` cannot be the zero address.

**LSP1 Hooks:**

- If the `notify` boolean is set to `true` and the operator is a contract that supports LSP1 interface, it SHOULD call operator's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: `keccak256('LSP8Tokens_OperatorNotification')` > `0x8a1c15a8799f71b547e08e2bcb2e85257e81b0a07eee2ce6712549eef1f00970`
  - `data`: The data sent SHOULD be abi encoded and contain the `tokenOwner` (address), `tokenId` (bytes32), `isAuthorized` (boolean), and the `operatorNotificationData` (bytes) respectively.

<br>

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

**Returns:** `bool`, TRUE if `operator` address is an operator of `tokenId`, FALSE otherwise.

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
MUST emit a [OperatorRevoked](#operatorrevoked) to clear the past operators.

_Parameters:_

- `from` the sending address.
- `to` the receiving address.
- `from` and `to` cannot be the same address.
- `tokenId` the token to transfer.
- `force` when set to TRUE, `to` may be any address; when set to FALSE `to` must be a contract that supports [LSP1 UniversalReceiver][lsp1] and successfully processes a call to `universalReceiver(bytes32 typeId, bytes memory data)`.
- `data` additional data the caller wants included in the emitted event, and sent in the hooks to `from` and `to` addresses.

_Requirements:_

- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `tokenId` token must be owned by `from`.
- If the caller is not `from`, it must be an operator of `tokenId`.

**LSP1 Hooks:**

- If the token sender is a contract that supports LSP1 interface, it SHOULD call the token sender's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: `keccak256('LSP8Tokens_SenderNotification')` = `0xb23eae7e6d1564b295b4c3e3be402d9a2f0776c57bdf365903496f6fa481ab00`
  - `data`: The data sent SHOULD be ABI encoded and contain the `sender` (address), `receiver` (address), `tokenId` (bytes32) and the `data` (bytes) respectively.

<br>

- If the token recipient is a contract that supports LSP1 interface, it SHOULD call the token recipient's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: `keccak256('LSP8Tokens_RecipientNotification')` = `0x0b084a55ebf70fd3c06fd755269dac2212c4d3f0f4d09079780bfa50c1b2984d`
  - `data`: The data sent SHOULD be ABI encoded and contain the `sender` (address), `receiver` (address), `tokenId` (bytes32) and the `data` (bytes) respectively.

**Note:** LSP1 Hooks MUST be implemented in any type of token transfer (mint, transfer, burn, transferBatch).

#### transferBatch

```solidity
function transferBatch(address[] memory from, address[] memory to, bytes32[] memory tokenId, bool force, bytes[] memory data) external;
```

Transfers many tokens based on the list `from`, `to`, `tokenId`. If any transfer fails, the call will revert.

MUST emit a [Transfer event](#transfer) for each transfered token.
MUST emit a [OperatorRevoked](#operatorrevoked) to clear the past operators for each transfered token.

_Parameters:_

- `from` the list of sending addresses.
- `to` the list of receiving addresses.
- `tokenId` the list of tokens to transfer.
- `force` when set to TRUE, `to` may be any address; when set to FALSE `to` must be a contract that supports [LSP1 UniversalReceiver][lsp1] and successfully processes a call to `universalReceiver(bytes32 typeId, bytes memory data)`.
- `data` the list of additional data the caller wants included in the emitted event, and sent in the hooks to `from` and `to` addresses.

_Requirements:_

- `from`, `to`, `tokenId` lists are the same length.
- no values in `from` can be the zero address.
- no values in `to` can be the zero address.
- `from` and `to` cannot be the same address at the same.
- each `tokenId` token must be owned by `from`.
- If the caller is not `from`, it must be an operator of each `tokenId`.

#### getTokenIdData

```solidity
function getTokenIdData(bytes32 tokenId, bytes32 dataKey) external view returns (bytes memory dataValue)
```

Gets the data set for the given data key for a specific tokenId.

_Parameters:_

- `tokenId`: the tokenId to retrieve data for.
- `dataKey`: the data key which value to retrieve.

_Returns:_ `bytes` , The data for the requested data key.

#### getTokenIdDataBatch

```solidity
function getTokenIdDataBatch(bytes32[] memory tokenIds, bytes32[] memory dataKeys) external view returns(bytes[] memory dataValues)
```

Gets array of data at multiple given data keys for given tokenIds.

_Parameters:_

- `tokenIds`: the tokenIds to retrieve data for.
- `dataKeys`: the data keys which values to retrieve.

_Returns:_ `bytes[]` , array of data values for the requested data keys.

#### setTokenIdData

```solidity
function setTokenIdData(bytes32 tokenId, bytes32 dataKey, bytes memory dataValue) external;
```

Sets data as bytes in the storage for a single data key for a tokenId.

_Parameters:_

- `tokenId`: the tokenId to set data for.
- `dataKey`: the data key which value to set.
- `dataValue`: the data to store.

_Requirements:_

- MUST only be called by the current owner of the contract.

**Triggers Event:** [TokenIdDataChanged](#tokeniddatachanged)

#### setTokenIdDataBatch

```solidity
function setTokenIdDataBatch(bytes32[] memory tokenIds, bytes32[] memory dataKeys, bytes[] memory dataValues) external
```

Sets array of data at multiple data keys for multiple tokenIds.

_Parameters:_

- `tokenIds`: the tokenIds to set data for.
- `dataKeys`: the data keys which values to set.
- `dataValues`: the array of bytes to set.

_Requirements:_

- Array parameters MUST have the same length.
- MUST only be called by the current owner of the contract.

**Triggers Event:** [TokenIdDataChanged](#tokeniddatachanged) on each iteration

#### batchCalls

```solidity
function batchCalls(bytes[] calldata data) external returns (bytes[] memory results);
```

Enables the execution of a batch of encoded function calls on the current contract in a single transaction, provided as an array of bytes.

MUST use the [DELEGATECALL] opcode to execute each call in the same context of the current contract.

_Parameters:_

- `data`: an array of encoded function calls to be executed on the current contract.

The data field can be:

- an array of ABI-encoded function calls such as an array of ABI-encoded `transfer`, `authorizeOperator`, `balanceOf` or any LSP8 functions.
- an array of bytes which will resolve to the fallback function to be checked for an extension.

_Requirements:_

- MUST NOT be payable.

_Returns:_ `results` , an array of bytes containing the return values of each executed function call.

### Events

#### TokenIdDataChanged

```solidity
event TokenIdDataChanged(bytes32 indexed tokenId, bytes32 indexed dataKey, bytes dataValue);
```

MUST be emitted when `dataValue` is set as a value for `dataValue` for the `tokenId`.

#### Transfer

```solidity
event Transfer(address operator, address indexed from, address indexed to, bytes32 indexed tokenId, bool force, bytes data);
```

MUST be emitted when `tokenId` token is transferred from `from` to `to`.

#### OperatorAuthorizationChanged

```solidity
event OperatorAuthorizationChanged(address indexed operator, address indexed tokenOwner, bytes32 indexed tokenId, bytes operatorNotificationData);
```

MUST be emitted when `tokenOwner` enables `operator` for `tokenId`.

#### OperatorRevoked

```solidity
event OperatorRevoked(address indexed operator, address indexed tokenOwner, bytes32 indexed tokenId, bool notified, bytes operatorNotificationData);
```

MUST be emitted when `tokenOwner` disables `operator` for `tokenId`.

### Metadata

The **LSP8-IdentifiableDigitalAsset** expect the usage of [LSP4-DigitalAsset-Metadata](./LSP-4-DigitalAsset-Metadata.md) to store the metadata of the asset, as well as defining standard specific data keys to store LSP8 specific metadata. These data key can be either stored for the whole contract using `setData(..)` or for a single tokenId using `setTokenIdData(..)`.

To set metdata for each specific tokenId, set the `LSP4Metadata` key for each tokenId using `setTokenIdData(..)` function.

#### ERC725Y Data Keys

#### LSP8TokenIdSchema

```json
{
  "name": "LSP8TokenIdSchema",
  "key": "0x341bc44e55234544c70af9d37b2cb8cc7ba74685b58526221de2cc977f469924",
  "keyType": "Singleton",
  "valueType": "uint256",
  "valueContent": "Number"
}
```

The **LSP8-IdentifiableDigitalAsset** standard, defines tokenIds as `bytes32`, this data key describes the schema of the `tokenId` and how to parse it and can take one of the following values described in the table below.

| Value |  Schema   | Description                                                                                                             |
| :---: | :-------: | :---------------------------------------------------------------------------------------------------------------------- |
|  `0`  | `uint256` | each NFT is parsed as a **unique number**.                                                                              |
|  `1`  | `string`  | each NFT is parsed as a **unique name** (as a short **utf8 encoded string**, no more than 32 characters long)           |
|  `2`  | `address` | each NFT is parsed as its **own smart contract** that can hold its own logic and metadata (_e.g [ERC725Y] compatible_). |
|  `3`  | `bytes32` | each NFT is parsed as a 32 bytes long **unique identifier**.                                                            |
|  `4`  | `bytes32` | each NFT is parsed as a 32 bytes **hash digest**.                                                                       |

Since tokenIds can have their own custom metadata, it is also possible to have **Mixed types**, where there is a default schema for the collection, and each tokenId can have its own schema, meaning the values can be extended to:

| Value |              Schema               | Description                                                                                                                                                                           |
| :---: | :-------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `100` | `Mixed` with default as `uint256` | Default NFT is parsed as a **unique number** with querying the `LSP8TokenIdSchema` for each `tokenId`.                                                                                |
| `101` | `Mixed` with default as `string`  | Default NFT is parsed as a **unique name** (as a short **utf8 encoded string**, no more than 32 characters long) with querying the `LSP8TokenIdSchema` for each `tokenId`.            |
| `102` | `Mixed` with default as `address` | Default NFT is parsed as its **own smart contract** that can hold its own logic and metadata (_e.g [ERC725Y] compatible_) with querying the `LSP8TokenIdSchema` for each `tokenId`. . |
| `103` | `Mixed` with default as `bytes32` | Default NFT is parsed as a 32 bytes long **unique identifier** with querying the `LSP8TokenIdSchema` for each `tokenId`.                                                              |
| `104` | `Mixed` with default as `bytes32` | Default NFT is parsed as a 32 bytes **hash digest**with querying the `LSP8TokenIdSchema` for each `tokenId`.                                                                          |

_Requirements:_

- This MUST NOT be changeable, and set only during initialization of the LSP8 token contract.

#### LSP8TokenMetadataBaseURI

```json
{
  "name": "LSP8TokenMetadataBaseURI",
  "key": "0x1a7628600c3bac7101f53697f48df381ddc36b9015e7d7c9c5633d1252aa2843",
  "keyType": "Singleton",
  "valueType": "bytes",
  "valueContent": "VerifiableURI"
}
```

This data key defines the base URI for the metadata of each `tokenId`s present in the LSP8 contract.

The complete URI that points to the metadata of a specific tokenId MUST be formed by concatenating this base URI with the `tokenId`.
As `{LSP8TokenMetadataBaseURI}{tokenId}`.

⚠️ TokenIds MUST be in lowercase, even for the tokenId type `address` (= address not checksumed).

- LSP8TokenIdSchema `0` (= `uint256`)<br>
  e.g. `http://mybase.uri/1234`
- LSP8TokenIdSchema `1` (= `string`)<br>
  e.g. `http://mybase.uri/name-of-the-nft`
- LSP8TokenIdSchema `2` (= `address`)<br>
  e.g. `http://mybase.uri/0x43fb7ab43a3a32f1e2d5326b651bbae713b02429`
- LSP8TokenIdSchema `3` or `4` (= `bytes32`)<br>
  e.g. `http://mybase.uri/e5fe3851d597a3aa8bbdf8d8289eb9789ca2c34da7a7c3d0a7c442a87b81d5c2`

Some Base URIs could be alterable, for example in the case of NFTs that need their metadata to change overtime.

### ERC725Y Data Keys of external contract for tokenID schema 2 (`address`)

When the LSP8 contract uses the [tokenId schema `4`](#lsp8tokenidschema) (= `address`), each tokenId minted is an ERC725Y smart contract that can have its own metadata.
We refer to this contract as the **tokenId metadata contract**.

In this case, each tokenId present in the LSP8 contract references an other ERC725Y contract.

The **tokenId metadata contract** SHOULD contain the following ERC725Y data key in its storage.

#### LSP8ReferenceContract

This data key stores the address of the LSP8 contract that minted this specific `tokenId` (defined by the address of the **tokenId metadata contract**).

It is a reference back to the LSP8 Collection it comes from.

If the `LSP8ReferenceContract` data key is set, it MUST NOT be changeable.

```json
{
  "name": "LSP8ReferenceContract",
  "key": "0x708e7b881795f2e6b6c2752108c177ec89248458de3bf69d0d43480b3e5034e6",
  "keyType": "Singleton",
  "valueType": "(address,bytes32)",
  "valueContent": "(Address,bytes32)"
}
```

### LSP8 TokenId Metadata

The metadata for a specific of a uniquely identifiable digital asset (when this tokenId is represented by its own ERC725Y contract) can follow the JSON format of the [`LSP4Metadata`](./LSP-4-DigitalAsset-Metadata.md#lsp4metadata) data key.

This JSON format includes an `"attributes"` field to describe unique properties of the tokenId.

## Rationale

<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->

There should be a base token standard that allows tracking unique assets for the LSP ecosystem of contracts, which will allow common tooling and clients to be built. Existing tools and clients that expect [ERC721][erc721] can be made to work with this standard by using "compatability" contract extensions that match the desired interface.

### Token Identifier

Every token is identified by a unique `bytes32 tokenId` which SHALL NOT change for the life of the contract. The pair `(contract address, uint256 tokenId)` is globally unique and a fully-qualified identifier for a specific asset on-chain. While some implementations may find it convenient to use the tokenId as an `uint256` that is incremented for each minted token, callers SHALL NOT assume that tokenIds have any specific pattern to them, and MUST treat the tokenId as a "black box". Also note that a tokenId MAY become invalid (when burned).

The choice of `bytes32 tokenId` allows a wide variety of applications including numbers, contract addresses, and hashed values (ie. serial numbers).

### Operators

To clarify the ability of an address to access tokens from another address, `operator` was chosen as the name for functions, events and variables in all cases. This is originally from [ERC777][erc777] standard and replaces the `approve` functionality from [ERC721][erc721].

### Token Transfers

There is only one transfer function, which is aware of operators. This deviates from [ERC721][erc721] and [ERC777][erc777] which added functions specifically for the token owner to use, and for those with access to tokens. By having a single function to call this makes it simple to move tokens, and the caller will be exposed in the `Transfer` event as an indexed value.

### Usage of hooks

When a token is changing owners (minting, transfering, burning) an attempt is made to notify the token sender and receiver using [LSP1 UniversalReceiver][lsp1] interface. The implementation uses `_notifyTokenSender` and `_notifyTokenReceiver` as the internal functions to process this.

The `force` parameter sent during `function transfer` SHOULD be used when notifying the token receiver, to determine if it must support [LSP1 UniversalReceiver][lsp1]. This is used to prevent accidental token transfers, which may results in lost tokens: non-contract addresses could be a copy paste issue, contracts not supporting [LSP1 UniversalReceiver][lsp1] might not be able to move tokens.

## Implementation

<!--The implementations must be completed before any LIP is given status "Final", but it need not be completed before the LIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->

A implementation can be found in the [lukso-network/lsp-smart-contracts][lsp8.sol].

ERC725Y JSON Schema `LSP8IdentifiableDigitalAsset`:

```json
[
  {
    "name": "LSP8TokenIdSchema",
    "key": "0x341bc44e55234544c70af9d37b2cb8cc7ba74685b58526221de2cc977f469924",
    "keyType": "Singleton",
    "valueType": "uint256",
    "valueContent": "Number"
  },
  {
    "name": "LSP8TokenMetadataBaseURI",
    "key": "0x1a7628600c3bac7101f53697f48df381ddc36b9015e7d7c9c5633d1252aa2843",
    "keyType": "Singleton",
    "valueType": "(bytes4,string)",
    "valueContent": "(Bytes4,URI)"
  },
  {
    "name": "LSP8ReferenceContract",
    "key": "0x708e7b881795f2e6b6c2752108c177ec89248458de3bf69d0d43480b3e5034e6",
    "keyType": "Singleton",
    "valueType": "(address,bytes32)",
    "valueContent": "(Address,bytes32)"
  }
]
```

## Interface Cheat Sheet

```solidity
interface ILSP8 is /* IERC165 */ {

    // ERC173

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() external view returns (address);

    function transferOwnership(address newOwner) external override; // onlyOwner

    function renounceOwnership() external virtual; // onlyOwner


    // ERC725Y

    event DataChanged(bytes32 indexed dataKey, bytes dataValue);


    function getData(bytes32 dataKey) external view returns (bytes memory value);

    function setData(bytes32 dataKey, bytes memory value) external; // onlyOwner

    function getDataBatch(bytes32[] memory dataKeys) external view returns (bytes[] memory values);

    function setDataBatch(bytes32[] memory dataKeys, bytes[] memory values) external; // onlyOwner


    // LSP8

    event Transfer(address operator, address indexed from, address indexed to, bytes32 indexed tokenId, bool force, bytes data);

    event OperatorAuthorizationChanged(address indexed operator, address indexed tokenOwner, bytes32 indexed tokenId, bytes operatorNotificationData);

    event OperatorRevoked(address indexed operator, address indexed tokenOwner, bytes32 indexed tokenId, bool notified, bytes operatorNotificationData);

    event TokenIdDataChanged(bytes32 indexed tokenId, bytes32 indexed dataKey, bytes dataValue);


    function getTokenIdData(bytes32 tokenId, bytes32 dataKey) external view returns (bytes memory dataValue);

    function setTokenIdData(bytes32 tokenId, bytes32 dataKey, bytes memory dataValue) external; // onlyOwner

    function getTokenIdDataBatch(bytes32[] memory tokenIds, bytes32[] memory dataKeys) external view returns (bytes[] memory dataValues);

    function setTokenIdDataBatch(bytes32[] memory tokenIds, bytes32[] memory dataKeys, bytes[] memory dataValues) external; // onlyOwner


    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner) external view returns (uint256);

    function tokenOwnerOf(bytes32 tokenId) external view returns (address);

    function tokenIdsOf(address tokenOwner) external view returns (bytes32[] memory);

    function authorizeOperator(address operator, bytes32 tokenId, bytes memory operatorNotificationData) external;

    function revokeOperator(address operator, bytes32 tokenId, bool notify, bytes memory operatorNotificationData) external;

    function isOperatorFor(address operator, bytes32 tokenId) external view returns (bool);

    function getOperatorsOf(bytes32 tokenId) external view returns (address[] memory);

    function transfer(address from, address to, bytes32 tokenId, bool force, bytes memory data) external;

    function transferBatch(address[] memory from, address[] memory to, bytes32[] memory tokenId, bool force, bytes[] memory data) external;

    function batchCalls(bytes[] calldata data) external returns (bytes[] memory results);
}

```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[erc165]: https://eips.ethereum.org/EIPS/eip-165
[erc721]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
[erc725]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-725.md
[erc725y]: https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#erc725y
[erc777]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-777.md
[lsp1]: ./LSP-1-UniversalReceiver.md
[lsp2#jsonurl]: ./LSP-2-ERC725YJSONSchema.md#JSONURL
[lsp2#mapping]: ./LSP-2-ERC725YJSONSchema.md#mapping
[lsp4#erc725ykeys]: ./LSP-4-DigitalAsset-Metadata.md#erc725ykeys
[lsp7]: ./LSP-7-DigitalAsset.md
[lsp8]: ./LSP-8-IdentifiableDigitalAsset.md
[lsp8.sol]: https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/develop/contracts/LSP8IdentifiableDigitalAsset/LSP8IdentifiableDigitalAsset.sol
