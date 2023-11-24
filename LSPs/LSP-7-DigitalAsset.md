---
lip: 7
title: Digital Asset
author: Fabian Vogelsteller <fabian@lukso.network>, Claudio Weck <claudio@fanzone.media>, Matthew Stevens <@mattgstevens>, Ankit Kumar <@ankitkumar9018>
discussions-to: https://discord.gg/E2rJPP4 (LUKSO), https://discord.gg/PQvJQtCV (FANZONE)
status: Draft
type: LSP
created: 2021-09-02
requires: ERC165, ERC173, ERC725Y, LSP1, LSP2, LSP4, LSP17
---

<!--You can leave these HTML comments in your merged LIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new LIPs. Note that an LIP number will be assigned by an editor. When opening a pull request to submit your LIP, please use an abbreviated title in the filename, `lip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary

<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->

A standard interface for digital assets, for either fungible or non-fungible tokens.

## Abstract

<!--A short (~200 word) description of the technical issue being addressed.-->

This standard defines an interface for tokens where minting and transfering is specified with an amount of tokens. It is based on [ERC20][ERC20] with some ideas from [ERC777][ERC777].

## Motivation

<!--The motivation is critical for LIPs that want to change the Lukso protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->

This standard aims to support many token use cases, both fungible and non-fungible, to be used as the base implementation that is defined with other LSP standards in mind.

A commonality with [LSP8 IdentifiableDigitalAsset][LSP8] is desired so that the two token implementations use similar naming for functions, events, and using hooks to notify token senders and receivers using [LSP1 UniversalReceiver][LSP1].

## Specification

[ERC165] interface id: `0xdaa746b7`

The LSP7 interface ID is calculated as the XOR of the LSP7 interface (see [interface cheat-sheet below](#interface-cheat-sheet)) and the [LSP17 Extendable interface ID](./LSP-17-ContractExtension.md#erc165-interface-id).

### ERC725Y Data Keys

This standard also expects data keys from [LSP4 DigitalAsset-Metadata][LSP4#erc725ykeys].

### Methods

#### decimals

```solidity
function decimals() external view returns (uint8);
```

Returns the number of decimals used to get its user representation.

If the token is non-divisible then `0` SHOULD be used, otherwise `18` is the common value.

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

_Parameters:_

- `tokenOwner` the address to query.

**Returns:** `uint256` the number of tokens owned by this address.

#### authorizeOperator

```solidity
function authorizeOperator(address operator, uint256 amount, bytes memory operatorNotificationData) external;
```

Sets `amount` as the amount of tokens `operator` address has access to from callers tokens.

To increase or decrease the authorized amount of an operator, it's advised to call `revokeOperator(..)` function first, and then call `authorizeOperator(..)` with the new amount to authorize, to avoid front-running through an allowance double-spend exploit.
Check more information [in this document](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/).

MUST emit an [AuthorizedOperator event](#authorizedoperator).

_Parameters:_

- `operator` the address to authorize as an operator.
- `amount` the amount of tokens operator has access to.
- `operatorNotificationData` the data to send when notifying the operator via LSP1.

_Requirements:_

- `operator` cannot be calling address.
- `operator` cannot be the zero address.

**LSP1 Hooks:**

- If the operator is a contract that supports LSP1 interface, it SHOULD call operator's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: `keccak256('LSP7Tokens_OperatorNotification')` > `0x386072cc5a58e61263b434c722725f21031cd06e7c552cfaa06db5de8a320dbc`
  - `data`: The data sent SHOULD be abi encoded and contain the `tokenOwner` (address), `amount` (uint256) , and the `operatorNotificationData` (bytes) respectively.

<br>

#### revokeOperator

```solidity
function revokeOperator(address operator, bool notify, bytes memory operatorNotificationData) external;
```

Removes `operator` address as an operator of callers tokens.

MUST emit a [RevokedOperator event](#revokedoperator).

_Parameters:_

- `operator` the address to revoke as an operator.
- `notify` the boolean indicating whether to notify the operator via LSP1 or not.
- `operatorNotificationData` the data to send when notifying the operator via LSP1.

_Requirements:_

- `operator` cannot be calling address.
- `operator` cannot be the zero address.

**LSP1 Hooks:**

- If the `notify` parameter is set to `true`, and the operator is a contract that supports LSP1 interface, it SHOULD call operator's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: `keccak256('LSP7Tokens_OperatorNotification')` > `0x386072cc5a58e61263b434c722725f21031cd06e7c552cfaa06db5de8a320dbc`
  - `data`: The data sent SHOULD be abi encoded and contain the `tokenOwner` (address), `amount` (uint256) (0 in case of revoke), and the `operatorNotificationData` (bytes) respectively.

<br>


#### increaseAllowance

```solidity
function increaseAllowance(address operator, uint256 addedAmount, bytes memory operatorNotificationData) external;
```

Increase the allowance of `operator` by `addedAmount`. This is an alternative approach to {authorizeOperator} that can be used as a mitigation for the double spending allowance problem. Notify the operator based on the LSP1-UniversalReceiver standard.

_Parameters:_

- `operator` the address to increase allowance as an operator.
- `addedAmount` the amount to add to the existing allowance of tokens operator has access to.
- `operatorNotificationData` the data to send when notifying the operator via LSP1.

_Requirements:_

- `operator`'s original allowance cannot be zero.

**LSP1 Hooks:**

- If the operator is a contract that supports LSP1 interface, it SHOULD call operator's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: `keccak256('LSP7Tokens_OperatorNotification')` > `0x386072cc5a58e61263b434c722725f21031cd06e7c552cfaa06db5de8a320dbc`
  - `data`: The data sent SHOULD be abi encoded and contain the `tokenOwner` (address), `amount` (uint256) (new allowance) , and the `operatorNotificationData` (bytes) respectively.

<be>

#### decreaseAllowance

```solidity
function decreaseAllowance(address operator, uint256 subtractedAmount, bytes memory operatorNotificationData) external;
```

Decrease the allowance of `operator` by `subtractedAmount`. This is an alternative approach to {authorizeOperator} that can be used as a mitigation for the double spending allowance problem. Notify the operator based on the LSP1-UniversalReceiver standard.

_Parameters:_

- `operator` the address to decrease allowance as an operator.
- `subtractedAmount` the amount to substract to the existing allowance of tokens operator has access to.
- `operatorNotificationData` the data to send when notifying the operator via LSP1.

**LSP1 Hooks:**

- If the operator is a contract that supports LSP1 interface, it SHOULD call operator's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: `keccak256('LSP7Tokens_OperatorNotification')` > `0x386072cc5a58e61263b434c722725f21031cd06e7c552cfaa06db5de8a320dbc`
  - `data`: The data sent SHOULD be abi encoded and contain the `tokenOwner` (address), `amount` (uint256) (new allowance) , and the `operatorNotificationData` (bytes) respectively.

<br>

#### authorizedAmountFor

```solidity
function authorizedAmountFor(address operator, address tokenOwner) external view returns (uint256);
```

Returns amount of tokens `operator` address is authorized to spent from `tokenOwner`.
Operators can send and burn tokens on behalf of their owners. The tokenOwner is their own operator.

_Parameters:_

- `operator` the address to query operator status for.

**Returns:** `uint256`, the amount of tokens `operator` has access to from `tokenOwner`.

### getOperatorsOf

```solidity
function getOperatorsOf(address tokenOwner) external view returns (address[] memory);
```

Returns a list of operators allowed to transfer tokens on behalf of a `tokenOwner` from its balance. Their balance can be queried via [`authorizedAmountFor(address,address)`](#authorizedamountfor)

_Parameters:_

- `tokenOwner` the address to query the list of operators for.

**Returns:** `address[]`, a list of token `operator`s for `tokenOwner`.

#### transfer

```solidity
function transfer(address from, address to, uint256 amount, bool force, bytes memory data) external;
```

Transfers `amount` of tokens from `from` to `to`. The `force` parameter will be used when notifying the token sender and receiver and revert.

MUST emit a [Transfer event](#transfer) when transfer was successful.

_Parameters:_

- `from` the sending address.
- `to` the receiving address.
- `amount` the amount of tokens to transfer.
- `force` when set to TRUE, `to` may be any address; when set to FALSE `to` must be a contract that supports [LSP1 UniversalReceiver][LSP1] and not revert.
- `data` additional data the caller wants included in the emitted event, and sent in the hooks to `from` and `to` addresses.

_Requirements:_

- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `amount` tokens must be owned by `from`.
- If the caller is not `from`, it must be an operator for `from` with access to at least `amount` tokens.

**LSP1 Hooks:**

- If the token sender is a contract that supports LSP1 interface, it SHOULD call the token sender's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: keccak256('LSP7Tokens_SenderNotification') > `0x429ac7a06903dbc9c13dfcb3c9d11df8194581fa047c96d7a4171fc7402958ea`
  - `data`: The data sent SHOULD be packed encoded and contain the `sender` (address), `receiver` (address), `amount` (uint256) and the `data` (bytes) respectively.

<br>

- If the token recipient is a contract that supports LSP1 interface, it SHOULD call the token recipient's [`universalReceiver(...)`] function with the parameters below:

  - `typeId`: keccak256('LSP7Tokens_RecipientNotification') >`0x20804611b3e2ea21c480dc465142210acf4a2485947541770ec1fb87dee4a55c`
  - `data`: The data sent SHOULD be packed encoded and contain the `sender` (address), `receiver` (address), `amount` (uint256) and the `data` (bytes) respectively.

**Note:** LSP1 Hooks MUST be implemented in any type of token transfer (mint, transfer, burn, transferBatch).

#### transferBatch

```solidity
function transferBatch(address[] memory from, address[] memory to, uint256[] memory amount, bool force, bytes[] memory data) external;
```

Transfers many tokens based on the list `from`, `to`, `amount`. If any transfer fails, the call will revert.

MUST emit a [Transfer event](#transfer) for each transfered token.

_Parameters:_

- `from` the list of sending addresses.
- `to` the list of receiving addresses.
- `amount` the amount of tokens to transfer.
- `force` when set to TRUE, `to` may be any address; when set to FALSE `to` must be a contract that supports [LSP1 UniversalReceiver][LSP1] and not revert.
- `data` the list of additional data the caller wants included in the emitted event, and sent in the hooks to `from` and `to` addresses.

_Requirements:_

- `from`, `to`, `amount` lists are the same length.
- no values in `from` can be the zero address.
- no values in `to` can be the zero address.
- each `amount` tokens must be owned by `from`.
- If the caller is not `from`, it must be an operator for `from` with access to at least `amount` tokens.

### Events

#### Transfer

```solidity
event Transfer(address indexed operator, address indexed from, address indexed to, uint256 amount, bool force, bytes data);
```

MUST be emitted when `amount` tokens is transferred from `from` to `to`.

#### AuthorizedOperator

```solidity
event AuthorizedOperator(address indexed operator, address indexed tokenOwner, uint256 amount, bytes operatorNotificationData);
```

MUST be emitted when `tokenOwner` enables `operator` for `amount` tokens.

#### RevokedOperator

```solidity
event RevokedOperator(address indexed operator, address indexed tokenOwner, bool notify, bytes memory operatorNotificationData);
```

MUST be emitted when `tokenOwner` disables `operator`.

## Rationale

<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->

There should be a base token standard for the LSP ecosystem of contracts, which will allow common tooling and clients to be built. Existing tools and clients that expect [ERC20][ERC20] & [ERC777][ERC777] can be made to work with this standard by using "compatability" contract extensions that match the desired interface.

### Operators

To clarify the ability of an address to access tokens from another address, `operator` was chosen as the name for functions, events and variables in all cases. This is originally from [ERC777][ERC777] standard and replaces the `allowance` functionality from [ERC20][ERC20].

### Token Transfers

There is only one transfer function, which is aware of operators. This deviates from [ERC20][ERC20] and [ERC777][ERC777] which added functions specifically for the token owner to use, and for those with access to tokens. By having a single function to call this makes it simple to move tokens, and the caller will be exposed in the `Transfer` event as an indexed value.

### Usage of hooks

When a token is changing owners (minting, transfering, burning) an attempt is made to notify the token sender and receiver using [LSP1 UniversalReceiver][LSP1] interface. The implementation uses `_notifyTokenSender` and `_notifyTokenReceiver` as the internal functions to process this.

The `force` parameter sent during `function transfer` SHOULD be used when notifying the token receiver, to determine if it must support [LSP1 UniversalReceiver][LSP1]. This is used to prevent accidental token transfers, which may results in lost tokens: non-contract addresses could be a copy paste issue, contracts not supporting [LSP1 UniversalReceiver][LSP1] might not be able to move tokens.

## Implementation

<!--The implementations must be completed before any LIP is given status "Final", but it need not be completed before the LIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->

A implementation can be found in the [lukso-network/lsp-smart-contracts][LSP7.sol];

## Interface Cheat Sheet

```solidity
interface ILSP7 is /* IERC165 */ {

