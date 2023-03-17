---
lip: 21
title: Metadata Discovery
author: Jean Cavallera, Samuel Videau, Hugo Masclet, Callum Grindle
discussions-to: https://discord.com/channels/359064931246538762/620552532602912769/930749248365015100
status: Draft
type: LSP
created: 2023-03-17
requires: ERC725Y, LSP2
---

<!--You can leave these HTML comments in your merged LIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new LIPs. Note that an LIP number will be assigned by an editor. When opening a pull request to submit your LIP, please use an abbreviated title in the filename, `lip-draft_title_abbrev.md`. The title should be 44 characters or less.-->

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->
This standard defines the **zero data key** `0x0000000000000000000000000000000000000000000000000000000000000000` as an entry point for an ERC725Y smart to make its metadata publicly discoverable and retrievable.


## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
This standard addresses the issue of making the different schemas used by an ERC725Y contract discoverable for users or applications that interact with the contract for the first time. This is useful for applications that have no prior knowledge of the different JSON schemas used for the metadata, and that do not know where this schema can be obtained off-chain.

## Motivation
<!--The motivation is critical for LIPs that want to change the Lukso protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->
The LSP2 standard provides a schema that enables to read and interpret the metadata of an ERC725Y smart contract in a human friendly. This is also useful for tools to automate encoding and decoding of standard entries in the storage of a ERC725Y smart contract.

### Current Problem

Despite the benefits that LSP2 provides, a problem around metadata remains: 

_how can someone that does not know the set of ERC725Y JSON schemas used by a smart contract can read + decode the data from the contract storage in the first place?_

With no prior knowledge of the schemas, the contract metadata cannot be fetched as the schema helps to construct the `bytes32` data key, so that the contract can be queried to fetch data from it.

### Existing Solutions

Currently, the JSON schemas can be obtained through various ways, including public/private Github repositories, documentation websites, README, packages or Gist. There is no standard "rules" or recommendations on where and how these schemas should be shared, which leads to a need for a "LSP2 JSON sharing" model, a way to store the link of the JSON Metadat where the schemas can be retrieved from.

The only way to be able to read all the data of an ERC725Y contract without prior knowledge of it is to be aware of all the schemas available. In the previous "link sharing model", users and participants are aware of the schemas through third party services, where the schemas are hosted and published. To accomplish this without a trusted party, the schemas must be publicly discoverable, and we need a system for participants to agree on a single method to retrieve these schemas and the metadata.

One approach can be to store the external URL inside the smart contract on-chain.

A common solution is to introduce a state variable inside the smart contract that can be publicly queried. However, using this method creates several limitations and inconsistencies:

1. different smart contracts implementations can use different variable names or getter functions
2. different smart contracts implementations can store the Metadata Schema URL at different slots in the storage.

This lead to a non-standard way to retrieve this important information, as there is no "standard rule" for retrieving these schemas.

We need a way for users and tools:
- to know **how to retrieve** the JSON Schemas of the publicly available metadata.
- to know **how to remember** how the schemas can be retrieved.

### Proposed Solution

For our purpose, we use a single unique and easy to remember `bytes32` data key: the **zero data key**: `0x0000000000000000000000000000000000000000000000000000000000000000`.

The advantage of the **zero data key** over other data keys is that it is unique and easy to remember, while the hash of the data key requires to remember the hash of the data that was hashed to obtain the `bytes32` data key.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (go-ethereum, parity, cpp-ethereum, ethereumj, ethereumjs, and [others](https://github.com/ethereum/wiki/wiki/Clients)).-->

The following schema defines the **zero data key** to make schemas and metadata of an ERC725Y smart contract publicly discoverable.

```json
{
    "name": "LSP21MetadataDiscovery",
    "key": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "keyType": "Singleton",
    "valueType": "string",
    "valueContent": "<JSON|JSONURL>"
}
```

The data stored under the **zero data key** can be one of the following two options:
- **on-chain**: a `JSON` file as utf8 encoded string.
- **off-chain**: a `JSONURL` linking to

_Requirements_

Whether the Schemas are stored on or off-chains, the JSON data MUST adhere to the following requirements:
- MUST be an array of Metadata JSON schemas that comply with the [LSP2 JSON Schema object format](./LSP-2-ERC725YJSONSchema.md#specification).

### When the Schemas are stored on-chain

- _What are the requirements_
- _Put an example here_


### When the Schemas are stored off-chain

- _What are the additional requirements_
- _Put an example here_


## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->

The link to the schema can point to either a decentralised storage networks like IPFS or centralised servers like private Google Drive, according to the preference of the user.

So when a user, tool or an other smart contract want to read and interact with the ERC725Y Metadata of a contract that it does not know, it can just fetch that JSON Schema from the zero data key to discover the metadata publicly available and then extract the data from the store.

Making the metadata publicly discoverable through the **zero data key**

- if you interact with an unknown ERC725Y, you’ll still be able to fetch data
- if a project get abandoned or whatever, the ERC725Yjson will still be there, and will not be lost

The **zero data key** also enable custom data keys (_e.g: `CollectionDescription`, `CollectionImage`_) that are custom to a specific user (e.g: a Universal Profile) to be publicly discoverable.

Some objections that the metadata key raise are that through this method, any metadata can now be more publicly visible and accessible. This can be a debate as users or smart contracts might not necessarily want to make all there metadata publicly known and discoverable. Some might not necessarily want anyone to be able to look up certain metadata. For instance, a user might want to attach some specific data to his Universal Profile but keep it hidden from the publicly, so that only the Universal Profile owner (the actual user) know how to access it because he knows the data key. Therefore, some users might want not include the schema of metadata they want to keep secret inside the JSON linked to the **zero data key**. 

## Backwards Compatibility
<!--All LIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The LIP must explain how the author proposes to deal with these incompatibilities. LIP submissions without a sufficient backwards compatibility treatise may be rejected outright.-->

## Test Cases
<!--Test cases for an implementation are mandatory for LIPs that are affecting consensus changes. Other LIPs can choose to include links to test cases if applicable.-->

## Implementation
<!--The implementations must be completed before any LIP is given status "Final", but it need not be completed before the LIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
