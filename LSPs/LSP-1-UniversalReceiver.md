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

ERC 165 interface id: `0x6bb56a14`

Every contract that complies to the Universal Receiver standard MUST implement:

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

A solidity example of the described interface:
```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.5.0 <0.7.0;

// ERC 165 interface id: `0x6bb56a14`
interface ILSP1 {
    event UniversalReceiver(address indexed from, bytes32 indexed typeId, bytes32 indexed returnedValue, bytes receivedData);

    function universalReceiver(bytes32 typeId, bytes memory data) external returns (bytes32);
}
```

The following interface describes a `ILSP1Delegate` interface.
This is useful when an address wants to delegate its universalReceiver functionality
to another smart contract. This is important for smart contract accounts that want to upgrade the universalReceiver functionality,
without changing its own code.

```solidity
// ERC 165 interface id: `0xc2d7bcc1`
interface ILSP1Delegate  /* is ERC165 */ {

    function universalReceiverDelegate(address sender, bytes32 typeId, bytes memory data) external returns (bytes32);
}

```

### Examples

The most basic implementation can be achieved as following:
```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.6.10;

contract BasicUniversalReceiver is ERC165, ILSP1 {

    bytes4 _INTERFACE_ID_LSP1 = 0x6bb56a14;

    constructor() public {
        _registerInterface(_INTERFACE_ID_LSP1);
    }

    function universalReceiver(bytes32 typeId, bytes memory data) external returns (bytes32) {
        emit UniversalReceiver(msg.sender, typeId, 0x0, data);
        return 0x0;
    }

}
```


Example Implementation of a universalReceiver delegation
```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.6.10;

contract ExternalUniversalReceiver is ERC165, ILSP1 {

    bytes4 _INTERFACE_ID_LSP1 = 0x6bb56a14;
    bytes4 _INTERFACE_ID_LSP1DELEGATE = 0xc2d7bcc1;

    address universalReceiverDelegate;


    constructor(address _universalReceiverDelegate) public {
        _registerInterface(_INTERFACE_ID_LSP1);

        universalReceiverDelegate = _universalReceiverDelegate;
    }

    function universalReceiver(bytes32 _typeId, bytes memory _data) external returns (bytes32 returnValue) {

        if (ERC165(universalReceiverDelegate).supportsInterface(_INTERFACE_ID_LSP1DELEGATE)) {
            returnValue = ILSP1Delegate(universalReceiverDelegate).universalReceiverDelegate(_msgSender(), _typeId, _data);
        }

        emit UniversalReceiver(_msgSender(), _typeId, returnValue, _data);

        return returnValue;
    }
}
```

Example Implementation to receive and decode a simple token transfer:
```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.6.10;

contract UniversalReceiverExample is BasicUniversalReceiver {

    // Custom event we fire
    event TokenReceived(address tokenContract, address from, address to, uint256 amount);
    // Custom type we can decode
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
