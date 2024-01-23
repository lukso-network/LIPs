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

## Simple Summary

This standard defines a universal factory smart contract, that will allow to deploy different types of smart contracts using [CREATE2] opcode after being deployed with [Nick Factory] in order to produce the same address on different chains.

## Abstract

This standard defines several functions to be used to deploy different types of contracts using [CREATE2] such as normal and initializable contracts. These functions take into consideration the need to initialize in the same transaction for initializable contracts. The initialize data is included in the salt to avoid squatting addresses on different chains.

The same bytecode and salt will produce the same contract address on different chains, if and only if, the UniversalFactory contract was deployed on the same address on each chain, using [Nick Factory] in our case.

## Motivation

Possessing a private key allows for the control of the corresponding address across multiple chains. Consequently, it enables users to verify an address on a particular chain and send assets on other chains, under the presumption that the same entity controls the associated addresses.

Through the use of smart contracts, having a contract at a certain address on one chain does not inherently mean that an identical contract exists at the same address, under the same entity's control, on another chain. If a user sends assets, presuming they control the same address across different chains, those assets may become inaccessible. Thus, the capability to duplicate the same contract address on other chains is beneficial, guaranteeing access to the other smart contract in case there was a mistake sending assets to another chain.

Similarly, deploying a contract across various chains with an identical address can establish a kind of multi-chain identity. This approach can prove advantageous, particularly with factory, registry, and account-based contracts.

## Specification

### UniversalFactory Setup

Before the deployment of the UniversalFactory on any network, people should make sure that the [Nick Factory] is deployed on the same network.

#### Nick Factory Deployment

The Nick Factory should be located at this address `0x4e59b44847b379578588920ca78fbf26c0b4956c` on the network. If there is no code on this address, it means that the contract is not deployed yet.

To deploy, the following raw transaction should be broadcasted to the network `0xf8a58085174876e800830186a08080b853604580600e600039806000f350fe7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf31ba02222222222222222222222222222222222222222222222222222222222222222a02222222222222222222222222222222222222222222222222222222222222222` after funding the deployer address: `0x3fab184622dc19b6109349b94811493bf2a45362` with `gasPrice (100 gwei) * gasLimit (100000)`.

