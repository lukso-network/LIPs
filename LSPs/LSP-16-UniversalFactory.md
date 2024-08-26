---
lip: 16
title: Universal Factory
author: Yamen Merhi <@YamenMerhi>
discussions-to: https://discord.gg/E2rJPP4
status: Review
type: LSP
created: 2022-11-19
requires: EIP104, EIP155, EIP1167
---

**The official LSP16 Universal Factory address on LUKSO is: [0x1600016e23e25D20CA8759338BfB8A8d11563C4e](https://explorer.lukso.network/address/0x1600016e23e25D20CA8759338BfB8A8d11563C4e).**

To deploy this follower system on other chains please see the [deployment section](#deployment).

## Simple Summary

This standard defines a universal factory smart contract, that will allow to deploy different types of smart contracts using [CREATE2] opcode after being deployed with [Nick Factory] in order to produce the same address on different chains.

## Abstract

LSP16 introduces a universal factory for deploying smart contracts using the CREATE2 opcode, ensuring consistent contract addresses across multiple blockchains. This standard allows for the deployment of various contract types, including initializable contracts, with initialization data included in the deployment process to prevent address squatting. By leveraging the Nick Factory for deployment, LSP16 enables a decentralized way to replicate contract addresses on any chain, facilitating multi-chain identity and asset management. This approach offers significant advantages, such as ensuring that assets sent across chains reach their intended contract by maintaining consistent contract addresses. LSP16 is a cornerstone for building interoperable and scalable blockchain applications, offering developers a reliable tool for multi-chain deployment and management.

This standard defines several functions to be used to deploy different types of contracts using [CREATE2] such as normal and initializable contracts. These functions take into consideration the need to initialize in the same transaction for initializable contracts. The initialize data is included in the salt to avoid squatting addresses on different chains.

The same bytecode and salt will produce the same contract address on different chains, if and only if, the UniversalFactory contract was deployed on the same address on each chain, using [Nick Factory] in our case.

## Motivation

Possessing a private key allows for the control of the corresponding address across multiple chains. Consequently, it enables users to verify an address on a particular chain and send assets on other chains, under the presumption that the same entity controls the associated addresses.

Through the use of smart contracts, having a contract at a certain address on one chain does not inherently mean that an identical contract exists at the same address, under the same entity's control, on another chain. If a user sends assets, presuming they control the same address across different chains, those assets may become inaccessible. Thus, the capability to duplicate the same contract address on other chains is beneficial, guaranteeing access to the other smart contract in case there was a mistake sending assets to another chain.

Similarly, deploying a contract across various chains with an identical address can establish a kind of multi-chain identity. This approach can prove advantageous, particularly with factory, registry, and account-based contracts.

## Specification

### Methods

#### deployCreate2

```solidity
function deployCreate2(bytes calldata creationBytecode, bytes32 providedSalt) public payable returns (address);
```

Deploys a contract using the CREATE2 opcode without initialization (external call after deployment).

The address where the contract will be deployed can be known in advance via the [computeAddress](#computeaddress) function.

The `providedSalt` parameter is not used directly as the salt by the CREATE2 opcode. Instead, it is hashed via keccak256 with prepending a false boolean. See [generateSalt](#generatesalt) function for more details.

> `keccak256(abi.encodePacked(false, providedSalt))`

MUST emit the [ContractCreated] event after deploying the contract.

**Parameters:**

- `creationBytecode`: The creation bytecode of the contract to deploy
- `providedSalt`: The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment

**Return:**

- `contractCreated`: The address of the contract created.

**Requirements:**

- If value is associated with the contract creation, the constructor of the contract to deploy MUST be payable, otherwise the call will revert.

- MUST NOT use the same `bytecode` and `providedSalt` twice, otherwise the call will revert.

#### deployCreate2AndInitialize

```solidity
function deployCreate2AndInitialize(bytes calldata creationBytecode, bytes32 providedSalt, bytes calldata initializeCalldata, uint256 constructorMsgValue, uint256 initializeCalldataMsgValue) public payable returns (address);
```

Deploys a contract using the CREATE2 opcode with initialization (external call after deployment).

The address where the contract will be deployed can be known in advance via the [computeAddress](#computeaddress) function.

The `providedSalt` parameter is not used directly as the salt by the CREATE2 opcode. Instead, it is hashed via keccak256 with prepending a true boolean and the initializeCalldata parameter. See [generateSalt](#generatesalt) function for more details.

> `keccak256(abi.encodePacked(true, initializeCalldata, providedSalt))`

MUST emit the [ContractCreated] event after deploying the contract.

**Parameters:**

- `creationBytecode`: The creation bytecode of the contract to deploy
- `providedSalt`: The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
- `initializeCalldata`: The calldata to be executed on the created contract
- `constructorMsgValue`: The value sent to the contract during deploymentcontract
- `initializeCalldataMsgValue`: The value sent to the contract during initialization

**Return:**

- `contractCreated`: The address of the contract created.

**Requirements:**

- If some value is transferred during the contract creation, the constructor of the contract to deploy MUST be payable, otherwise the call will revert.

- If some value is transferred during the initialization call, the initialize function called on the contract to deploy MUST be payable, otherwise the call will revert.

- The sum of `constructorMsgValue` and `initializeCalldataMsgValue` MUST be equal to the value associated with the function call.

- MUST NOT use the same `bytecode`, `providedSalt` and `initializeCalldata` twice, otherwise the call will revert.

#### deployERC1167Proxy

```solidity
function deployERC1167Proxy(address implementationContract, bytes32 providedSalt) public returns (address);
```

Deploys an ERC1167 minimal proxy contract using the CREATE2 opcode.

The address where the contract will be deployed can be known in advance via the [computeERC1167Address](#computeerc1167address) function.

The `providedSalt` parameter is not used directly as the salt by the CREATE2 opcode. Instead, it is hashed via keccak256 with prepending a false boolean. See [generateSalt](#generatesalt) function for more details.

> `keccak256(abi.encodePacked(false, providedSalt))`

MUST emit the [ContractCreated] event after deploying the contract.

**Parameters:**

- `implementationContract`: The contract to create a clone of according to ERC1167
- `providedSalt`: The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment

**Return:**

- `proxy`: The address of the contract created

**Requirements:**

- MUST NOT use the same `implementationContract` and `providedSalt` twice, otherwise the call will revert.

#### deployERC1167ProxyAndInitialize

```solidity
function deployERC1167Proxy(address implementationContract, bytes32 providedSalt, bytes calldata initializeCalldata) public returns (address);
```

Deploys an ERC1167 minimal proxy contract using the CREATE2 opcode with initialization (external call after deployment).

The address where the contract will be deployed can be known in advance via the [computeERC1167Address](#computeerc1167address) function.

The `providedSalt` parameter is not used directly as the salt by the CREATE2 opcode. Instead, it is hashed via keccak256 with prepending a true boolean and the initializeCalldata parameter. See [generateSalt](#generatesalt) function for more details.

> `keccak256(abi.encodePacked(true, initializeCalldata, providedSalt))`

MUST emit the [ContractCreated] event after deploying the contract.

**Parameters:**

- `implementationContract`: The contract to create a clone of according to ERC1167
- `providedSalt`: The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
- `initializeCalldata`: The calldata to be executed on the created contract

**Return:**

- `proxy`: The address of the contract created

**Requirements:**

- MUST NOT use the same `implementationContract` and `providedSalt` twice, otherwise the call will revert.

- If value is associated with the initialization call, the initialize function called on the contract to deploy MUST be payable, otherwise the call will revert.

- MUST NOT use the same `bytecode`, `providedSalt` and `initializeCalldata` twice, otherwise the call will revert.

#### computeAddress

```solidity
function computeAddress(bytes32 creationBytecodeHash, bytes32 providedSalt, bool initializable, bytes calldata initializeCalldata) public view virtual returns (address)
```

Computes the address of a contract to be deployed using CREATE2, based on the input parameters. Any change in one of these parameters will result in a different address.

When the `initializable` boolean is set to `false`, `initializeCalldata` will not affect the function output.

**Parameters:**

- `creationBytecodeHash`: The keccak256 hash of the creation bytecode to be deployed
- `providedSalt`: The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
- `initializable`: A boolean that indicates whether an external call should be made to initialize the contract after deployment
- `initializeCalldata`: The calldata to be executed on the created contract if `initializable` is set to `true`

**Return:**

- `contractToCreate`: The address where the contract will be deployed.

### computeERC1167Address

```solidity
function computeERC1167Address(address implementationContract, bytes32 providedSalt, bool initializable, bytes calldata initializeCalldata) public view virtual returns (address)
```

Computes the address of a contract to be deployed using CREATE2, based on the input parameters. Any change in one of these parameters will result in a different address.

When the `initializable` boolean is set to `false`, `initializeCalldata` will not affect the function output.

**Parameters:**

- `implementationContract`: The contract to create a clone of according to ERC1167
- `providedSalt`: The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
- `initializable`: A boolean that indicates whether an external call should be made to initialize the contract after deployment
- `initializeCalldata`: The calldata to be executed on the created contract if `initializable` is set to `true`

**Return:**

- proxyToCreate: The address where the contract will be deployed.

### generateSalt

```solidity
function generateSalt(bytes32 providedSalt, bool initializable, bytes memory initializeCalldata) public view virtual returns (bytes32)
```

Generates the salt used to deploy the contract by hashing the following parameters (concatenated together) with keccak256:

- the `providedSalt`
- the `initializable` boolean
- the `initializeCalldata`, only if the contract is initializable (the `initializable` boolean is set to `true`)

This approach ensures that in order to reproduce an initializable contract at the same address on another chain, not only the `providedSalt` is required to be the same, but also the initialize parameters within the `initializeCalldata` must also be the same.

This maintains consistent deployment behaviour. Users are required to initialize contracts with the same parameters across different chains to ensure contracts are deployed at the same address across different chains.

**Parameters:**

- `providedSalt`: The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
- `initializable`: A boolean that indicates whether an external call should be made to initialize the contract after deployment
- `initializeCalldata`: The calldata to be executed on the created contract if `initializable` is set to `true`

**Return:**

- `generatedSalt`: The generated salt which will be used for CREATE2 deployment

### Events

#### ContractCreated

```solidity
event ContractCreated(address indexed contractCreated, bytes32 indexed providedSalt, bytes32 generatedSalt, bool indexed initializable, bytes initializeCalldata);
```

MUST be emitted when a contract is created using the UniversalFactory contract.

**Parameters:**

- `contractCreated`: The address of the contract created
- `providedSalt`: The salt provided by the deployer which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
- `generatedSalt`: The salt used by the `CREATE2` opcode for contract deployment
- `initialized`: The Boolean that specifies if the contract must be initialized or not
- `initializeCalldata`: The bytes provided as initializeCalldata (Empty string when `initialized` is set to false)

## Rationale

The Nick Factory is utilized to deploy the UniversalFactory, taking into consideration that we want to avoid the dependency on a single entity for regular contract deployment. By leveraging the Nick Factory, any user can deploy it, given the same parameters.

Moreover, the [Nick Factory] is chosen due to its widespread deployment and compatibility, even on chains that don't support pre-[EIP-155] transactions (the method by which Nick Factory was deployed). This compatibility aligns with the standard's objective, enabling the replication of contract addresses on a broad array of chains.

[Minimal proxy] contracts can be deployed with the deployCreate2 and deployCreate2AndInitialize functions. However, new functions have been introduced to reduce potential errors during user interaction and to optimize gas costs. The clone library undertakes the responsibility of deploying and generating the minimal proxy bytecode by accepting the base contract's address.

The salt provided during function calls isn't used directly as the salt for the CREATE2 opcode. This is because this contract is designed to tie the creation of contracts to their initial deployment/initialization parameters. This methodology prevents address squatting and ensures that a contract A, owned by EOA A on chain 1, cannot be replicated at the same address where contract A is owned by EOA B on chain 2. Including the initialization data in the salt ensures that contracts maintain consistent deployment behavior and parameters across various chains.

Furthermore, if a contract is not initializable, the provided salt is hashed to prevent it from being used as it is, as a generated salt from a salt and initialization data from another chain. This avoids the scenario where generated salts are used to reproduce the same address of proxies without the initialization/external call effect.

## Implementation

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/packages/lsp16-contracts/contracts/LSP16UniversalFactory.sol) repository.

## Security Consideration

Knowing that deploying a contract using the UniversalFactory will allow to deploy the same contract on other chains with the same address, people should be aware and watch out to use contracts that don't have a logic that protects against replay-attacks.

The constructor parameters or/and initialization data SHOULD NOT include any network-specific parameters (e.g: chain-id, a local token contract address), otherwise the deployed contract will not be recreated at the same address across different networks, thus defeating the purpose of the UniversalFactory.

## Deployment

The `LSP16UniversalFactory` is deplpoyed at [`0x1600016e23e25D20CA8759338BfB8A8d11563C4e`](https://explorer.lukso.network/address/0x1600016e23e25D20CA8759338BfB8A8d11563C4e) on LUKSO using the [Nick Factory contract](https://github.com/Arachnid/deterministic-deployment-proxy/tree/master). The following explains how to deploy `LSP16UniversalFactory` at the same address on other EVM networks.

### LSP16UniversalFactory Deployment

After the [deployment of Nick Factory on the network](https://github.com/Arachnid/deterministic-deployment-proxy/tree/master) ([`0x4e59b44847b379578588920cA78FbF26c0B4956C`](https://explorer.lukso.network/address/0x4e59b44847b379578588920cA78FbF26c0B4956C)), the `LSP16UniversalFactory` can be deployed at `0x1600016e23e25D20CA8759338BfB8A8d11563C4e` using the salt: `0xfaee762dee0012026f5380724e9744bdc5dd26ecd8f584fe9d72a4170d01c049` with the following transaction data from any EOA to Nicks Factory address `0x4e59b44847b379578588920cA78FbF26c0B4956C` with 900,000 GAS:

```js
0xfaee762dee0012026f5380724e9744bdc5dd26ecd8f584fe9d72a4170d01c049608060405234801561001057600080fd5b50610eb5806100206000396000f3fe6080604052600436106100705760003560e01c806349d8abed1161004e57806349d8abed146101005780635340165f14610120578063cdbd473a14610133578063e888edcb1461014657600080fd5b80631a17ccbf1461007557806326736355146100a85780633b315680146100e0575b600080fd5b34801561008157600080fd5b50610095610090366004610a0f565b610166565b6040519081526020015b60405180910390f35b6100bb6100b6366004610b41565b6101c1565b60405173ffffffffffffffffffffffffffffffffffffffff909116815260200161009f565b3480156100ec57600080fd5b506100bb6100fb366004610b8d565b610293565b34801561010c57600080fd5b506100bb61011b366004610c19565b6102ee565b6100bb61012e366004610c43565b61038a565b6100bb610141366004610c9d565b6104bf565b34801561015257600080fd5b506100bb610161366004610d26565b610671565b600082156101a1576001828560405160200161018493929190610d80565b6040516020818303038152906040528051906020012090506101ba565b6040516000602082015260218101859052604101610184565b9392505050565b6000806101df83600060405180602001604052806000815250610166565b90506000610224348388888080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152506106c192505050565b905060001515848273ffffffffffffffffffffffffffffffffffffffff167f8872a323d65599f01bf90dc61c94b4e0cc8e2347d6af4122fccc3e112ee34a848560405180602001604052806000815250604051610282929190610db2565b60405180910390a495945050505050565b6000806102d7868686868080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525061016692505050565b90506102e38188610825565b979650505050505050565b60008061030c83600060405180602001604052806000815250610166565b9050600061031a8583610832565b905060001515848273ffffffffffffffffffffffffffffffffffffffff167f8872a323d65599f01bf90dc61c94b4e0cc8e2347d6af4122fccc3e112ee34a848560405180602001604052806000815250604051610378929190610db2565b60405180910390a49150505b92915050565b6000806103cf85600186868080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525061016692505050565b905060006103dd8783610832565b905060011515868273ffffffffffffffffffffffffffffffffffffffff167f8872a323d65599f01bf90dc61c94b4e0cc8e2347d6af4122fccc3e112ee34a8485898960405161042e93929190610e0a565b60405180910390a46000808273ffffffffffffffffffffffffffffffffffffffff16348888604051610461929190610e5e565b60006040518083038185875af1925050503d806000811461049e576040519150601f19603f3d011682016040523d82523d6000602084013e6104a3565b606091505b50915091506104b282826108f6565b5090979650505050505050565b6000346104cc8385610e6e565b14610503576040517f2fd9ca9100000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b600061054787600188888080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525061016692505050565b9050600061058c85838c8c8080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152506106c192505050565b905060011515888273ffffffffffffffffffffffffffffffffffffffff167f8872a323d65599f01bf90dc61c94b4e0cc8e2347d6af4122fccc3e112ee34a84858b8b6040516105dd93929190610e0a565b60405180910390a46000808273ffffffffffffffffffffffffffffffffffffffff16868a8a604051610610929190610e5e565b60006040518083038185875af1925050503d806000811461064d576040519150601f19603f3d011682016040523d82523d6000602084013e610652565b606091505b509150915061066182826108f6565b50909a9950505050505050505050565b6000806106b5868686868080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525061016692505050565b90506102e38782610941565b600083471015610732576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601d60248201527f437265617465323a20696e73756666696369656e742062616c616e636500000060448201526064015b60405180910390fd5b815160000361079d576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820181905260248201527f437265617465323a2062797465636f6465206c656e677468206973207a65726f6044820152606401610729565b8282516020840186f5905073ffffffffffffffffffffffffffffffffffffffff81166101ba576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601960248201527f437265617465323a204661696c6564206f6e206465706c6f79000000000000006044820152606401610729565b60006101ba8383306109a1565b6000763d602d80600a3d3981f3363d3d373d3d3d363d730000008360601b60e81c176000526e5af43d82803e903d91602b57fd5bf38360781b1760205281603760096000f5905073ffffffffffffffffffffffffffffffffffffffff8116610384576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f455243313136373a2063726561746532206661696c65640000000000000000006044820152606401610729565b8161093d5780511561090b5780518082602001fd5b6040517fc1ee854300000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5050565b6040513060388201526f5af43d82803e903d91602b57fd5bf3ff602482015260148101839052733d602d80600a3d3981f3363d3d373d3d3d363d738152605881018290526037600c820120607882015260556043909101206000906101ba565b6000604051836040820152846020820152828152600b8101905060ff815360559020949350505050565b803580151581146109db57600080fd5b919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b600080600060608486031215610a2457600080fd5b83359250610a34602085016109cb565b9150604084013567ffffffffffffffff80821115610a5157600080fd5b818601915086601f830112610a6557600080fd5b813581811115610a7757610a776109e0565b604051601f82017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0908116603f01168101908382118183101715610abd57610abd6109e0565b81604052828152896020848701011115610ad657600080fd5b8260208601602083013760006020848301015280955050505050509250925092565b60008083601f840112610b0a57600080fd5b50813567ffffffffffffffff811115610b2257600080fd5b602083019150836020828501011115610b3a57600080fd5b9250929050565b600080600060408486031215610b5657600080fd5b833567ffffffffffffffff811115610b6d57600080fd5b610b7986828701610af8565b909790965060209590950135949350505050565b600080600080600060808688031215610ba557600080fd5b8535945060208601359350610bbc604087016109cb565b9250606086013567ffffffffffffffff811115610bd857600080fd5b610be488828901610af8565b969995985093965092949392505050565b803573ffffffffffffffffffffffffffffffffffffffff811681146109db57600080fd5b60008060408385031215610c2c57600080fd5b610c3583610bf5565b946020939093013593505050565b60008060008060608587031215610c5957600080fd5b610c6285610bf5565b935060208501359250604085013567ffffffffffffffff811115610c8557600080fd5b610c9187828801610af8565b95989497509550505050565b600080600080600080600060a0888a031215610cb857600080fd5b873567ffffffffffffffff80821115610cd057600080fd5b610cdc8b838c01610af8565b909950975060208a0135965060408a0135915080821115610cfc57600080fd5b50610d098a828b01610af8565b989b979a5095989597966060870135966080013595509350505050565b600080600080600060808688031215610d3e57600080fd5b610d4786610bf5565b945060208601359350610bbc604087016109cb565b60005b83811015610d77578181015183820152602001610d5f565b50506000910152565b83151560f81b815260008351610d9d816001850160208801610d5c565b60019201918201929092526021019392505050565b8281526040602082015260008251806040840152610dd7816060850160208701610d5c565b601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe016919091016060019392505050565b83815260406020820152816040820152818360608301376000818301606090810191909152601f9092017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe016010192915050565b8183823760009101908152919050565b80820180821115610384577f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fdfea164736f6c6343000811000a;
```

This should deploy the `LSP16UniversalFactory` at the following address: `0x1600016e23e25D20CA8759338BfB8A8d11563C4e`.

The deployed [implementation code can be found here](https://github.com/lukso-network/lsp-smart-contracts/tree/9e1519f94293b96efa2ebc8f459fde65cc43fecd/contracts/LSP16UniversalFactory).

- The source code is generated with `0.8.17` compiler version and with `9999999` optimization runs, and the metadata hash set to none.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[EIP-155]: ./eip-155.md
[CREATE2]: https://eips.ethereum.org/EIPS/eip-1014
[minimal proxy]: https://eips.ethereum.org/EIPS/eip-1167
[ContractCreated]: ./LSP-16-UniversalFactory.md#contractcreated
[LSP16 UniversalFactory smart contract]: https://github.com/lukso-network/lsp-smart-contracts/blob/develop/packages/lsp16-contracts/contracts/LSP16UniversalFactory.sol
[Nick Factory]: https://github.com/Arachnid/deterministic-deployment-proxy
