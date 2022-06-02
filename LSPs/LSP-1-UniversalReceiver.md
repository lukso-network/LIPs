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
An entry function enabling a contract to receive arbitrary information.

## Abstract
<!--A short (~200 word) description of the technical issue being addressed.-->
Similar to a smart contract's fallback function, which allows a contract to be notified of an incoming transaction with a value, the Universal Receiver function allows for any contract to receive information about any interaction.
This allows receiving contracts to react on incoming transfers or other interactions.


## Motivation
<!--The motivation is critical for LIPs that want to change the Ethereum protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the LIP solves. LIP submissions without sufficient motivation may be rejected outright.-->
There are often the need to inform other smart contracts about actions another smart contract did perform.
A good example are token transfers, where the token smart contract should inform receiving contracts about the transfer.

By creating a universal function that many smart contracts implement, receiving of asset and information can be unified.

In cases where smart contracts function as a profile or wallet over a long time, an upgradable universal receiver can allow for future assets to be received, without the need for the interface to be changed.

## Specification

[ERC165] interface id: `0x6bb56a14`

Every contract that complies with the Universal Receiver standard MUST implement:

### Methods

#### universalReceiver

```solidity
universalReceiver(bytes32 typeId, bytes memory data) public returns (bytes memory)
```

Allows to be called by any external contract to inform the contract about any incoming transfers, interactions or simple information.

_Parameters:_

- `typeId` is the hash of a standard, or the type relative to the `data` received.

- `data` is a byteArray of arbitrary data. Receiving contracts should take the `typeId` in consideration to properly decode the `data`.

_Returns:_ `bytes`, which can be used to encode response values.

### Events

#### UniversalReceiver

```solidity
event UniversalReceiver(address indexed from, bytes32 indexed typeId, bytes indexed returnedValue, bytes receivedData)
```

This event MUST be emitted when the `universalReceiver` function is succesfully executed.

_Values:_

- `from` is the address calling the `universalReceiver(..)` function.

- `typeId` is the hash of a standard, or the type relative to the `data` received.

- `returnedValue` is the data returned from the `universalReceiver(..)` function.

- `receivedData` is a byteArray of arbitrary data received.


## UniversalReceiverDelegate

The UniversalReceiverDelegate is an optional extension that could be used with the `universalReceiver(..)` function, where the `typeId` and `data` received to the function is forwarded to the UniversalReceiverDelegate contract that can be customized to react on certain combination of `typeId` and `data`.

The address of the UniversalReceiverDelegate **MUST** be changable in the contract implementing the `unviersalReceiver(..)` function to have the option to change how the contract react on upcoming information and assets transfers in the future.

_Could be done by having a setter function for the UniversalReceiverDelegate address._

### Specification

ERC165 interface id: `0xc2d7bcc1`


```solidity
universalReceiverDelegate(address caller, bytes32 typeId, bytes memory data) public returns (bytes memory);
```

Allows to be called by any external contract when an address wants to delegate its universalReceiver functionality to another smart contract.

_Parameters:_

- `caller` is the address calling the original `universalReceiver` function.

- `typeId` is the hash of a standard, or the type relative to the `data` received.

- `data` is a byteArray of arbitrary data. Receiving contracts should take the `typeId` in consideration to properly decode the `data`. 

_Returns:_ `bytes`, which can be used to encode response values.

## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
This is an abstraction of the ideas behind Ethereum [ERC223](https://github.com/ethereum/EIPs/issues/223) and [ERC777](https://eips.ethereum.org/EIPS/eip-777), that contracts are called when they are receiving tokens. With this proposal, we can allow contracts to receive any information over a standardised interface.
This can even be done in an upgradable way, where the receiving code can be changed over time to support new standards and assets. 

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/tree/develop/contracts/LSP1UniversalReceiver) repository.

### UniversalReceiver Example:

After transfering token from `TokenABC` to `MyWallet`, the owner of `MyWallet` contract can know looking at the UniversalReceiver event emitted that the `typeId` is `_TOKEN_RECEIVING_HASH` and then he could look into the `data` to know the token sender address and the amount sent.