Check [Nick's Factory repository](https://github.com/Arachnid/deterministic-deployment-proxy/tree/master) for more information.

#### UniversalFactory Deployment

After the deployment of Nick Factory on the network, the UniversalFactory can be reproduced at the standardized address given sending the same salt and bytecode.

In order to create the UniversalFactory contract, one should send a transaction to the [Nick Factory] address with data field equal to [salt](#standardized-salt) + [bytecode](#standardized-bytecode).

The address produced should be equal to `0x1600016e23e25D20CA8759338BfB8A8d11563C4e`.

### UniversalFactory Configuration

#### Standardized Address

`0x1600016e23e25D20CA8759338BfB8A8d11563C4e`

#### Standardized Salt

`0xfaee762dee0012026f5380724e9744bdc5dd26ecd8f584fe9d72a4170d01c049`

#### Standardized Bytecode

`0x608060405234801561001057600080fd5b50610eb5806100206000396000f3fe6080604052600436106100705760003560e01c806349d8abed1161004e57806349d8abed146101005780635340165f14610120578063cdbd473a14610133578063e888edcb1461014657600080fd5b80631a17ccbf1461007557806326736355146100a85780633b315680146100e0575b600080fd5b34801561008157600080fd5b50610095610090366004610a0f565b610166565b6040519081526020015b60405180910390f35b6100bb6100b6366004610b41565b6101c1565b60405173ffffffffffffffffffffffffffffffffffffffff909116815260200161009f565b3480156100ec57600080fd5b506100bb6100fb366004610b8d565b610293565b34801561010c57600080fd5b506100bb61011b366004610c19565b6102ee565b6100bb61012e366004610c43565b61038a565b6100bb610141366004610c9d565b6104bf565b34801561015257600080fd5b506100bb610161366004610d26565b610671565b600082156101a1576001828560405160200161018493929190610d80565b6040516020818303038152906040528051906020012090506101ba565b6040516000602082015260218101859052604101610184565b9392505050565b6000806101df83600060405180602001604052806000815250610166565b90506000610224348388888080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152506106c192505050565b905060001515848273ffffffffffffffffffffffffffffffffffffffff167f8872a323d65599f01bf90dc61c94b4e0cc8e2347d6af4122fccc3e112ee34a848560405180602001604052806000815250604051610282929190610db2565b60405180910390a495945050505050565b6000806102d7868686868080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525061016692505050565b90506102e38188610825565b979650505050505050565b60008061030c83600060405180602001604052806000815250610166565b9050600061031a8583610832565b905060001515848273ffffffffffffffffffffffffffffffffffffffff167f8872a323d65599f01bf90dc61c94b4e0cc8e2347d6af4122fccc3e112ee34a848560405180602001604052806000815250604051610378929190610db2565b60405180910390a49150505b92915050565b6000806103cf85600186868080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525061016692505050565b905060006103dd8783610832565b905060011515868273ffffffffffffffffffffffffffffffffffffffff167f8872a323d65599f01bf90dc61c94b4e0cc8e2347d6af4122fccc3e112ee34a8485898960405161042e93929190610e0a565b60405180910390a46000808273ffffffffffffffffffffffffffffffffffffffff16348888604051610461929190610e5e565b60006040518083038185875af1925050503d806000811461049e576040519150601f19603f3d011682016040523d82523d6000602084013e6104a3565b606091505b50915091506104b282826108f6565b5090979650505050505050565b6000346104cc8385610e6e565b14610503576040517f2fd9ca9100000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b600061054787600188888080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525061016692505050565b9050600061058c85838c8c8080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152506106c192505050565b905060011515888273ffffffffffffffffffffffffffffffffffffffff167f8872a323d65599f01bf90dc61c94b4e0cc8e2347d6af4122fccc3e112ee34a84858b8b6040516105dd93929190610e0a565b60405180910390a46000808273ffffffffffffffffffffffffffffffffffffffff16868a8a604051610610929190610e5e565b60006040518083038185875af1925050503d806000811461064d576040519150601f19603f3d011682016040523d82523d6000602084013e610652565b606091505b509150915061066182826108f6565b50909a9950505050505050505050565b6000806106b5868686868080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525061016692505050565b90506102e38782610941565b600083471015610732576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601d60248201527f437265617465323a20696e73756666696369656e742062616c616e636500000060448201526064015b60405180910390fd5b815160000361079d576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820181905260248201527f437265617465323a2062797465636f6465206c656e677468206973207a65726f6044820152606401610729565b8282516020840186f5905073ffffffffffffffffffffffffffffffffffffffff81166101ba576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601960248201527f437265617465323a204661696c6564206f6e206465706c6f79000000000000006044820152606401610729565b60006101ba8383306109a1565b6000763d602d80600a3d3981f3363d3d373d3d3d363d730000008360601b60e81c176000526e5af43d82803e903d91602b57fd5bf38360781b1760205281603760096000f5905073ffffffffffffffffffffffffffffffffffffffff8116610384576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f455243313136373a2063726561746532206661696c65640000000000000000006044820152606401610729565b8161093d5780511561090b5780518082602001fd5b6040517fc1ee854300000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5050565b6040513060388201526f5af43d82803e903d91602b57fd5bf3ff602482015260148101839052733d602d80600a3d3981f3363d3d373d3d3d363d738152605881018290526037600c820120607882015260556043909101206000906101ba565b6000604051836040820152846020820152828152600b8101905060ff815360559020949350505050565b803580151581146109db57600080fd5b919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b600080600060608486031215610a2457600080fd5b83359250610a34602085016109cb565b9150604084013567ffffffffffffffff80821115610a5157600080fd5b818601915086601f830112610a6557600080fd5b813581811115610a7757610a776109e0565b604051601f82017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0908116603f01168101908382118183101715610abd57610abd6109e0565b81604052828152896020848701011115610ad657600080fd5b8260208601602083013760006020848301015280955050505050509250925092565b60008083601f840112610b0a57600080fd5b50813567ffffffffffffffff811115610b2257600080fd5b602083019150836020828501011115610b3a57600080fd5b9250929050565b600080600060408486031215610b5657600080fd5b833567ffffffffffffffff811115610b6d57600080fd5b610b7986828701610af8565b909790965060209590950135949350505050565b600080600080600060808688031215610ba557600080fd5b8535945060208601359350610bbc604087016109cb565b9250606086013567ffffffffffffffff811115610bd857600080fd5b610be488828901610af8565b969995985093965092949392505050565b803573ffffffffffffffffffffffffffffffffffffffff811681146109db57600080fd5b60008060408385031215610c2c57600080fd5b610c3583610bf5565b946020939093013593505050565b60008060008060608587031215610c5957600080fd5b610c6285610bf5565b935060208501359250604085013567ffffffffffffffff811115610c8557600080fd5b610c9187828801610af8565b95989497509550505050565b600080600080600080600060a0888a031215610cb857600080fd5b873567ffffffffffffffff80821115610cd057600080fd5b610cdc8b838c01610af8565b909950975060208a0135965060408a0135915080821115610cfc57600080fd5b50610d098a828b01610af8565b989b979a5095989597966060870135966080013595509350505050565b600080600080600060808688031215610d3e57600080fd5b610d4786610bf5565b945060208601359350610bbc604087016109cb565b60005b83811015610d77578181015183820152602001610d5f565b50506000910152565b83151560f81b815260008351610d9d816001850160208801610d5c565b60019201918201929092526021019392505050565b8281526040602082015260008251806040840152610dd7816060850160208701610d5c565b601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe016919091016060019392505050565b83815260406020820152816040820152818360608301376000818301606090810191909152601f9092017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe016010192915050565b8183823760009101908152919050565b80820180821115610384577f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fdfea164736f6c6343000811000a`

#### UniversalFactory Source Code

This is an exact copy of the code of the [LSP16 UniversalFactory smart contract].

- The source code is generated with `0.8.17` compiler version and with `9999999` optimization runs, and the metadata hash set to none.
- The imported contracts are part of the `4.9.2` version of the `@openzeppelin/contracts` package.
- Navigate to [lsp-smart-contract](https://github.com/lukso-network/lsp-smart-contracts) repo and checkout to `9e1519f94293b96efa2ebc8f459fde65cc43fecd` commit to obtain the exact copy of the code, change the compiler settings in `hardhat.config.ts` and compile to produce the same bytecode.

<details>
<summary>Click to Expand</summary>
<pre>

```solidity
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

// libraries
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

// errors

/**
 * @notice Couldn't initialize the contract.
 * @dev Reverts when there is no revert reason bubbled up by the created contract when initializing
 */
error ContractInitializationFailed();

/**
 * @dev Reverts when `msg.value` sent to {deployCreate2AndInitialize(..)} function is not equal to the sum of the `initializeCalldataMsgValue` and `constructorMsgValue`
 */
error InvalidValueSum();

/**
 * @title LSP16 Universal Factory
 * @dev Factory contract to deploy different types of contracts using the CREATE2 opcode
 * standardized as LSP16 - UniversalFactory:
 * https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-16-UniversalFactory.md
 *
 * The UniversalFactory will be deployed using Nick's Factory (0x4e59b44847b379578588920ca78fbf26c0b4956c)
 *
 * The deployed address can be found in the LSP16 specification.
 * Please refer to the LSP16 Specification to obtain the exact creation bytecode and salt that
 * should be used to produce the address of the UniversalFactory on different chains.
 *
 * This factory contract is designed to deploy contracts at the same address on multiple chains.
 *
 * The UniversalFactory can deploy 2 types of contracts:
 * - non-initializable (normal deployment)
 * - initializable (external call after deployment, e.g: proxy contracts)
 *
 * The `providedSalt` parameter given by the deployer is not used directly as the salt by the CREATE2 opcode.
 * Instead, it is used along with these parameters:
 *  - `initializable` boolean
 *  - `initializeCalldata` (when the contract is initializable and `initializable` is set to `true`).
 * These three parameters are concatenated together and hashed to generate the final salt for CREATE2.
 *
 * See {generateSalt} function for more details.
 *
 * The constructor and `initializeCalldata` SHOULD NOT include any network-specific parameters (e.g: chain-id,
 * a local token contract address), otherwise the deployed contract will not be recreated at the same address
 * across different networks, thus defeating the purpose of the UniversalFactory.
 *
 * One way to solve this problem is to set an EOA owner in the `initializeCalldata`/constructor
 * that can later call functions that set these parameters as variables in the contract.
 *
 * The UniversalFactory must be deployed at the same address on different chains to successfully deploy
 * contracts at the same address across different chains.
 */
contract LSP16UniversalFactory {
    /**
     * @dev placeholder for the `initializeCallData` param when the `initializable` boolean is set to `false`.
     */
    bytes private constant _EMPTY_BYTE = "";

    /**
     * @notice Contract created. Contract address: `createdContract`.
     * @dev Emitted whenever a contract is created.
     *
     * @param createdContract The address of the contract created.
     * @param providedSalt The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment.
     * @param generatedSalt The salt used by the `CREATE2` opcode for contract deployment.
     * @param initialized The Boolean that specifies if the contract must be initialized or not.
     * @param initializeCalldata The bytes provided as initializeCalldata (Empty string when `initialized` is set to false).
     */
    event ContractCreated(
        address indexed createdContract,
        bytes32 indexed providedSalt,
        bytes32 generatedSalt,
        bool indexed initialized,
        bytes initializeCalldata
    );

    /**
     * @notice Deploys a smart contract.
     *
     * @dev Deploys a contract using the CREATE2 opcode. The address where the contract will be deployed can be known in advance via the {computeAddress} function.
     *
     * This function deploys contracts without initialization (external call after deployment).
     *
     * The `providedSalt` parameter is not used directly as the salt by the CREATE2 opcode. Instead, it is hashed with keccak256: `keccak256(abi.encodePacked(false, providedSalt))`. See {generateSalt} function for more details.
     *
     * Using the same `creationBytecode` and `providedSalt` multiple times will revert, as the contract cannot be deployed twice at the same address.
     *
     * If the constructor of the contract to deploy is payable, value can be sent to this function to fund the created contract. However, sending value to this function while the constructor is not payable will result in a revert.
     *
     * @param creationBytecode The creation bytecode of the contract to be deployed
     * @param providedSalt The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
     *
     * @return The address of the deployed contract
     */
    function deployCreate2(
        bytes calldata creationBytecode,
        bytes32 providedSalt
    ) public payable virtual returns (address) {
        bytes32 generatedSalt = generateSalt(providedSalt, false, _EMPTY_BYTE);
        address contractCreated = Create2.deploy(
            msg.value,
            generatedSalt,
            creationBytecode
        );
        emit ContractCreated(
            contractCreated,
            providedSalt,
            generatedSalt,
            false,
            _EMPTY_BYTE
        );

        return contractCreated;
    }

    /**
     * @notice Deploys a smart contract and initializes it.
     *
     * @dev Deploys a contract using the CREATE2 opcode. The address where the contract will be deployed can be known in advance via the {computeAddress} function.
     *
     * This function deploys contracts with initialization (external call after deployment).
     *
     * The `providedSalt` parameter is not used directly as the salt by the CREATE2 opcode. Instead, it is hashed with keccak256: `keccak256(abi.encodePacked(true, initializeCalldata, providedSalt))`. See {generateSalt} function for more details.
     *
     * Using the same `creationBytecode`, `providedSalt` and `initializeCalldata` multiple times will revert, as the contract cannot be deployed twice at the same address.
     *
     * If the constructor or the initialize function of the contract to deploy is payable, value can be sent along with the deployment/initialization to fund the created contract. However, sending value to this function while the constructor/initialize function is not payable will result in a revert.
     *
     * Will revert if the `msg.value` sent to the function is not equal to the sum of `constructorMsgValue` and `initializeCalldataMsgValue`.
     *
     * @param creationBytecode The creation bytecode of the contract to be deployed
     * @param providedSalt The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
     * @param initializeCalldata The calldata to be executed on the created contract
     * @param constructorMsgValue The value sent to the contract during deployment
     * @param initializeCalldataMsgValue The value sent to the contract during initialization
     *
     * @return The address of the deployed contract
     */
    function deployCreate2AndInitialize(
        bytes calldata creationBytecode,
        bytes32 providedSalt,
        bytes calldata initializeCalldata,
        uint256 constructorMsgValue,
        uint256 initializeCalldataMsgValue
    ) public payable virtual returns (address) {
        if (constructorMsgValue + initializeCalldataMsgValue != msg.value)
            revert InvalidValueSum();

        bytes32 generatedSalt = generateSalt(
            providedSalt,
            true,
            initializeCalldata
        );
        address contractCreated = Create2.deploy(
            constructorMsgValue,
            generatedSalt,
            creationBytecode
        );
        emit ContractCreated(
            contractCreated,
            providedSalt,
            generatedSalt,
            true,
            initializeCalldata
        );

        (bool success, bytes memory returndata) = contractCreated.call{
            value: initializeCalldataMsgValue
        }(initializeCalldata);
        _verifyCallResult(success, returndata);

        return contractCreated;
    }

    /**
     * @notice Deploys a proxy smart contract.
     *
     * @dev Deploys an ERC1167 minimal proxy contract using the CREATE2 opcode. The address where the contract will be deployed can be known in advance via the {computeERC1167Address} function.
     *
     * This function deploys contracts without initialization (external call after deployment).
     *
     * The `providedSalt` parameter is not used directly as the salt by the CREATE2 opcode. Instead, it is hashed with keccak256: `keccak256(abi.encodePacked(false, providedSalt))`. See {generateSalt} function for more details.
     *
     * Using the same `implementationContract` and `providedSalt` multiple times will revert, as the contract cannot be deployed twice at the same address.
     *
     * Sending value to the contract created is not possible since the constructor of the ERC1167 minimal proxy is not payable.
     *
     * @param implementationContract The contract address to use as the base implementation behind the proxy that will be deployed
     * @param providedSalt The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
     *
     * @return The address of the minimal proxy deployed
     */
    function deployERC1167Proxy(
        address implementationContract,
        bytes32 providedSalt
    ) public virtual returns (address) {
        bytes32 generatedSalt = generateSalt(providedSalt, false, _EMPTY_BYTE);

        address proxy = Clones.cloneDeterministic(
            implementationContract,
            generatedSalt
        );
        emit ContractCreated(
            proxy,
            providedSalt,
            generatedSalt,
            false,
            _EMPTY_BYTE
        );

        return proxy;
    }

    /**
     * @notice Deploys a proxy smart contract and initializes it.
     *
     * @dev Deploys an ERC1167 minimal proxy contract using the CREATE2 opcode. The address where the contract will be deployed
     * can be known in advance via the {computeERC1167Address} function.
     *
     * This function deploys contracts with initialization (external call after deployment).
     *
     * The `providedSalt` parameter is not used directly as the salt by the CREATE2 opcode. Instead, it is hashed with keccak256: `keccak256(abi.encodePacked(true, initializeCalldata, providedSalt))`.
     * See {generateSalt} function for more details.
     *
     * Using the same `implementationContract`, `providedSalt` and `initializeCalldata` multiple times will revert, as the contract cannot be deployed twice at the same address.
     *
     * If the initialize function of the contract to deploy is payable, value can be sent along to fund the created contract while initializing. However, sending value to this function while the initialize function is not payable will result in a revert.
     *
     * @param implementationContract The contract address to use as the base implementation behind the proxy that will be deployed
     * @param providedSalt The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
     * @param initializeCalldata The calldata to be executed on the created contract
     *
     * @return The address of the minimal proxy deployed
     */
    function deployERC1167ProxyAndInitialize(
        address implementationContract,
        bytes32 providedSalt,
        bytes calldata initializeCalldata
    ) public payable virtual returns (address) {
        bytes32 generatedSalt = generateSalt(
            providedSalt,
            true,
            initializeCalldata
        );

        address proxy = Clones.cloneDeterministic(
            implementationContract,
            generatedSalt
        );
        emit ContractCreated(
            proxy,
            providedSalt,
            generatedSalt,
            true,
            initializeCalldata
        );

        (bool success, bytes memory returndata) = proxy.call{value: msg.value}(
            initializeCalldata
        );
        _verifyCallResult(success, returndata);

        return proxy;
    }

    /**
     * @dev Computes the address of a contract to be deployed using CREATE2, based on the input parameters.
     *
     * Any change in one of these parameters will result in a different address. When the `initializable` boolean is set to `false`, `initializeCalldata` will not affect the function output.
     *
     * @param creationBytecodeHash The keccak256 hash of the creation bytecode to be deployed
     * @param providedSalt The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
     * @param initializable A boolean that indicates whether an external call should be made to initialize the contract after deployment
     * @param initializeCalldata The calldata to be executed on the created contract if `initializable` is set to `true`
     *
     * @return The address where the contract will be deployed
     */
    function computeAddress(
        bytes32 creationBytecodeHash,
        bytes32 providedSalt,
        bool initializable,
        bytes calldata initializeCalldata
    ) public view virtual returns (address) {
        bytes32 generatedSalt = generateSalt(
            providedSalt,
            initializable,
            initializeCalldata
        );
        return Create2.computeAddress(generatedSalt, creationBytecodeHash);
    }

    /**
     * @dev Computes the address of an ERC1167 proxy contract based on the input parameters.
     *
     * Any change in one of these parameters will result in a different address. When the `initializable` boolean is set to `false`, `initializeCalldata` will not affect the function output.
     *
     * @param implementationContract The contract to create a clone of according to ERC1167
     * @param providedSalt The salt provided by the deployer, which will be used to generate the final salt that will be used by the `CREATE2` opcode for contract deployment
     * @param initializable A boolean that indicates whether an external call should be made to initialize the proxy contract after deployment
     * @param initializeCalldata The calldata to be executed on the created contract if `initializable` is set to `true`
     *
     * @return The address where the ERC1167 proxy contract will be deployed
     */
    function computeERC1167Address(
        address implementationContract,
        bytes32 providedSalt,
        bool initializable,
        bytes calldata initializeCalldata
    ) public view virtual returns (address) {
        bytes32 generatedSalt = generateSalt(
            providedSalt,
            initializable,
            initializeCalldata
        );
        return
            Clones.predictDeterministicAddress(
                implementationContract,
                generatedSalt
            );
    }

    /**
     * @dev Generates the salt used to deploy the contract by hashing the following parameters (concatenated together) with keccak256:
     * 1. the `providedSalt`
     * 2. the `initializable` boolean
     * 3. the `initializeCalldata`, only if the contract is initializable (the `initializable` boolean is set to `true`)
     *
     * - The `providedSalt` parameter is not used directly as the salt by the CREATE2 opcode. Instead, it is used along with these parameters:
     *  1. `initializable` boolean
     *  2. `initializeCalldata` (when the contract is initializable and `initializable` is set to `true`).
     *
     * - This approach ensures that in order to reproduce an initializable contract at the same address on another chain, not only the `providedSalt` is required to be the same, but also the initialize parameters within the `initializeCalldata` must also be the same. This maintains consistent deployment behaviour. Users are required to initialize contracts with the same parameters across different chains to ensure contracts are deployed at the same address across different chains.
     *
     * 1. Example (for initializable contracts)
     *
     * -  For an existing contract A on chain 1 owned by X, to replicate the same contract at the same address with
     * the same owner X on chain 2, the salt used to generate the address should include the initializeCalldata
     * that assigns X as the owner of contract A.
     *
     * - For instance, if another user, Y, tries to deploy the contract at the same address
     * on chain 2 using the same providedSalt, but with a different initializeCalldata to make Y the owner instead of X,
     * the generated address would be different, preventing Y from deploying the contract with different ownership
     * at the same address.
     *
     * - However, for non-initializable contracts, if the constructor has arguments that specify the deployment behavior, they
     * will be included in the creation bytecode. Any change in the constructor arguments will lead to a different contract's creation bytecode
     * which will result in a different address on other chains.
     *
     * 2. Example (for non-initializable contracts)
     *
     * - If a contract is deployed with specific constructor arguments on chain 1, these arguments are embedded within the creation bytecode.
     * For instance, if contract B is deployed with a specific `tokenName` and `tokenSymbol` on chain 1, and a user wants to deploy
     * the same contract with the same `tokenName` and `tokenSymbol` on chain 2, they must use the same constructor arguments to
     * produce the same creation bytecode. This ensures that the same deployment behaviour is maintained across different chains,
     * as long as the same creation bytecode is used.
     *
     * - If another user Z, tries to deploy the same contract B at the same address on chain 2 using the same `providedSalt`
     * but different constructor arguments (a different `tokenName` and/or `tokenSymbol`), the generated address will be different.
     * This prevents user Z from deploying the contract with different constructor arguments at the same address on chain 2.
     *
     * - The providedSalt was hashed to produce the salt used by CREATE2 opcode to prevent users from deploying initializable contracts
     * using non-initializable functions such as {deployCreate2} without having the initialization call.
     *
     * - In other words, if the providedSalt was not hashed and was used as it is as the salt by the CREATE2 opcode, malicious users
     * can check the generated salt used for the already deployed initializable contract on chain 1, and deploy the contract
     * from {deployCreate2} function on chain 2, with passing the generated salt of the deployed contract as providedSalt
     * that will produce the same address but without the initialization, where the malicious user can initialize after.
     *
     * @param initializable The Boolean that specifies if the contract must be initialized or not
     * @param initializeCalldata The calldata to be executed on the created contract if `initializable` is set to `true`
     * @param providedSalt The salt provided by the deployer, which will be used to generate the final salt
     * that will be used by the `CREATE2` opcode for contract deployment
     *
     * @return The generated salt which will be used for CREATE2 deployment
     */
    function generateSalt(
        bytes32 providedSalt,
        bool initializable,
        bytes memory initializeCalldata
    ) public pure virtual returns (bytes32) {
        if (initializable) {
            return
                keccak256(
                    abi.encodePacked(true, initializeCalldata, providedSalt)
                );
        } else {
            return keccak256(abi.encodePacked(false, providedSalt));
        }
    }

    /**
     * @dev Verifies that the contract created was initialized correctly.
     * Bubble the revert reason if present, revert with `ContractInitializationFailed` otherwise.
     */
    function _verifyCallResult(
        bool success,
        bytes memory returndata
    ) internal pure virtual {
        if (!success) {
            // Look for revert reason and bubble it up if present
            if (returndata.length != 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                // solhint-disable no-inline-assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert ContractInitializationFailed();
            }
        }
    }
}
```

</pre>
</details>

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

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP16UniversalFactory/LSP16UniversalFactory.sol) repository.

## Security Consideration

Knowing that deploying a contract using the UniversalFactory will allow to deploy the same contract on other chains with the same address, people should be aware and watch out to use contracts that don't have a logic that protects against replay-attacks.

The constructor parameters or/and initialization data SHOULD NOT include any network-specific parameters (e.g: chain-id, a local token contract address), otherwise the deployed contract will not be recreated at the same address across different networks, thus defeating the purpose of the UniversalFactory.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

[EIP-155]: ./eip-155.md
[CREATE2]: https://eips.ethereum.org/EIPS/eip-1014
[minimal proxy]: https://eips.ethereum.org/EIPS/eip-1167
[ContractCreated]: ./LSP-16-UniversalFactory.md#contractcreated
[LSP16 UniversalFactory smart contract]: https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP16UniversalFactory/LSP16UniversalFactory.sol
[Nick Factory]: https://github.com/Arachnid/deterministic-deployment-proxy
