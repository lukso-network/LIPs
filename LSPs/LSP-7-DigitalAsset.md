---
lip: 7
title: Digital Asset
author: Claudio Weck <claudio@fanzone.media>, Fabian Vogelsteller <fabian@lukso.network>, Matthew Stevens <@mattgstevens>, Ankit Kumar <https://github.com/ankitkumar9018>
discussions-to: https://discord.gg/E2rJPP4 (LUKSO), https://discord.gg/PQvJQtCV (FANZONE)
status: Draft
type: LSP
created: 2021-09-02
requires: LSP1, LSP2, LSP4, ERC165, ERC725Y
---

<!--You can leave these HTML comments in your merged LIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new LIPs. Note that an LIP number will be assigned by an editor. When opening a pull request to submit your LIP, please use an abbreviated title in the filename, `lip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->
A standard interface for digital assets, for either fungible or non-fungible tokens.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
This standard defines an interface for tokens where minting and transfering is specified with an amount of tokens. It is based on [ERC20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) with some enhancements from [ERC777](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md).

## Motivation
<!--The motivation is critical for LIPs that want to change the Lukso protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->

This standard aims to support many token use cases, both fungible and non-fungible, to be used as the base implementation that is defined with other LSP standards in mind.

A commonality with LSP8 is desired so that the two token implementations use similar naming for functions, events, and using hooks to notify token senders and receivers using LSP1.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (go-ethereum, parity, cpp-ethereum, ethereumj, ethereumjs, and [others](https://github.com/ethereum/wikwi/wiki/Clients)).-->

### ERC725Y Keys for minting contract

These are the expected keys for the LSP7 contract which mints tokens.

#### SupportedStandards:LSP7DigitalAsset

The supported standard SHOULD be `LSP7DigitalAsset`

```json
{
    "name": "SupportedStandards:LSP7DigitalAsset",
    "key": "0xeafec4d89fa9619884b6b8913562645500000000000000000000000074ac49b0",
    "keyType": "Mapping",
    "valueContent": "0x74ac49b0",
    "valueType": "bytes"
}
```

#### LSP4Metadata

The description of the asset, to be stored in the ERC725Y of the contract which mints tokens.

Please see [LSP4Metadata](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-4-DigitalCertificate.md#lsp4metadata) for details.

#### LSP4Creators[]

An array of (ERC725Account) addresses of creators,

Please see [LSP4Creators[]](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-4-DigitalCertificate.md#lsp4creators) for details.

### Methods

#### decimals

```solidity
function decimals() external view returns (uint8);
```

Returns the number of decimals used to get its user representation.

If the token is an NFT then `0` SHOULD be used, otherwise `18` is the common value.

**Returns:** `uint8` the number of decimals to tranfrom a token value when displaying.

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

**Parameters:**

- `tokenOwner` the address to query.

**Returns:** `uint256` the number of tokens owned by this address.

#### authorizeOperator

```solidity
function authorizeOperator(address operator, uint256 amount) external;
```

Sets `amount` as the amount of tokens `operator` address has access to from callers tokens.

Emits an [AuthorizedOperator event](#authorizedoperator).

**Parameters:**

- `operator` the address to authorize as an operator.
- `amount` the amount of tokens operator has access to.

**Requirements:**

- `operator` cannot be calling address.

#### revokeOperator

```solidity
function revokeOperator(address operator) external;
```

Removes `operator` address as an operator of callers tokens.

Emits an [RevokedOperator event](#revokedoperator).

**Parameters:**

- `operator` the address to revoke as an operator.

**Requirements:**

- `operator` cannot be calling address.

#### isOperatorFor

```solidity
function isOperatorFor(address operator, uint256 amount) external view returns (uint256);
```

Returns amount of tokens `operator` address has access to from `tokenOwner`.
Operators can send and burn tokens on behalf of their owners. The tokenOwner is their own operator.

**Parameters:**

- `operator` the address to query operator status for.

**Returns:** `address` the token owner.

#### transfer

```solidity
function transfer(address from, address to, uint256 amount, bool force, bytes calldata data) external;
```

Transfers `amount` of tokens from `from` to `to`. The `force` parameter will be used when notifying the token sender and receiver.

MUST Emit a [Transfer event](#transfer) when transfer was successful.

**Parameters:**

- `from` the sending address.
- `to` the receiving address.
- `amount` the amount of tokens to transfer.
- `force` when set to true, `to` may be any address; when set to false `to` must be a contract that supports `LSP1` and successfully processes a call to `universalReceiver(bytes32 typeId, bytes memory data)`.
- `data` additional data the caller wants included in the emmited event, and sent in the hooks to `from` and `to` addresses.

**Requirements:**

- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `amount` tokens must be owned by `from`.
- If the caller is not `from`, it must be an operator for `from` with access to at least `amount` tokens.

#### transferBatch

```solidity
function transferBatch(address[] calldata from, address[] calldata to, bytes32[] calldata tokenId, bool force, bytes[] calldata data) external;
```

Transfers many tokens based on the list `from`, `to`, `amount`. If any transfer fails, the call will revert.

MUST emit a [Transfer event](#transfer) for each transfered token.

**Parameters:**

- `from` the list of sending addresses.
- `to` the list of receiving addresses.
- `tokenId` the list of tokens to transfer.
- `force` when set to true, `to` may be any address; when set to false `to` must be a contract that supports `LSP1` and successfully processes a call to `universalReceiver(bytes32 typeId, bytes memory data)`.
- `data` the list of additional data the caller wants included in the emmited event, and sent in the hooks to `from` and `to` addresses.

**Requirements:**

- `from`, `to`, `tokenId` lists are the same length.
- no values in `from` can be the zero address.
- no values in `to` can be the zero address.
- each `amount` tokens must be owned by `from`.
- If the caller is not `from`, it must be an operator for `from` with access to at least `amount` tokens.

### Events

#### Transfer

```solidity
event Transfer(address indexed operator, address indexed from, address indexed to, uint256 amount, bytes data);
```

MUST be emitted when `amount` token is transferred from `from` to `to`.

#### AuthorizedOperator

```solidity
event AuthorizedOperator(address indexed operator, address indexed tokenOwner, uint256 amount);
```

MUST be emitted when `tokenOwner` enables `operator` for `amount` tokens.

#### RevokedOperator

```solidity
event RevokedOperator(address indexed operator, address indexed tokenOwner);
```

MUST be emitted when `tokenOwner` disables `operator`.

## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->

There should be a base token standard for the LSP ecosystem of contracts, which will allow common tooling and clients to be built. Existing tools and clients that expect ERC20 & ERC777 can be made to work with this standard by using "compatability" contract extensions that match the desired interface.

### Operators

To clarify the ability of an address to access tokens from another address, `operator` was chosen as the name for functions, events and variables in all cases. This is originally from ERC777 standard and replaces the `allowance` functionality from ERC20.

### Token Transfers

There is only one transfer function, which is aware of operators. This deviates from ERC20 and ERC777 which added functions specifically for the token owner to use, and for those with access to tokens. By having a single function to call this makes it simple to move tokens, and the caller will be exposed in the `Transfer` event as an indexed value.

### Usage of hooks

When a token is changing owners (minting, transfering, burning) an attempt is made to notify the token sender and receiver using LSP1 interface. The implementation uses `_notifyTokenSender` and `_notifyTokenReceiver` as the internal functions to process this.

The `force` parameter sent during `function transfer` SHOULD be used when notifying the token receiver, to determine if it must support LSP1. This is used to prevent accidental token transfers, which may results in lost tokens: non-contract addresses could be a copy paste issue, contracts not supporting LSP1 might not be able to move tokens.

## Implementation
<!--The implementations must be completed before any LIP is given status "Final", but it need not be completed before the LIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->

A implementation can be found in the [lukso-network/universalprofile-smart-contracts](https://github.com/fanzone-media/universalprofile-smart-contracts/blob/permissions/contracts/LSP7/LSP7Core.sol);

ERC725Y JSON Schema `LSP7DigitalAsset`:

```json
[
    {
        "name": "SupportedStandards:LSP7DigitalAsset",
        "key": "0xeafec4d89fa9619884b6b8913562645500000000000000000000000074ac49b0",
        "keyType": "Mapping",
        "valueContent": "0x74ac49b0",
        "valueType": "bytes"
    }
]
```

## Interface Cheat Sheet

```solidity
interface ILSP7 is IERC165, IERC725Y {
    event Transfer(address indexed operator, address indexed from, address indexed to, uint256 amount, bytes data);

    event AuthorizedOperator(address indexed operator, address indexed tokenOwner, uint256 indexed amount);

    event RevokedOperator(address indexed operator, address indexed tokenOwner);

    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner) external view returns (uint256);

    function authorizeOperator(address operator, uint256 amount) external;

    function revokeOperator(address to, uint256 amount) external;

    function isOperatorFor(address operator, address tokenOwner) external view returns (uint256);

    function transfer(address from, address to, uint256 amount, bool force, bytes calldata data) external;

    function transferBatch(address[] calldata from, address[] calldata to, uint256[] calldata amount, bool force, bytes[] calldata data) external;

    // ERC173

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address);

    function renounceOwnership() public virtual onlyOwner;

    function transferOwnership(address newOwner) public override onlyOwner;


    // ERC725Y

    event DataChanged(bytes32 indexed key, bytes value);

    function getData(bytes32 _key) public view override virtual returns (bytes memory _value);

    function setData(bytes32 _key, bytes memory _value) external override onlyOwner;
}

```

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
