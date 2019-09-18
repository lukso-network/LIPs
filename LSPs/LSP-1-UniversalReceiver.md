---
lip: <to be assigned>
title: Universal Receiver
author: JG Carvalho (@jgcarv), Fabian Vogelsteller <@frozeman> 
discussions-to: <URL>
status: Draft
type: <Standards Track (Core, Networking, Interface, ERC)
category (*only required for Standard Track): <LSP>
created: 2019-09-01
requires (*optional): <LIP number(s)>
replaces (*optional): <LIP number(s)>
---


## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->
A interface to allow any contract to be able to receive any arbitrary information. 

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
Similar to a smart contracts fallback function, which allows a contract to be notified of a incoming transaction with value, the Universal Receiver allow for any contract to recevie information about any interaction. 
This allows receiving contracts to react on incoming transfers or other interactions. 


## Motivation
<!--The motivation is critical for LIPs that want to change the Ethereum protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->
There are often the need to inform other smart contracts about actions another smart contract did perform.
A good example are token transfers, where the token smart contract should inform receiving contracts about the transfer.

By creating a universal function that many smart contracts implement, receiving of asset and information can be unified.

In cases where smart contracts function as a profile or wallet over a long time, an upgradable receiver can allow for future assets to be received, without that the interface needs to be changed.


## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (go-ethereum, parity, cpp-ethereum, ethereumj, ethereumjs, and [others](https://github.com/ethereum/wiki/wiki/Clients)).-->
Every contract that comply to the Universal Receiver standard MUST implement:

### Methods

#### universalReceiver

```js
universalReceiver(bytes32 id, bytes data) external returns (bool success)
```

Allows to be called by any external contract to inform it about any transfers, interactions or simple information.

- `bytes32 id` is the hash of a standard (according to ERC165?)

- `bytes data` is a byteArray of arbitrary data. Reciving contracts should take the `id` in consideration to properly decode the `data`. The function MUST revert if `typeId` is not accepted or unknown. 


### Events

#### Received

```js
Received(address, from, bytes32 indexed id, bytes data)
```

This event MUST be emitted when the `universalReceiver` function is succesfully executed.


## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
This is an abstraction of the ideas behind Ethereum ERC223 and ERC777, that contracts are called when they are receiving tokens. With this proposal, we can allow contracts to receive any information over a standardised interface.
This can even be done in an upgradable way, where the receiving code can changed over time to support new standards and assets. 


## Implementation
<!--The implementations must be completed before any LIP is given status "Final", but it need not be completed before the LIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->
 
A solidty example of the described interface:
```solidity
pragma solidity 0.5.10;

interface UniversalReceiver {
    event Recieved(address indexed from, bytes32 indexed id, bytes calldata data);
    function universalReceiver(bytes32 id, bytes calldata data) external;
}
```

The most basic implementation can be achieved as following:

```solidity
pragma solidity 0.5.10;

contract BasicUniversalReceiver is UniversalReceiver {

    function universalReceiver(bytes32 id, bytes calldata data) external {
        emit Received(msg.sender, id, data);
    }

}
```

Implementation to receive and decode a token transfer:
```solidity
pragma solidity 0.5.10;

contract BasicUniversalReceiver is UniversalReceiver {

    event TokenReceived(address tokenContract, address from, address to, uint256 amount);
    bytes32 constant internal TOKEN_RECIEVE = keccak256(abi.encodePacked("TOKEN_RECIEVE")) 

    function toTokenData(bytes memory _bytes) internal pure returns(address _from, address _to, uint256 _amount) {
        require(_bytes.length == 72, "data has wrong size");
        assembly {
            _from := mload(add(add(_bytes, 0x14), 0x0))
            _to := mload(add(add(_bytes, 0x14), 0x14))
            _amount := mload(add(add(_bytes, 0x20), 0x28))
        }
    }

    function universalReceiver(bytes32 id, bytes calldata data) external {
        if(typeId == TOKEN_RECIEVE){
            (address from, address to, uint256 amount) = toTokenData(data);
            emit TokenRecieved(msg.sender, from, to, amount);
        }
        emit Received(msg.sender, id, data);
    }

}
```
## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).