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
Similar to a smart contract's fallback function, which allows a contract to be notified of an incoming transaction with a value, the [`universalReceiver(bytes32,bytes)`](#universalReceiver) function allows for any contract to receive information about any interaction.

This allows receiving contracts to react on incoming transfers or other interactions.


## Motivation
There is often the need to inform other smart contracts about actions another smart contract did perform.

A good example are token transfers, where the token smart contract should inform receiving contracts about the transfer.

By creating a universal function that many smart contracts implement, receiving of asset and information can be unified.

In cases where smart contracts function as a profile or wallet over a long time, an upgradable universal receiver can allow for future assets to be received, without the need for the interface to be changed.

## Specification

**LSP1-UniversalReceiver** interface id according to [ERC165]: `0x6bb56a14`.

Smart contracts implementing the LSP1-UniversalReceiver standard MUST implement the [ERC165] `supportsInterface(..)` function and MUST support [ERC165] and LSP1 interface ids.

Every contract that complies with the LSP1-UniversalReceiver standard MUST implement:

### Methods

#### universalReceiver

```solidity
function universalReceiver(bytes32 typeId, bytes memory data) external payable returns (bytes memory)
```

Allows to be called by any external contract to inform the contract about any incoming transfers, interactions or simple information. 

The `universalReceiver(...)` function can be customized to react on a different aspect of the call such as the `typeId`, the data sent, the caller or the value sent to the function (_e.g, reacting on a token or a vault transfer_).

_Parameters:_

- `typeId` is the hash of a standard, or the type relative to the `data` received.

- `data` is a byteArray of arbitrary data. Receiving contracts SHOULD take the `typeId` in consideration to properly decode the `data`.

_Returns:_ `bytes` which can be used to encode response values.

> **Note:** The `universalReceiver(...)` function COULD be allowed to return no data (no return as the equivalent of the opcode instruction `return(memory_pointer, 0)`).
> If any `bytes` data is returned, bytes not conforming to the default ABI encoding will result in a revert. See the [specification for the abi-encoding of `bytes`] for more details.

### Events

#### UniversalReceiver

```solidity
event UniversalReceiver(address indexed from, uint256 indexed value, bytes32 indexed typeId, bytes receivedData, bytes returnedValue);
```

This event MUST be emitted when the `universalReceiver` function is succesfully executed.

_Values:_

- `from` is the address calling the `universalReceiver(..)` function.

- `value` is the amount of value sent to the `universalReceiver(..)` function.

- `typeId` is the hash of a standard, or the type relative to the `data` received.

- `receivedData` is a byteArray of arbitrary data received.

- `returnedValue` is the data returned by the `universalReceiver(..)` function.


## UniversalReceiver Delegation

UniversalReceiver delegation allows to forward the `universalReceiver(..)` call on one contract to another external contract, allowing for upgradeability and changing behaviour of the initial `universalReceiver(..)` call.

### Motivation

The ability to react to upcoming actions with a logic hardcoded within the `universalReceiver(..)` function comes with limitations, as only a fixed functionality can be coded or the [`UniversalReceiver`](#universalreceiver-1) event be fired. 

This section explains a way to forward the call to the `universalReceiver(..)` function to an external smart contract to extend and change funcitonality over time.

The delegation works by simply forwarding a call to the `universalReceiver(..)` function to a delegated smart contract calling the `universalReceiver(..)` function on the external smart contract.
As the external smart contract doesn't know about the inital `msg.sender` and the `msg.value`, this specification proposes to add these values to the `msg.data`. This allows the external contract to strip them from the `msg.data` and understand the address and value of the inital call to the extended smart contract.


### Specification

The **UniversalReceiverDelegate** is an optional extension. It allows the `universalReceiver(..)` function to delegate its functionality to an external contract that can be customized to react differently based on the `typeId` and the `data` received. 

The `universalReceiver(..)` function on the initial smart contract forwards the call to the `universalReceiver(..)` on the **UniversalReceiverDelegate** contract and append the calldata with 52 extra bytes as follows:

- The `msg.sender` calling the initial `universalReceiver(..)` function without any pad, MUST be 20 bytes.
- The `msg.value` received to the initial `universalReceiver(..)` function, MUST be 32 bytes.

The **UniversalReceiverDelegate** smart contract can then understand the `msg.sender` and `msg.value` of the initial smart contract, or ignore the appended data.


## Rationale
This is an abstraction of the ideas behind [ERC223] and [ERC777], that contracts are called when they are receiving tokens or other assets. 

With this proposal, we can allow contracts to receive any information in a generic manner over a standardised interface. 

As this function is generic and only the sent `typeId` changes, smart contract accounts that can upgrade its behaviour using the **UniversalReceiverDelegate** technique can be created. 

The UniversalReceiverDelegate functionality COULD be implemented using `call`, or `delegatecall`, both of which have different security properties.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts] repository.