    // ERC173

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() external view returns (address);

    function transferOwnership(address newOwner) external; // onlyOwner

    function renounceOwnership() external; // onlyOwner


    // ERC725Y

    event DataChanged(bytes32 indexed dataKey, bytes dataValue);


    function getData(bytes32 dataKey) external view returns (bytes memory value);

    function setData(bytes32 dataKey, bytes memory value) external; // onlyOwner

    function getDataBatch(bytes32[] memory dataKeys) external view returns (bytes[] memory values);

    function setDataBatch(bytes32[] memory dataKeys, bytes[] memory values) external; // onlyOwner


    // LSP7

    event Transfer(address indexed operator, address indexed from, address indexed to, uint256 amount, bool force, bytes data);

    event AuthorizedOperator(address indexed operator, address indexed tokenOwner, uint256 indexed amount, bytes operatorNotificationData);

    event RevokedOperator(address indexed operator, address indexed tokenOwner, bool notify, bytes operatorNotificationData);


    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner) external view returns (uint256);

    function authorizeOperator(address operator, uint256 amount, bytes memory operatorNotificationData) external;

    function revokeOperator(address to, bool notify, bytes memory operatorNotificationData) external;

    function increaseAllowance(address operator, uint256 addedAmount, bytes memory operatorNotificationData) external;

    function decreaseAllowance(address operator, uint256 subtractedAmount, bytes memory operatorNotificationData) external;

    function authorizedAmountFor(address operator, address tokenOwner) external view returns (uint256);

    function getOperatorsOf(address tokenOwner) external view returns (address[] memory);

    function transfer(address from, address to, uint256 amount, bool force, bytes memory data) external;

    function transferBatch(address[] memory from, address[] memory to, uint256[] memory amount, bool force, bytes[] memory data) external;
    
}

```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: https://eips.ethereum.org/EIPS/eip-165
[ERC20]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
[ERC777]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-777.md
[LSP1]: ./LSP-1-UniversalReceiver.md
[LSP4#erc725ykeys]: ./LSP-4-DigitalAsset-Metadata.md#erc725ykeys
[LSP8]: ./LSP-8-IdentifiableDigitalAsset.md
[LSP7.sol]: https://github.com/lukso-network/lsp-universalprofile-smart-contracts/blob/main/contracts/LSP7DigitalAsset/LSP7DigitalAsset.sol
