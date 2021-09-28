---
lip: 7
title: Digital Asset
author: Claudio Weck <https://github.com/ClaudioZone>, Fabian Vogelsteller <fabian@lukso.network>, Matthew Stevens <@mattgstevens>, Ankit Kumar <https://github.com/ankitkumar9018>
discussions-to: https://discord.gg/E2rJPP4 (LUKSO), https://discord.gg/PQvJQtCV (FANZONE)
status: Draft
type: LSP
created: 2021-09-02
requires: LSP1, LSP2, LSP4, ERC165, ERC725Y
---

<!--You can leave these HTML comments in your merged LIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new LIPs. Note that an LIP number will be assigned by an editor. When opening a pull request to submit your LIP, please use an abbreviated title in the filename, `lip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->
A standard interface for digital certificates allowing for tokens to be efficiently minted, traded.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
This standard defines an interface for tokens 

This standard defines a set of key value stores that are useful to know what the `tokenId` represents, and metadata about individual `tokenId`.

## Motivation
<!--The motivation is critical for LIPs that want to change the Lukso protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->

This standard aims to support use cases not covered by LSP7, by using a `tokenId` instead of an amount of tokens. Each `tokenId` may have metadata (either as a on-chain ERC725Y contract or off-chain JSON) in addition to the LSP4 metadata of the smart contract that mints the tokens. In this way a minted token benefits from the flexibility & upgradability of the ERC725Y standard, and transfering a token carries the history of ownership and metadata updates. This is beneficial for a new generation of NFTs.

A commonality with LSP8 is desired so that the two token implementations use similar naming for functions, events, and using hooks to notify token senders and receivers using LSP1.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (go-ethereum, parity, cpp-ethereum, ethereumj, ethereumjs, and [others](https://github.com/ethereum/wikwi/wiki/Clients)).-->


## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->


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
    event Transfer(
        address operator,
        address indexed from,
        address indexed to,
        uint256 indexed amount,
        bytes data
    );

    event AuthorizedOperator(
        address indexed operator,
        address indexed tokenOwner,
        uint256 indexed amount
    );

    event RevokedOperator(
        address indexed operator,
        address indexed tokenOwner,
        uint256 indexed amount
    );

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
