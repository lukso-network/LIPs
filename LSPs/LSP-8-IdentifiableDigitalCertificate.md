---
lip: <to be assigned>
title: Identifiable Digital Certificate
author: Claudio Weck <https://github.com/ClaudioZone> , Matthew Stevens <@mattgstevens>, Ankit Kumar <https://github.com/ankitkumar9018>
discussions-to: https://discord.gg/E2rJPP4 (LUKSO), https://discord.gg/PQvJQtCV (FANZONE)
status: Draft
created: 2021-09-02
requires: LSP1, LSP2, ERC165, ERC725Y
---

<!--You can leave these HTML comments in your merged LIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new LIPs. Note that an LIP number will be assigned by an editor. When opening a pull request to submit your LIP, please use an abbreviated title in the filename, `lip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->
A standard interface for identifiable digital certificates, based on ERC721 for unique and upgradable NFTs. 

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
This standard defines an interface for tokens that are identified with a `tokenId`, based on [ERC721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md).

This standard uses a `bytes32` value for `tokenId` which allows for a wider use case of token identification including numbers, contract addresses, and hashed values (ie. serial numbers).

This standard also includes a set of key value stores that are useful to know what the `tokenId` represents, and metadata about individual `tokenId` as ERC725.

## Motivation
<!--The motivation is critical for LIPs that want to change the Lukso protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->

This standard aims to support use cases not covered by LSP4, by providing identifiable tokens instead of a quantity of tokens. This allows for each `tokenId` to have metadata in an ERC725Y in addition to the metadata of the smart contract that mints the tokens. In this way individual tokens benefit from the flexibility & upgradability of the ERC725Y standard, and transfering a token carries the history of ownership and metadata updates. This is beneficial for a new generation of NFTs.

As LSP4 is also in DRAFT status at this time, this standard additionally aims to find common naming for transfer related functions, as well as hooks behavior to interact with [LSP1](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-1-UniversalReceiver.md)

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (go-ethereum, parity, cpp-ethereum, ethereumj, ethereumjs, and [others](https://github.com/ethereum/wikwi/wiki/Clients)).-->

Every contract that supports to the Identifiable Digital Certificate standard SHOULD implement:

### ERC721 modifications

To be compliant with this standard the required ERC721 needs to be modified as follows:

#### tokenId

All uses of tokenId should be `bytes32` instead of `uint256`.

#### "safe" transfer and mint functions

On the lukso network it is expected that most tokens will be sent to addresses that are contract LSP3Account, so performing the additional check `onERC721Received` is not needed. The `safeTransferFrom` and `_safeMint` functions are removed.

#### _checkOnERC721Received

It is not expected that `onERC721Received` will be implemented by receiving addresses, as the LSP1 standard will be the main use case. Since `safeTransferFrom` and `safeMint` are removed, the function `_checkOnERC721Received` is also removed.

TODO: should we add a check to this standard and the LSP4 standard to ensure that tokens cannot get stuck in a contract that is not able to interact with them.

#### token supply cap

To enforce scarcity of a token, a `uint256 tokenSupplyCap` is provided during initialization. This is used as an invariant check when minting new tokens.

Additionally the following functions have been added to see what the current supply is:

- `function totalSupply()`: Returns the total amount of tokens stored by the contract. (the `tokenSupplyCap` provided)
- `function mintedSupply()`: Returns the number of tokens that have been minted.
- `function mintableSupply()`: Returns the number of tokens available to be minted.



#### Universal Receiver

Aiming for compatibility with LSP4, which is based on ERC777, the smart contract COULD expect receivers to implement LSP1.
This is especially recommended for the LUKSO network, to improve the overall compatibility and future proofness of assets and universal profiles based on [LSP3](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-3-UniversalProfile.md).

ERC721 has a limited concept of hooks, providing only:

- `_beforeTokenTransfer(address from, address to, uint256 tokenId)`.

To align with the current LSP4 implementation, the ERC777 named hooks are added:

- `function _callTokensToSend(address from, address to, bytes32 tokenId, bytes memory data)`
- `function _callTokensReceived(address from, address to, bytes32 tokenId, bytes memory data)`

There is are two small differences to ERC777
- only one `bytes data` is provided in both hooks, whereas in ERC777 there is `bytes userData` and `bytes operatorData`
- in `_callTokensReceived` there is no function param `requireReceptionAck` as it is does not seem to be important when used with LSP1. (TODO: when aligning names, operator/approve pattern, and hooks with LSP4 lets decide if this is needed)

### Keys

#### SupportedStandards:IdentifiableDigitalCertificate

The supported standard SHOULD be `IdentifiableDigitalCertificate`

```json
{
    "name": "SupportedStandards:IdentifiableDigitalCertificate",
    "key": "TODO",
    "keyType": "Mapping",
    "valueContent": "TODO",
    "valueType": "bytes"
}
```

#### LSP4Metadata

The description of the asset, to be stored in the ERC725Y of the contract which mints tokens.

```json
{
    "name": "LSP4Metadata",
    "key": "0x9afb95cacc9f95858ec44aa8c3b685511002e30ae54415823f406128b85b238e",
    "keyType": "Singleton",
    "valueContent": "JSONURL",
    "valueType": "bytes"
}
```

For construction of the JSONURL value see: [ERC725Y JSON Schema](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#jsonurl-example)

The linked JSON file SHOULD have the following format:

```js
{
    "LSP4Metadata": {
        "description": "string",
        "links": [ // links related to DigitalCertificate
            {
                "title": "string", // a title for the link.
                "url": "string" // the link itself
            },
            ...
        ],
        "images": [ // multiple images in different sizes, related to the DigitalCertificate, image 0, should be the main image
            [
                {
                    "width": Number,
                    "height": Number,
                    "hashFunction": 'keccak256(bytes)',
                    "hash": 'string', // bytes32 hex string of the image hash
                    "url": 'string'
                },
                ...
            ],
            [...]
        ],
        "assets": [{
            "hashFunction": 'keccak256(bytes)',
            "hash": 'string',
            "url": 'string',
            "fileType": 'string'
        }]
    }
}
```

#### LSP4Creators[]

An array of (ERC725Account) addresses of creators,

```json
{
    "name": "LSP4Creators[]",
    "key": "0x114bd03b3a46d48759680d81ebb2b414fda7d030a7105a851867accf1c2352e7",
    "keyType": "Array",
    "valueContent": "Number",
    "valueType": "uint256",
    "elementValueContent": "Address",
    "elementValueType": "address"
}
```

For construction of the Asset Keys see: [ERC725Y JSON Schema](https://github.com/lukso-network/LIPs/blob/master/LSPs/LSP-2-ERC725YJSONSchema.md#array)

#### ERC721-LSPXTokenIdType

What the `tokenId` represents in this contract, to be stored in the ERC725Y of the contract which mints tokens. Expected values include uint256, address, bytes32 (for cases where an off-chain value is being represented as a hashed value). (TODO: is there a better way to encode this than `string`)
```json
{
    "name": "ERC721-LSPXTokenIdType",
    "key": "TODO",
    "keyType": "Singleton",
    "valueContent": "String",
    "valueType": "string"
}
```

(TODO: discussion if there are other keys to include in the standard for the contract which mints tokens)

#### ERC721-LSPXTokenIdMetadataMintedBy

The `address` of the contract which minted this tokenId, to be stored in the ERC725Y of a `tokenId` metadata conract.

```json
{
    "name": "ERC721-LSPXTokenIdMetadataMintedBy",
    "key": "TODO",
    "keyType": "Singleton",
    "valueContent": "Address",
    "valueType": "address"
}
```

#### ERC721-LSPXTokenIdMetadataTokenId

The `bytes32` of the `tokenId` this metadata is for, to be stored in the ERC725Y of a `tokenId` metadata conract.

```json
{
    "name": "ERC721-LSPXTokenIdMetadataTokenId",
    "key": "TODO",
    "keyType": "Singleton",
    "valueContent": "Bytes32",
    "valueType": "bytes32"
}
```

(TODO: discussion if there are other TokenIdMetadata keys to include in the standard)


## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->


## Implementation
<!--The implementations must be completed before any LIP is given status "Final", but it need not be completed before the LIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->

A implementation can be found in the [lukso-network/universalprofile-smart-contracts](https://github.com/fanzone-media/universalprofile-smart-contracts/blob/permissions/contracts/ERC721-LSPX/ERC721-LSPX.sol);

ERC725Y JSON Schema `LSPXIdentifiableDigitalCertificate`:

```json
[
    {
        "name": "SupportedStandards:LSPXIdentifiableDigitalCertificate",
        "key": "TODO",
        "keyType": "Mapping",
        "valueContent": "TODO",
        "valueType": "bytes"
    },
    {
        "name": "LSP4Metadata",
        "key": "0x9afb95cacc9f95858ec44aa8c3b685511002e30ae54415823f406128b85b238e",
        "keyType": "Singleton",
        "valueContent": "JSONURL",
        "valueType": "bytes"
    },
    {
        "name": "LSP4Creators[]",
        "key": "0x114bd03b3a46d48759680d81ebb2b414fda7d030a7105a851867accf1c2352e7",
        "keyType": "Array",
        "valueContent": "Number",
        "valueType": "uint256",
        "elementValueContent": "Address",
        "elementValueType": "address"
    }
]
```

## Interface Cheat Sheet

```solidity
/**
 * @dev Required interface of an ERC721-LSPX compliant contract.
 */