```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;


contract TokenABC {

    // Hash of the word `_TOKEN_RECEIVING_HASH`
    bytes32 constant public _TOKEN_RECEIVING_HASH = 0x7901c95ea4b5fe1fba45bb8c10d7ddabf715dea547785f933d8be283925c4883;

    bytes4 _INTERFACE_ID_LSP1 = 0x6bb56a14;

    function sendToken(address to, uint256 amount) public {
        balance[msg.sender] -= amount;
        balance[to] += amount;
        _informTheReceiver(to, amount); 
    }

    function _informTheReceiver(address receiver, uint256 amount) internal {
        // If the contract receiving the tokens supports LSP1 InterfaceID then call the unviersalReceiver function
        if(ERC165Checker.supportsInterface(receiver,_INTERFACE_ID_LSP1)){
            ILSP1(receiver).universalReceiver(_TOKEN_RECEIVING_HASH, abi.encodePacked(msg.sender, amount));
        }
    }
}

contract MyWallet is ERC165, ILSP1 {

    bytes4 _INTERFACE_ID_LSP1 = 0x6bb56a14;

    constructor() public {
        _registerInterface(_INTERFACE_ID_LSP1);
    }

    function universalReceiver(bytes32 typeId, bytes memory data) public returns (bytes memory) {
        emit UniversalReceiver(msg.sender, typeId, 0x0, data);
        return 0x0;
    }
}
```

### UniversalReceiverDelegate Example:

This example is the same example written above except that `MyWallet` contract now supports UniversalReceiverDelegate.
The `TokenABC` contract will inform `MyWallet` contract about the transfer by calling the `universalReceiver(..)` function and this function will call the `universalReceiverDelegate(..)` function on the UniversalReceiverDelegate address set by the owner, to react on the transfer accordingly.

```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;


contract TokenABC {

    // Hash of the word `_TOKEN_RECEIVING_HASH`
    bytes32 constant public _TOKEN_RECEIVING_HASH = 0x7901c95ea4b5fe1fba45bb8c10d7ddabf715dea547785f933d8be283925c4883;

    bytes4 _INTERFACE_ID_LSP1 = 0x6bb56a14;

    function sendToken(address to, uint256 amount) public onlyOwner {
        balance[to] += amount;
        _informTheReceiver(to, amount); 
    }

    function _informTheReceiver(address receiver, uint256 amount) internal {
        // If the contract receiving the tokens supports LSP1 InterfaceID then call the unviersalReceiver function
        if(ERC165Checker.supportsInterface(receiver,_INTERFACE_ID_LSP1)){
            ILSP1(receiver).universalReceiver(_TOKEN_RECEIVING_HASH, abi.encodePacked(address(this),amount));
        }
    }
}

contract MyWallet is ERC165, ILSP1 {

    bytes4 _INTERFACE_ID_LSP1 = 0x6bb56a14;
    bytes4 _INTERFACE_ID_LSP1_DELEGATE = 0xc2d7bcc1;

    address public universalReceiverDelegate;

    constructor() public {
        _registerInterface(_INTERFACE_ID_LSP1);
    }

    function setUniversalReceiverDelegate(address _newUniversalReceiverDelegate) public onlyOwner {
        // The address set should support LSP1Delegate InterfaceID
        universalReceiverDelegate = _newUniversalReceiverDelegate;
    }

    function universalReceiver(bytes32 typeId, bytes memory data) public returns (bytes memory) {

        // if the address set as universalReceiverDelegate supports LSP1Delegate then call the universalReceiverDelegate function
        if(ERC165Checker.supportsInterface(universalReceiverDelegate,_INTERFACE_ID_LSP1_DELEGATE)){

            // Call the universalReceiverDelegate function on universalReceiverDelegate address
            returneddata = ILSP1Delegate(universalReceiverDelegate).universalReceiverDelegate(typeId, data);
        }

        emit UniversalReceiver(msg.sender, typeId, returneddata, data);
        return returneddata;
    }
}


contract UniversalReceiverDelegate is ERC165, ILSP1Delegate {

    bytes4 _INTERFACE_ID_LSP1_DELEGATE = 0xc2d7bcc1;

    constructor() public {
        _registerInterface(_INTERFACE_ID_LSP1_DELEGATE);
    }

    function universalReceiverDelegate(address caller, bytes32 typeId, bytes memory data) public returns (bytes memory) {
        // Any logic could be written here:
        // - Interfact with DeFi protocol contract to sell the new tokens received automatically.
        // - Register the token received on other registery contract
        // - Allow only tokens with `_TOKEN_RECEIVING_HASH` hash and reject the others.
        // - revert; so in this way the wallet will have the option to reject any token.
    }
}
```

## Interface Cheat Sheet

```solidity

interface ILSP1  /* is ERC165 */ {

    event UniversalReceiver(address indexed from, bytes32 indexed typeId, bytes indexed returnedValue, bytes receivedData);
    
    
    function universalReceiver(bytes32 typeId, bytes memory data) external returns (bytes memory);
    
}
    
interface ILSP1Delegate  /* is ERC165 */ {
    
    function universalReceiverDelegate(address caller, bytes32 typeId, bytes memory data) external returns (bytes memory);

}
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>