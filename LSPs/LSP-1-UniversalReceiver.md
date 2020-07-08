---
lip: 1
title: Universal Receiver
author: JG Carvalho (@jgcarv), Fabian Vogelsteller <@frozeman> 
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2019-09-01
requires: ERC165
---


## Simple Summary
<!--"If you can't explain it simply, you don't understand it well enough." Provide a simplified and layman-accessible explanation of the LIP.-->
A entry function to allow a contract to be able to receive any arbitrary information. 

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

```solidity
universalReceiver(bytes32 typeId, bytes data) external returns (bytes32)
```

Allows to be called by any external contract to inform the contract about any incoming transfers, interactions or simple information.

- `bytes32 typeId` is the hash of a standard (according to ERC165?)

- `bytes data` is a byteArray of arbitrary data. Reciving contracts should take the `id` in consideration to properly decode the `data`. The function MUST revert if `id` is not accepted or unknown. 

Returns `bytes32`, which can be used to encode response values.
**If the receiving should fail the function MUST revert.**


### Events

#### UniversalReceiver

```solidity
event UniversalReceiver(address indexed from, bytes32 indexed typeId, bytes32 indexed returnedValue, bytes receivedData)
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
// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.5.0 <0.7.0;

interface ILSP1 {
    event UniversalReceiver(address indexed from, bytes32 indexed typeId, bytes32 indexed returnedValue, bytes receivedData);

    function universalReceiver(bytes32 typeId, bytes memory data) external returns (bytes32);
}

```

The most basic implementation can be achieved as following:

```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.6.10;

contract BasicUniversalReceiver is ILSP1 {

    function universalReceiver(bytes32 typeId, bytes memory data) external returns (bytes32) {
        emit UniversalReceiver(msg.sender, typeId, 0x0, data);
        return 0x0;
    }

}
```

Example Implementation to receive and decode a simple token transfer:
```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.6.10;

contract BasicUniversalReceiver is UniversalReceiver {

    event TokenReceived(address tokenContract, address from, address to, uint256 amount);
    bytes32 constant internal TOKEN_RECEIVE = keccak256("TOKEN_RECEIVE");

    function toTokenData(bytes memory _bytes) internal pure returns(address _from, address _to, uint256 _amount) {
        require(_bytes.length == 72, "data has wrong size");
        assembly {
            _from := mload(add(add(_bytes, 0x14), 0x0))
            _to := mload(add(add(_bytes, 0x14), 0x14))
            _amount := mload(add(add(_bytes, 0x20), 0x28))
        }
    }

    function universalReceiver(bytes32 typeId, bytes calldata data) external returns (bytes32) {
        if(typeId == TOKEN_RECEIVE){
            (address from, address to, uint256 amount) = toTokenData(data);
            emit TokenReceived(msg.sender, from, to, amount);
        }
        emit UniversalReceiver(msg.sender, typeId, 0x0, data);
        
        return 0x0;
    }

}
```
## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