### UniversalReceiver Example:

After transfering token from `TokenABC` to `MyWallet`, the owner of `MyWallet` contract can know, by looking at the emitted UniversalReceiver event, that the `typeId` is `_TOKEN_RECEIVING_HASH`. 

Enabling the owner to know the token sender address and the amount sent by looking into the `data`.

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

    function universalReceiver(bytes32 typeId, bytes memory data) public payable returns (bytes memory) {
        emit UniversalReceiver(msg.sender, msg.value, typeId, data, 0x);
        return 0x0;
    }
}
```

### UniversalReceiverDelegate Example:

This example is the same example written above except that `MyWallet` contract now delegates the universalReceiver functionality to a UniversalReceiverDelegate contract.

The `TokenABC` contract will inform the `MyWallet` contract about the transfer by calling the `universalReceiver(..)` function. This function will then call the `universalReceiver(..)` function on the UniversalReceiverDelegate address set by the owner, to react on the transfer accordingly.

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

    address public universalReceiverDelegate;

    constructor() public {
        _registerInterface(_INTERFACE_ID_LSP1);
    }

    function setUniversalReceiverDelegate(address _newUniversalReceiverDelegate) public onlyOwner {
        // The address set SHOULD support LSP1Delegate InterfaceID
        universalReceiverDelegate = _newUniversalReceiverDelegate;
    }

    function universalReceiver(bytes32 typeId, bytes memory data) public payable returns (bytes memory) {

        // if the address set as universalReceiverDelegate supports LSP1Delegate then call the universalReceiverDelegate function
        if(ERC165Checker.supportsInterface(universalReceiverDelegate,_INTERFACE_ID_LSP1)){

            // Call the universalReceiverDelegate function on universalReceiverDelegate address
            returnedData = ILSP1(universalReceiverDelegate).universalReceiver(typeId, data);
            
            
            // OR can call with appending extra calldata
            bytes memory callData = abi.encodePacked(
                abi.encodeWithSelector(
                    ILSP1UniversalReceiver.universalReceiver.selector,
                    typeId,
                    receivedData
                ),
                msgSender,
                msgValue
             );

        (bool success, bytes memory result) = universalReceiverDelegate.call(callData);
     

        emit UniversalReceiver(msg.sender, msg.value, typeId, data, returnedData);
        return returnedData;
    }
}




contract UniversalReceiverDelegate is ERC165, ILSP1 {

    bytes4 _INTERFACE_ID_LSP1 = 0x6bb56a14;

    constructor() public {
        _registerInterface(_INTERFACE_ID_LSP1);
    }

    function universalReceiver(bytes32 typeId, bytes memory data) public payable returns (bytes memory) {
        // Any logic could be written here:
        // - Interfact with DeFi protocol contract to sell the new tokens received automatically.
        // - Register the token received on other registery contract.
        // - Allow only tokens with `_TOKEN_RECEIVING_HASH` hash and reject the others.
        // - revert; so in this way the wallet will have the option to reject any token.
    }
    
    // The `msg.sender` of the caller contract and the `msg.value` sent to the caller contract if appended as extra calldata sent to the 
    // delegate contract, can be retrieved using these functions:
    
  
    function _mainMsgSender() internal view virtual returns (address) {
        return address(bytes20(msg.data[msg.data.length - 52:msg.data.length - 32]));
    }



    function _mainMsgValue() internal view virtual returns (uint256) {
       return uint256(bytes32(msg.data[msg.data.length - 32:]));
    }

}
```

## Interface Cheat Sheet

```solidity

interface ILSP1  /* is ERC165 */ {

    event UniversalReceiver(address indexed from, uint256 value, bytes32 indexed typeId, bytes receivedData, bytes returnedValue);
    
    
    function universalReceiver(bytes32 typeId, bytes memory data) external payable returns (bytes memory);
    
}
    
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: <https://eips.ethereum.org/EIPS/eip-165>
[ERC223]: <https://github.com/ethereum/EIPs/issues/223>
[ERC777]: <https://eips.ethereum.org/EIPS/eip-777>
[specification for the abi-encoding of `bytes`]: <https://docs.soliditylang.org/en/v0.8.19/abi-spec.html#formal-specification-of-the-encoding>
[lukso-network/lsp-smart-contracts]: <https://github.com/lukso-network/lsp-smart-contracts/tree/develop/contracts/LSP1UniversalReceiver>
