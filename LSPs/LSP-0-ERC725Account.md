---
lip: 0
title: ERC725 Account
author: Fabian Vogelsteller <fabian@lukso.network>
discussions-to: https://discord.gg/E2rJPP4
status: Draft
type: LSP
created: 2021-09-21
requires: ERC165, ERC725X, ERC725Y, ERC1271, LSP1, LSP2, LSP14, LSP17, LSP20
---

## Simple Summary

The **ERC725Account** standard outlines a blockchain smart contract account that integrates a suite of standards, including [ERC725], to **represent and manage digital identities**.

## Abstract

This standard defines a blockchain-based account system that can be used by humans, machines, organizations or other smart contracts.

Key functionalities of this account system include:

- **Dynamic Information Attachment**: Leveraging [ERC725Y] for adding generic information to the account post-deployment.

- **Generic Execution**: Utilizing [ERC725X] to grant the account the capability to interact with other contracts, manage token transfers, and initiate contract creation with different operations.

- **Signature Verification**: Utilizing [ERC1271] to verify whether the signature on behalf of the account is valid.

- **Notifications and Reactivity**: Through [LSP1-UniversalReceiver], enabling the account to be aware of assets or any other information and react accordingly (e.g., denying specific tokens).

- **Secured Ownership Management**: Enforced by [LSP14-Ownable2Step], ensuring transfer of ownership is secured through a 2-step process.

- **Future-Proof Functionalitys**: Through [LSP17-ContractExtension], allowing the account to extend and support new standardized functions and interfaceIds over time.

- **Streamlined Account Interaction**: Via [LSP20-CallVerification], enabling direct function calls on the account from addresses other than the owner, with verification of the call occurring on the owner if it is a contract.

## Motivation

### Limitations of Externally Owned Accounts

Using Externally Owned Accounts (EOAs) as main accounts poses challenges in different aspects. The significant limitations include:

- **No Information Attachment**: EOAs cannot store data that is readeable by off-chain clients or other smart contracts.

- **Weak Security**:The account, represented by a public key is controlled by its corresponding private key; if the private key leaks or is lost, all associated assets, reputation, and control over other smart contracts are also lost.

- **Exclusive Control**: Sharing the private key with other entities is not an option, as possession equals full control. This exclusivity prevents delegation of certain access rights, social recovery, and other shared security measures.

- **Information Tracking Limitation**: EOAs do not allow for the internal tracking of asset transfers, followers, or other information. As a result, account holders must depend on external blockchain explorers to monitor their transaction history, which introduce inconvenience and slow down information access.

### Lack of Standardization of Accounts

The absence of a standardized specification for blockchain accounts presents several challenges:

- **Complex Development Landscape**: The lack of a standard account template in blockchain leads to a diverse and complex array of custom smart contract accounts created by individual developers and organizations, which make it harder for other developers to build protocols on top of it.

- **Adoption and Compatibility Hurdles**: This diversity necessitates extra compatibility work, slowing the adoption and practical use of smart contract accounts across the blockchain ecosystem.

### Advantages of Smart Contract Accounts

Adopting smart contract accounts over traditional EOAs streamlines blockchain infrastructure use. Smart contracts enable advanced features and enhanced control, such as:

- **Dynamic Information Storage**: Unlike EOAs, smart contract accounts can record static information, making them self-explanatory entities that can assist in identity verification for off-chain entities, and enable the decentralized tracking of any information stored such as assets, followers, etc. The information stored can also be standardized, for example [LSP3-Profile-Metadata] for storing profile information, [LSP5-ReceivedAssets] for storing the addresses of received assets, and [LSP10-ReceivedVaults] for storing addresses of received vaults, etc ..

- **Upgradeable Security**: Owners can use a simple EOA for owning the account having basic level of security, or opt for an owner having a multisignature setup, or permissions access control contracts providing advanced layer of security in contorlling the account.

- **Inclusive Control**: Users can decide to own the account with a permission based access control contract (e.g: the [LSP6-KeyManager]) which allows owners to assign specific rights to different actors, like granting a party the right to update profile information without providing full transactional authority.

- **Extended Execution Capabilities**: Smart contract accounts can employ a broader set of operations compared to EOAs, including _delegatecall_, _staticcall_, and _create2_. This extension of capabilities allows for a wide range of actions and interactions that were previously not possible with standard EOAs.

- **Notifications and Automated Interaction Handling**: The ability to be notified about different actions, and automate the responses to incoming information empowers smart contract accounts with a higher degree of functionality. When assets are received or certain data is detected, the account can autonomously initiate actions or updates, tailored to the event, enhancing the user experience and potential for automation within the blockchain ecosystem using ([LSP1-UniversalReceiver]).

## Specification

### InterfaceId Calculation

**LSP0-ERC725Account** interface id according to [ERC165]: `0x24871b3d`.

This `bytes4` interface id is calculated as the `XOR` of the following:

