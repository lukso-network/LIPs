---
lip: <to be assigned>
title: Universal Reciever
author: JG Carvalho (@jgcarv), Fabian Vogelsteller <@frozeman> 
discussions-to: <URL>
status: Draft
type: <Standards Track (Core, Networking, Interface, ERC)
category (*only required for Standard Track): <LSP>
created: 2019-09-01
requires (*optional): <LIP number(s)>
replaces (*optional): <LIP number(s)>
---

<!--You can leave these HTML comments in your merged LIP and delete the visible duplicate text guides, they will not appear and may be helpful to refer to if you edit it again. This is the suggested template for new LIPs. Note that an LIP number will be assigned by an editor. When opening a pull request to submit your LIP, please use an abbreviated title in the filename, `lip-draft_title_abbrev.md`. The title should be 44 characters or less.-->
This is the suggested template for new LIPs.

Note that an LIP number will be assigned by an editor. When opening a pull request to submit your LIP, please use an abbreviated title in the filename, `lip-draft_title_abbrev.md`.

The title should be 44 characters or less.

## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->
A interface to allow any contract to be able to recieve an arbitrary information. 

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
Similar to the fallback function, which allows a contract to be notified of a incoming transaction with value, the Universal Reciever aims to allow for a contract to be informed that another entity is interacting with it. 

This makes possible for contracts to take necessary actions regarding the ongoing transaction. This is an abstraction of the ideas behind Ethereum ERC223 and ERC777, among others, that call contracts when they're transfering/recieving tokens. Those standards define parameters useful for token transfers, but not much else. With this proposal, we can expand the functionality defined in those ERCs.    

## Motivation
<!--The motivation is critical for LIPs that want to change the Ethereum protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->
There're a wild range of applications beyond simple tokens that could make use of a standardized recieving functionality, which ranges from oracles, DAOS and other applications. This LIP may allow for easier integration between different systems, and if implemented with some sort of upgradability can become future proof for other kinds of yet to exists contracts. 

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (go-ethereum, parity, cpp-ethereum, ethereumj, ethereumjs, and [others](https://github.com/ethereum/wiki/wiki/Clients)).-->
Every contract that comply to the Universal Reciever standard MUST implement:

* The function `universalReciever`, which accepts two parametes: a `bytes32 typeId` and a `bytes data`. The `typeId` is used for definind which kind of information is being transmitted in the call, and the `data` is a byteArray of this arbitrary data. Reciving contracts should take the `typeId` in consideration to properly decode the `data`. The functoin MUST revert if `typeId` is not accepted or unknown. 


* The event `Received`, which accepts two parametes: a `bytes32 typeId` and a `bytes data`. This event MUST be emitted when the `universalReciever` function is succesfully executed.


## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->



## Implementation
<!--The implementations must be completed before any LIP is given status "Final", but it need not be completed before the LIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->
 
A solidty example of the described interface:
```solidity
pragma solidity 0.5.10;

interface UniversalReciever {
    event Recieved(bytes32 typeId, bytes calldata data);
    function universalReciever(bytes32 typeId, bytes calldata data) external;
}
```
The most basic implementation can be achieved as following:

```solidity
pragma solidity 0.5.10;

contract BasicUniversalReciever is UniversalReciever {

    function universalReciever(bytes32 typeId, bytes calldata data) external {
        emit Received(sender,typeId,data);
    }

}
```
But that isin't particularly useful and therefore we provide a incremented implemantion which can be used for recivieng tokens.

```solidity
pragma solidity 0.5.10;

contract BasicUniversalReciever is UniversalReciever {

    event TokenRecieved(address token,address from, address to, uint256 amount);
    bytes32 constant internal TOKEN_RECIEVE = keccak256(abi.encodePacked("TOKEN_RECIEVE")) 

    function toTokenData(bytes memory _bytes) internal pure returns(address _from, address _to, uint256 _amount) {
        require(_bytes.length == 72, "data has wrong size");
        assembly {
            _from := mload(add(add(_bytes, 0x14), 0x0))
            _to := mload(add(add(_bytes, 0x14), 0x14))
            _amount := mload(add(add(_bytes, 0x20), 0x28))
        }
    }

    function universalReciever(bytes32 typeId, bytes calldata data) external {
        if(typeId == TOKEN_RECIEVE){
            (address from, address to,uint amount) = toTokenData(data);
            emit TokenRecieved(sender, from,to, amount);
        }
        emit Received(sender,typeId,data);
    }

}
```
## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).