interface IERC721LSPX is IERC165 {
    //
    // --- Events
    //

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        bytes32 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        bytes32 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Emitted when `tokenId` has a metadata contract created at `storageContract`
     */
    event MetadataCreated(
        bytes32 indexed tokenId,
        address indexed storageContract
    );

    //
    // --- Token queries
    //

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the number of tokens that have been minted.
     */
    function mintedSupply() external view returns (uint256);

    /**
     * @dev Returns the number of tokens available to be minted.
     */
    function mintableSupply() external view returns (uint256);

    /**
     * @dev Returns a bytes32 array of all token holder addresses
     */
    function allTokenHolders() external view returns (bytes32[] memory);

    //
    // --- Token ID queries
    //

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     *
     * * Requirements:
     *
     * - `owner` cannot be the zero address.
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(bytes32 tokenId) external view returns (address);

    //
    // --- Metadata functionality
    //

    /**
     * @dev Returns the metadata address of the `tokenId` token;
     *
     * * Requirements:
     *
     * - `tokenId` must exist.
     */
    function metadataOf(bytes32 tokenId) external view returns (address);

    //
    // --- Approval functionality
    //

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(bytes32 tokenId) external view returns (address);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, bytes32 tokenId) external;

    //
    // --- Transfer functionality
    //

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        bytes32 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        bytes32 tokenId,
        bytes calldata data
    ) external;

    // Pausable

    event Paused(address account);

    event Unpaused(address account);

    function paused() public view virtual returns (bool);

    function pause() external whenNotPaused onlyDefaultOperators;

    function unpause() external whenPaused onlyDefaultOperators;


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