- The selector of the [`batchCalls(bytes[])`](#batchcalls) function signature.
- The ERC165 interface ID of the **[ERC725X]** standard.
- The ERC165 interface ID of the **[ERC725Y]** standard.
- The ERC165 interface ID of the **[ERC1271]** standard (= `isValidSignature(bytes32,bytes)` function selector).
- The ERC165 interface ID of the **[LSP1-UniversalReceiver]** standard.
- The ERC165 interface ID of the **[LSP14-Ownable2Step]** standard.
- The ERC165 interface ID of the **[LSP17-ContractExtension]** standard.
- The ERC165 interface ID of the **[LSP20-CallVerification]** standard.

### Exclusive Called Functions Behavior

#### Owner Specific Functions

For smart contracts adhering to the **LSP0-ERC725Account** standard, certain functions are designated to be owner-exclusive and include:

- `setData(bytes32,bytes)`
- `setDataBatch(bytes32[],bytes[])`
- `execute(uint256,address,uint256,bytes)`
- `executeBatch(uint256[],address[],uint256[],bytes[])`
- `transferOwnership(address)`
- `renounceOwnership()`

These functions are designed to be initiated by the account owner to perform crucial operations like updating data, executing transactions, and transferring or renouncing ownership.

However, in alignment with the [LSP20-CallVerification] standard, these owner-exclusive functions can also be invoked by addresses allowed by the logic of the owner. This invocation triggers an internal verification process to the owner.

For example, if the caller address is not the owner, the function will call the `lsp20VerifyCall(..)` on the owner address function to validate the transaction before execution passing the following arguments:

- `requestor`: The address calling the function to be executed.
- `target`: The address of the account.
- `caller`: The address calling the function to be executed.
- `value`: The value sent by the caller to the function called on the account.
- `receivedCalldata`: The calldata sent by the caller to the account.

The expected outcome is for the `bytes4` returned value to match the first `bytes3` of the function selector of `lsp20VerifyCall` for the operation to proceed. Specifically, if the fourth byte of the call is `0x01`, the function MUST call `lsp20VerifyCallResult` after execution of the function passing the following arguments:

- `callHash`: The `keccak256` hash of the parameters of `lsp20VerifyCall(address,address,address,uint256,bytes)` parameters packed-encoded (concatened).

- `callResult`: the result of the function being called on the account.
  - if the function being called returns some data, the `callResult` MUST be the value returned by the function being called as abi-encoded `bytes`.
  - if the function being called does not return any data, the `callResult` MUST be an empty `bytes`.

This post verification allows for additional verification steps to be conducted within the transaction process.

#### Pending Owner Specific Functions

The function designated to be called by the pending owner is:

- `acceptOwnership()`

The same logic applies to `acceptOwnership` function, expcet that it should be either called by the pending owner or an address allowed by the pending owner. In case the caller is not the pending owner, the verification should happen according to the [LSP20-CallVerification] on the address of the pending owner.

> Read more about the [Rational behind using LSP20-CallVerifiaction](#lsp20-callverification-usage) in the LSP0-ERC725Account standard.

### Value Receive Notification and Reaction Specification

#### Owner Specific Payable Functions

In smart contracts compliant with the [LSP0-ERC725Account] standard, specific owner-exclusive functions are capable of handling transactions with attached value. These include:

- `setData(bytes32,bytes)`
- `setDataBatch(bytes32[],bytes[])`
- `execute(uint256,address,uint256,bytes)`
- `executeBatch(uint256[],address[],uint256[],bytes[])`

When these functions receive value (LYX or any other native token), the smart contract must emit a `[UniversalReceiver]` event to notify the contract of the value received. The event parameters are as follows:

- `sender`: The address that initiated the function call.
- `value`: The amount of value (in wei) sent with the call.
- `typeId`: A unique identifier indicating a value reception, `keccak256("LSP0ValueReceived")` > `0x9c4705229491d365fb5434052e12a386d6771d976bea61070a8c694e8affea3d`.
- `receivedData`: The first four bytes of the calldata used to call the function, representing its signature.
- `returnedData`: Empty bytes, as these functions do not return data within this event context.

#### User-Callable Payable Functions

For functions that are payable and not restricted to the owner, such as:

- `receive()`
- `fallback()`
- `universalReceiver(bytes32,bytes)`

The contract should trigger the `[universalReceiver]` function logic before the called function execute if value is sent with the call. The arguments for the internal `universalReceiver` logic invocation are:

- typeId: The bytes32 hash obtained by keccak256 hashing of "LSP0ValueReceived".
- receivedData: Depending on the function called:
  - For `receive()`, it should be an empty bytes array.
  - For `fallback()`, it should include the entire calldata.
  - For `universalReceiver()`, it should contain all the calldata received.

After processing the internal logic, the UniversalReceiver event is emitted to signal the transaction and interaction with the smart contract account.

> When the value sent to the fallback function is forwarded to an extension, the universalReceiver function should not be invoked.
> Read more about the [Rational behind using UniversalReceiver](#value-receive-notification-and-reaction) in the payable function of the standard.

### Extending Functionalities and InterfaceIds Specification

#### Extending with Functions

To add a new function to the contract:

- Obtain the function's unique selector.
- Construct an LSP17Extension data key using the function selector.

```json
{
  "name": "LSP17Extension:<bytes4>",
  "key": "0xcee78b4094da860110960000<bytes4>",
  "keyType": "Mapping",
  "valueType": "(address, bytes1)",
  "valueContent": "(Address, bool)"
}
```

> <bytes4\> is the `functionSelector` of the function to extend. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

- Develop a contract that implements the desired function and deploy it to the network.
- Store the deployed contract's address in the account contract under the previously constructed LSP17 data key.

For calls to the account that require forwarding value to the extension, append an additional `0x01` byte to the call. For calls without value transfer, record only the address.

Upon invocation, the extension contract is designed to receive the full call data. An extra 52 bytes are appended to this data, passing compacted the original caller's address (20 bytes) and the sent value (32 bytes). The extension contract may retrieve the caller address and sent value by extracting these details from the calldata's tail end, enabling it to discern the transaction's origin and associated value.

#### Extending InterfaceIds

To support a new InterfaceId:

- Obtain the ERC165 standardized function selector for `supportsInterface(bytes4)`.
- Construct an LSP17Extension data key using the function selector.

```json
{
  "name": "LSP17Extension:<bytes4>",
  "key": "0xcee78b4094da860110960000<bytes4>",
  "keyType": "Mapping",
  "valueType": "(address, bytes1)",
  "valueContent": "(Address, bool)"
}
```

> <bytes4\> is the `functionSelector` of `supportsInterface(bytes4)` function. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

- Develop and deploy a contract that includes the `supportsInterface(bytes4)` function, which is designed to support additional interfaceIds.
- Store the deployed contract's address in the account contract under the previously constructed LSP17 data key.

### Methods

Smart contracts implementing the LSP0 standard MUST implement all of the functions listed below:

#### receive

```solidity
receive() external payable;
```

The receive function allows for receiving native tokens.

**Requirememnts**:

- MUST adhere to the logic specified in [Value Receive Notification and Reaction](#value-receive-notification-and-reaction) section.

#### fallback

```solidity
fallback() external payable;
```

This function is part of the [LSP17-ContractExtension] specification, with additional requirements as follows:

- MUST be payable.
- MUST adhere to the logic specified in [Value Receive Notification and Reaction](#value-receive-notification-and-reaction) section.
- MUST return if the data sent to the contract is less than 4 bytes in length.
- MUST check for address of the extension and a boolean under the following [ERC725Y] Data Key.

  - If there is no extension stored under the data key, the call should revert, except when the function selector is `0x00000000`, if no extension is stored for this function selector, the call will pass.
  - If the data stored is strictly 20 bytes, call the extension and behave according to [LSP17-ContractExtension] specification by appending the caller address and the value sent to the call.
  - If the data stored is 21 bytes, and the 21th byte is strictly `0x01` forward the value received to the extension. In any other case, the value should stay in the account.

```json
{
  "name": "LSP17Extension:<bytes4>",
  "key": "0xcee78b4094da860110960000<bytes4>",
  "keyType": "Mapping",
  "valueType": "(address, bytes1)",
  "valueContent": "(Address, bool)"
}
```

> <bytes4\> is the `functionSelector` called on the account contract. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

> Read more about the [Rational behind using UniversalReceiver] in the payable function of the standard and [the use of 0x00000000 selector for Graffiti].

#### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool);
```

This function is part of the [ERC165] specification, with additional requirements as follows:

- If the interfaceId being queried is not supported by the contract or inherited contracts, the data key attached below MUST be retrieved from the [ERC725Y] storage.

  - If there is an address stored under the data key, forward the `supportsInterface(bytes4)` call to the address and return the value.

  - If there is no address, execution ends normally.

```json
{
  "name": "LSP17Extension:<bytes4>",
  "key": "0xcee78b4094da860110960000<bytes4>",
  "keyType": "Mapping",
  "valueType": "(address, bytes1)",
  "valueContent": "(Address, bool)"
}
```

> <bytes4\> is the `functionSelector` of `supportsInterface(bytes4)` function. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

#### owner

```solidity
function owner() external view returns (address);
```

This function is part of the [LSP14-Ownable2Step] specification.

#### pendingOwner

```solidity
function pendingOwner() external view returns (address);
```

This function is part of the [LSP14-Ownable2Step] specification.

#### transferOwnership

```solidity
function transferOwnership(address newPendingOwner) external;
```

This function is part of the [LSP14-Ownable2Step] specification, with additional requirements as follows:

- MUST adhere to the logic specified in [Exclusive Called Functions Behavior](#exclusive-called-functions-behavior) section.
- MUST override the LSP14 Type ID triggered by using `transferOwnership(..)` to the one below:

  - `keccak256('LSP0OwnershipTransferStarted')` > `0xe17117c9d2665d1dbeb479ed8058bbebde3c50ac50e2e65619f60006caac6926`

#### acceptOwnership

```solidity
function acceptOwnership() external;
```

This function is part of the [LSP14-Ownable2Step] specification, with additional requirements as follows:

- MUST adhere to the logic specified in [Exclusive Called Functions Behavior](#exclusive-called-functions-behavior) section.
- MUST override the LSP14 Type IDs triggered by using `accceptOwnership(..)` to the ones below:

  - `keccak256('LSP0OwnershipTransferred_SenderNotification')` > `0xa4e59c931d14f7c8a7a35027f92ee40b5f2886b9fdcdb78f30bc5ecce5a2f814`

  - `keccak256('LSP0OwnershipTransferred_RecipientNotification')` > `0xceca317f109c43507871523e82dc2a3cc64dfa18f12da0b6db14f6e23f995538`

#### renounceOwnership

```solidity
function renounceOwnership() external;
```

This function is part of the [LSP14-Ownable2Step] specification with additional requirements as follows:

- MUST adhere to the logic specified in [Exclusive Called Functions Behavior](#exclusive-called-functions-behavior) section.
- MUST override the LSP14 Type IDs triggered by using `renounceOwnership(..)` to the ones below:

  - `keccak256('LSP0OwnershipTransferred_SenderNotification')` > `0xa4e59c931d14f7c8a7a35027f92ee40b5f2886b9fdcdb78f30bc5ecce5a2f814`

#### batchCalls

```solidity
function batchCalls(bytes[] calldata functionCalls) external returns (bytes[] memory results)
```

Enables the execution of a batch of encoded function calls on the current contract in a single transaction, provided as an array of bytes.

MUST use the [DELEGATECALL] opcode to execute each call in the same context of the current contract.

_Parameters:_

- `functionCalls`: an array of encoded function calls to be executed on the current contract.

The data field can be:

- an array of ABI-encoded function calls such as an array of ABI-encoded execute, setData, transferOwnership or any LSP0 functions.
- an array of bytes which will resolve to the fallback function to be checked for an extension.

_Requirements:_

- MUST NOT be payable.

_Returns:_ `results` , an array of bytes containing the return values of each executed function call.

#### execute

```solidity
function execute(uint256 operationType, address target, uint256 value, bytes memory data) external payable returns (bytes memory);
```

This function is part of the [ERC725X] specification, with additional requirements as follows:

- MUST adhere to the logic specified in [Exclusive Called Functions Behavior](#exclusive-called-functions-behavior) section.
- MUST adhere to the logic specified in [Value Receive Notification and Reaction](#value-receive-notification-and-reaction) section.

#### executeBatch

```solidity
function executeBatch(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns (bytes[] memory);
```

This function is part of the [ERC725X] specification, with additional requirements as follows:

- MUST adhere to the logic specified in [Exclusive Called Functions Behavior](#exclusive-called-functions-behavior) section.
- MUST adhere to the logic specified in [Value Receive Notification and Reaction](#value-receive-notification-and-reaction) section.

#### getData

```solidity
function getData(bytes32 dataKey) external view returns (bytes memory);
```

This function is part of the [ERC725Y] specification.

#### getDataBatch

```solidity
function getDataBatch(bytes32[] memory dataKeys) external view returns (bytes[] memory);
```

This function is part of the [ERC725Y] specification.

#### setData

```solidity
function setData(bytes32 dataKey, bytes memory dataValue) external payable;
```

This function is part of the [ERC725Y] specification, with additional requirements as follows:

- MUST be payable.
- MUST adhere to the logic specified in [Exclusive Called Functions Behavior](#exclusive-called-functions-behavior) section.
- MUST adhere to the logic specified in [Value Receive Notification and Reaction](#value-receive-notification-and-reaction) section.
- MUST emit only the first 256 bytes of the dataValue parameter in the [DataChanged] event.

#### setDataBatch

```solidity
function setDataBatch(bytes32[] memory dataKeys, bytes[] memory dataValues) external payable;
```

This function is part of the [ERC725Y] specification, with additional requirements as follows:

- MUST be payable.
- MUST adhere to the logic specified in [Exclusive Called Functions Behavior](#exclusive-called-functions-behavior) section.
- MUST adhere to the logic specified in [Value Receive Notification and Reaction](#value-receive-notification-and-reaction) section.
- MUST emit only the first 256 bytes of the dataValue parameter in the [DataChanged] event.

#### isValidSignature

```solidity
function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4);
```

This function is part of the [ERC1271] specification, with additional requirements as follows:

- When the owner is an EOA, the function MUST return the [success value] if the address recovered from the hash and the signature via [ecrecover] is the owner of the contract. Otherwise, MUST return the [failure value].

- When the owner is a contract, it will call the `isValidsignature(bytes32,bytes)` function on the owner contract, and return the success value if the function returns the success value. In any other case such as non-standard return value or revert, it will return the failure value indicating an invalid signature.

#### universalReceiver

```solidity
function universalReceiver(bytes32 typeId, bytes memory receivedData) external payable returns (bytes memory);
```

This function is part of the [LSP1-UniversalReceiver] specification, with additional requirements as follows:

- MUST adhere to the logic specified in [Value Receive Notification and Reaction](#value-receive-notification-and-reaction) section.

- If an `address` is stored under the data key attached below and this address is a contract:
  - forwards the call to the [`universalReceiverDelegate(address,uint256,bytes32,bytes)`] function on the contract at this address **ONLY IF** this contract supports the [LSP1-UniversalReceiverDelegate interface id].
  - if the contract at this address does not support the [LSP1-UniversalReceiverDelegate interface id], execution continues normally.
- If there is no `address` stored under this data key, execution continues normally.

```json
{
  "name": "LSP1UniversalReceiverDelegate",
  "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
  "keyType": "Singleton",
  "valueType": "address",
  "valueContent": "Address"
}
```

- If an `address` is stored under the data key attached below and this address is a contract:

  - forwards the call to the [`universalReceiverDelegate(address,uint256,bytes32,bytes)`] function on the contract at this address **ONLY IF** this contract supports the [LSP1-UniversalReceiverDelegate interface id].
  - if the contract at this address does not support the [LSP1-UniversalReceiverDelegate interface id], execution continues normally.

- If there is no `address` stored under this data key, execution continues normally.

```json
{
  "name": "LSP1UniversalReceiverDelegate:<bytes32>",
  "key": "0x0cfc51aec37c55a4d0b10000<bytes32>",
  "keyType": "Mapping",
  "valueType": "address",
  "valueContent": "Address"
}
```

> <bytes32\> is the `typeId` passed to the `universalReceiver(..)` function. Check [LSP2-ERC725YJSONSchema] to learn how to encode the key.

- MUST return the returned value of the `universalReceiverDelegate(address,uint256,bytes32,bytes)` function on both retrieved contract abi-encoded as bytes. If there is no addresses stored under the data keys above or the call was not forwarded to them, the return value is the two empty bytes abi-encoded as bytes.

- MUST emit a [UniversalReceiver] event if the function was successful with the call context, parameters passed to it and the function's return value.

### ERC725Y Data Keys

#### LSP1UniversalReceiverDelegate

```json
{
  "name": "LSP1UniversalReceiverDelegate",
  "key": "0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47",
  "keyType": "Singleton",
  "valueType": "address",
  "valueContent": "Address"
}
```

If the account delegates its universal receiver functionality to another smart contract, this smart contract address MUST be stored under the data key attached above. This call to this contract is performed when the `universalReceiver(bytes32,bytes)` function of the account is called and can react on the whole call regardless of the typeId.

Check [LSP1-UniversalReceiver] and [LSP2-ERC725YJSONSchema] for more information.

#### Mapped LSP1UniversalReceiverDelegate

```json
{
  "name": "LSP1UniversalReceiverDelegate:<bytes32>",
  "key": "0x0cfc51aec37c55a4d0b10000<bytes32>",
  "keyType": "Mapping",
  "valueType": "address",
  "valueContent": "Address"
}
```

The `<bytes32\>` in the data key name corresponds to the `typeId` passed to the `universalReceiver(..)` function.

> **Warning**
> When constructing this data key for a specific `typeId`, unique elements of the typeId SHOULD NOT be on the right side because of trimming rules.
>
> The `<bytes32>` is trimmed on the right side to keep only the first 20 bytes. Therefore, implementations SHOULD ensure that the first 20 bytes are unique to avoid clashes.
> For example, the `bytes32 typeId` below:
>
> ```
> 0x1111222233334444555566667777888899990000aaaabbbbccccddddeeeeffff
> ```
>
> will be trimmed to `0x1111222233334444555566667777888899990000`.
>
> See the section about the trimming rules for the key type [`Mapping`] in [LSP2-ERC725YJSONSchema] to learn how to encode this data key.

If the account delegates its universal receiver functionality to another smart contract, this smart contract address MUST be stored under the data key attached above. This call to this contract is performed when the `universalReceiver(bytes32,bytes)` function of the account is called with a specific typeId that it can react on.

Check the [**UniversalReceiver Delegation > Specification** section in LSP1-UniversalReceiver](./LSP-1-UniversalReceiver.md#universalreceiver-delegation) and [LSP2-ERC725YJSONSchema] for more information.

#### LSP17Extension

```json
{
  "name": "LSP17Extension:<bytes4>",
  "key": "0xcee78b4094da860110960000<bytes4>",
  "keyType": "Mapping",
  "valueType": "(address, bytes1)",
  "valueContent": "(Address, bool)"
}
```

> <bytes4\> is the `functionSelector` called on the account contract. Check [LSP2-ERC725YJSONSchema] to learn how to encode the data key.

If there is a function called on the account and the function does not exist, the fallback function lookup an address stored under the data key attached above and forwards the call to it with the value of the `msg.sender` and `msg.value` appended as extra calldata.

If the data stored is just 20 bytes, representing an address, or 21 bytes with the boolean set to false (anything other than `0x01`), the extension will be called without sending the value received to the extension.

If the data stored is 21 bytes with the boolean set to true (strictly `0x01`), the extension will be called with sending the value received to the extension. (Does not change that the value MUST be appended to the call)

Check the [**LSP17Extension Specification** section in LSP17-ContractExtension](./LSP-17-ContractExtension.md#lsp17extendable-specification) and [LSP2-ERC725YJSONSchema] for more information.

### Graffiti

Graffiti refers to the arbitrary messages or data sent to an **LSP0-ERC725Account** contract that do not match any existing function selectors, such as `execute(..)`, `setData(..)`, etc. These bytes, often carrying a message or additional information, are usually not intended to invoke specific functions within the contract.

When the account is called with specific bytes that do not match any function selector, it will first check its storage to see if there are any extensions set for these function selectors (bytes). If no extension is found, the call will typically revert. However, to emulate the behavior of calling an Externally Owned Account (EOA) with random bytes (which always passes), an exception has been made for the `0x00000000` selector.

When the account is called with data that starts with `0x00000000`, it will first check for extensions. If none are found, the call will still pass, allowing it to match the behavior of calling an EOA and enabling the ability to send arbitrary messages to the account. For example, one might receive a message like "This is a gift" while sending native tokens.

Additionally, it is possible to set an extension for the `0x00000000` selector. With this custom extension, you can define specific logic that runs when someone sends graffiti to your account. For instance, you may choose to disallow sending graffiti by reverting the transaction, impose a fee for sending graffiti, or emit the graffiti on an external contract. This flexibility allows for various use cases and interactions with graffiti in the LSP0ERC725Account contracts.

## Rationale

### ER725Y Data Storage

The [ERC725Y] standard is crucial for an account contract as it allows for flexible data storage using a key/value pair structure. This data can be used to store a wide variety of information, making it possible for the account to support numerous applications and services. It can also be used to help owner of the account to dictate a certain execution logic, for instance storing permissions of addresses allowed to interact with the account, can be read by an owner contract and allow execution based on it.

It's a future-proofing feature that enables the account to interact with any smart contract or address, adapting to new functionalities as the ecosystem evolves. The versatility of ERC725Y ensures that an account can remain relevant and functional as new use cases and requirements emerge.

### Notification and Reaction

Notification and Reaction are essential features that facilitate user interaction and automation in the context of Web3, analogous to notifications in the Web2 ecosystem.

#### Importance of Notifications

Just as notifications are crucial for the functionality of Web2 accounts, providing real-time updates and alerts on various actions, Web3 accounts must also possess this capability. Notifications serve as the bedrock for creating reactive, user-oriented applications that inform users promptly about events affecting their accounts.

#### Web3 Adoption and User Experience

To encourage broader adoption of Web3 accounts, they must be equipped with a standardized notification system that users are already familiar with in other technological spheres. This standardization helps in bridging the user experience gap between traditional (Web2) and blockchain (Web3) platforms.
Adopting the [LSP1-UniversalReceiver] standard is critical for enabling accounts to be universally and reliably informed of interactions, such as the reception of tokens, follows, royalties, etc .. This allows for the development of more sophisticated and automated response mechanisms within smart contracts.

By allowing the account to react to notifications with customizable logic, developers can program an array of automated responses tailored to the needs of the account holder. This flexibility enhances the potential for automation and facilitates a more intuitive and user-friendly blockchain experience.

### Value Receive Notification and Reaction

The notification and reaction mechanism provided on native token transfer in the LSP0-ERC725Account standard smart contracts is essential for several reasons.

#### Off-Chain Monitoring

It provides a standardized and efficient way for off-chain entities to monitor and record native token deposits in smart contracts by listening to a single event which is the `UniversalReceiver` with a specific typeId being `keccak256("LSP0ValueReceived")` > `0x9c4705229491d365fb5434052e12a386d6771d976bea61070a8c694e8affea3d`. This standardization makes integration simpler and more reliable for external applications tracking native token flows.

#### Reactive Measures for Received Funds

It allows the smart contract to distinguish between transactions initiated by the owner and those from other users. For owner-initiated transactions, the system simply notifies receipt of value. However, for public transactions, the contract can execute pre-defined logic to accept, reject, or process the funds according to the owner's requirements, enhancing security and control over the contract's balance.

This ability to react to incoming transfers is crucial for managing funds under various conditions, including legal compliance or operational rules set by the contract owner.

The provision of this mechanism aims to balance the need for transaction transparency with the necessity for direct control over the smart contract's fund management processes.

### LSP20-CallVerification Usage

The account stands as a versatile and secure solution in the realm of blockchain smart contracts, allowing for a variety of ownership configurations. Users can decide to own the account with an EOA or opt for a multi-signature owner for enhanced security or a permission access control contract like [LSP6-KeyManager].

#### Challenge of Diverse Ownership

This flexibility, however, brings forth a challenge for external entities like websites and protocols looking to interact with the account. The process requires identifying the owner of the account, understanding the ownership structure, and then tailoring the interaction accordingly (encoding the transaction according to the ABI of the owner contract). This could vary significantly depending on whether the owner is a simple address, a multi-signature wallet, or a more complex contract like the LSP6 KeyManager.

#### Consistent Interaction Regardless of Ownership

To streamline this interaction process and provide a uniform approach, the account has integrated the **LSP20-CallVerification** standard. This standard allows any external entity to directly call functions on the account. The account, in turn, internally validates these calls by consulting with its owner, ensuring that the owner’s logic and rules are followed.

This results in a consistent and straightforward interaction model for external entities. They can interact with the account in the same way, regardless of the ownership structure in place.

**Example Scenario with LSP6-KeyManager**

Let's take a practical example to illustrate this. Suppose the account is owned by an [LSP6-KeyManager], which operates based on permissions. An external controller (an address) wishes to update some data on the account using the setData function. Since LSP20 Standard is applied, the controller can directly call setData on the account. The setData function then forwards this call, along with the caller’s information, to the [LSP6-KeyManager] contract which evaluate whether the controller has the necessary permissions to perform this action. If yes, the call is executed; if not, it is denied.

This streamlined process facilitated by the [LSP20-CallVerification] standard ensures a uniform and user-friendly way of interacting with the account, making it more accessible and easier to integrate into various applications and services.

### Account Unbiasedness

The rationale for emphasizing account unbiasedness within a smart contract framework stems from the recognition of diverse user needs and the value of reputational continuity.

#### Diversity of User Preferences

Smart contract users come with different security needs and preferences which can change over time. A user might prefer different control mechanisms like social recovery, access control lists, or multisig setups at different stages. To cater to this variability, the underlying account structure should be feature-agnostic, providing only the core functionalities without pre-set features that presume the needs of all users.

#### Avoiding Feature Presumption

By designing accounts to be unbiased in terms of features, it allows for a neutral starting point where any specialized functionality can be layered on top by the user's choice. This approach acknowledges that no one-size-fits-all solution can effectively serve the varying and evolving requirements of all users.

#### Reputation and Continuity

Users build reputation and trust on their account addresses over time, through transaction history, balance accumulation, and interactions with other contracts. Having to migrate to a new account because of a change in preference can disrupt this continuity. Users face the inconvenience of transferring tokens and data and lose the intangible value of their established reputation, which is not transferable between accounts.

By separating core account functionalities from optional features, the system supports a modular approach to security and control customization. Users can retain their base account while changing the feature sets applied to it, maintaining their reputational capital and avoiding the disruption of account migrations. Thus, the unbiased basic account acts as a persistent, adaptable foundation for controlling the user identity on the blockchain, accommodating different needs.

### Extending Functionalities and InterfaceIds

The rationale for the capability to extend functionalities and support new InterfaceIds post-deployment is anchored in adaptability and future-proofing of smart contract accounts.

#### Ongoing Standardization

The blockchain ecosystem is continuously evolving, with new standards and best practices emerging regularly. Post-deployment adaptability ensures that an account can remain relevant and compliant with new standards as they arise. Extension mechanisms allow accounts to adopt new functionalities without needing to be redeployed. This approach supports the seamless adoption of innovations and standards, making the contract resilient to obsolescence.

#### Functionality Accessibility

By allowing the invocation of functions that are not natively present in the contract but provided through extensions, the account can maintain compatibility with new standards and interfaces. This prevents the contract from failing when interacting with newly defined functions that it did not originally include, thereby maintaining the contract's utility and interactions within the evolving ecosystem.

#### Disclosure of Supported InterfaceIds

Extending the ERC165 interfaceIds that the account supports is critical for transparency and interoperability. It allows other contracts and services to detect supported interfaces and interact with the account accordingly, facilitating broader compatibility across the ecosystem.

With the capacity to evolve, accounts can have a longer operational life, reducing the need for users to migrate to newer accounts with updated features. This stability is crucial for maintaining the trust and reputation associated with a blockchain account over time.

## Usage

The versatile nature of the unbiased account, with its capability to integrate various functions and ownership protocols, enables it to serve a wide range of purposes. From acting as a comprehensive Blockchain Profile for individuals in the Web3 space to functioning as an autonomous decentralized organization (DAO), the adaptability of the account caters to multiple use cases.

### Blockchain Profile

For individual users navigating the complexities of Web3, the account can be customized to serve as a Blockchain Profile—a singular digital identity encapsulating user reputation, assets, and transaction history. It simplifies interactions within the ecosystem by abstracting the underlying technical processes and providing a user-friendly interface for managing digital assets and identities, enhancing the user experience in decentralized applications (DApps), finance, and beyond.

### Organization

An unbiased account can be structured to embody an Organization, enabling entities to govern operations, manage funds, and maintain compliance with legal frameworks that prohibit unsolicited transfers. The account’s data keys can be standardized for organizational use, providing a clear and efficient way to manage access to contracts, execute transactions, and ensure that operations are fully auditable and transparent.

## Reference Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts] repository.

## Security Considerations

### Delegatecall

The use of `delegatecall` in smart contracts is a sensitive operation with significant security implications. As it allows one contract to execute code in the context of another, it can potentially lead to the compromise or complete destruction of the contract's state if not handled correctly. Therefore, for accounts where `delegatecall` functionality is deemed unnecessary or where its risks outweigh its benefits, it is advisable to eliminate paths that permit its use in the owner contract, thus closing off a vector for attacks and vulnerabilities while being able to use it later with an owner upgrade.

### Signature Replay

In the case of protocols interacting with the account, it is paramount to incorporate security measures that specifically address signature-based threats. To guard against replay attacks, where a signature is used maliciously on different contracts, the protocol must ensure that the account address is part of the signed data. This inclusion uniquely binds a signature to an account and context, preventing the misuse of signed messages and enhancing the overall security of the transaction verification process.

## Interface Cheat Sheet

```solidity
interface ILSP0  /* is ERC165 */ {


    // ERC725X

    event Executed(uint256 indexed operation, address indexed to, uint256 indexed value, bytes4 selector);

    event ContractCreated(uint256 indexed operation, address indexed contractAddress, uint256 indexed value, bytes32 salt);


    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external payable returns (bytes memory);

    function executeBatch(uint256[] memory operationsType, address[] memory targets, uint256[] memory values, bytes[] memory datas) external payable returns(bytes[] memory);


    // ERC725Y

    event DataChanged(bytes32 indexed dataKey, bytes dataValue);


    function getData(bytes32 dataKey) external view returns (bytes memory dataValue);

    function setData(bytes32 dataKey, bytes memory dataValue) external payable;

    function getDataBatch(bytes32[] memory dataKeys) external view returns (bytes[] memory dataValues);

    function setDataBatch(bytes32[] memory dataKeys, bytes[] memory dataValues) external payable;


    // ERC1271

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 returnedStatus);


    // LSP0 (ERC725Account)

    receive() external payable;

    fallback() external payable;

    function batchCalls(bytes[] calldata data) external returns (bytes[] memory results);


    // LSP1

    event UniversalReceiver(address indexed from, uint256 indexed value, bytes32 indexed typeId, bytes receivedData, bytes returnedValue);


    function universalReceiver(bytes32 typeId, bytes memory data) external payable returns (bytes memory);


    // LSP14

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event RenounceOwnershipInitiated();

    event OwnershipRenounced();


    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function transferOwnership(address newOwner) external;

    function acceptOwnership() external;

    function renounceOwnership() external;

}


```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[ERC165]: https://eips.ethereum.org/EIPS/eip-165
[ERC1271]: https://eips.ethereum.org/EIPS/eip-1271
[ERC725]: https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md
[ERC725X]: https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#erc725x
[ERC725Y]: https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#erc725y
[LSP1-UniversalReceiver]: ./LSP-1-UniversalReceiver.md
[LSP2-ERC725YJSONSchema]: ./LSP-2-ERC725YJSONSchema.md
[LSP3-Profile-Metadata]: ./LSP-3-Profile-Metadata.md
[LSP5-ReceivedAssets]: ./LSP-5-ReceivedAssets.md
[LSP10-ReceivedVaults]: ./LSP-10-ReceivedVaults.md
[LSP6-KeyManager]: ./LSP-6-KeyManager.md
[LSP14-Ownable2Step]: ./LSP-14-Ownable2Step.md
[lukso-network/lsp-smart-contracts]: https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP0ERC725Account/LSP0ERC725AccountCore.sol
[LSP17-ContractExtension]: ./LSP-17-ContractExtension.md
[LSP20-CallVerification]: ./LSP-20-CallVerification.md
[`lsp20VerifyCall(..)`]: ./LSP-20-CallVerification.md#lsp20verifycall
[`lsp20VerifyCallResult(..)`]: ./LSP-20-CallVerification.md#lsp20verifycallresult
[UniversalReceiver]: ./LSP-1-UniversalReceiver.md#events
[`universalReceiver(bytes32,bytes)`]: ./LSP-1-UniversalReceiver.md#universalreceiver
[`universalReceiverDelegate(address,uint256,bytes32,bytes)`]: ./LSP-1-UniversalReceiver.md#universalreceiverdelegate
[LSP1-UniversalReceiver interface id]: ./LSP-1-UniversalReceiver.md#specification
[LSP1-UniversalReceiverDelegate interface id]: ./LSP-1-UniversalReceiver.md#specification
[`ValueReceived`]: #valuereceived
[DataChanged]: https://github.com/ERC725Alliance/ERC725/blob/develop/docs/ERC-725.md#datachanged
[DELEGATECALL]: https://solidity-by-example.org/delegatecall/
[success value]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md#specification
[ecrecover]: https://docs.soliditylang.org/en/v0.8.17/solidity-by-example.html?highlight=ecrecover#recovering-the-message-signer-in-solidity
[failure value]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md#specification
[`Mapping`]: ./LSP-2-ERC725YJSONSchema.md#mapping
