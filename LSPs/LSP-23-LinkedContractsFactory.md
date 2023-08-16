---
lip: 23
title: LSP23 Linked Contracts Factory
author: skimaharvey
discussions-to: <URL>
status: Draft
type: LSP
created: 2023-08-16
requires: ERC1167
---

## Table of Content

- [Simple Summary](#simple-summary)
- [Abstract](#abstract)
- [Motivation](#motivation)
- [Specification](#specification)
  - [Methods](#methods)
    - [deployContracts](#deploycontracts)
    - [deployERC1167Proxies](#deployerc1167proxies)
- [Implementation](#implementation)
- [Interface Cheat Sheet](#interface-cheat-sheet)
- [Copyright](#copyright)

## Simple Summary

Deploying smart contracts that need to interact with each other can be complicated. This is especially true when these contracts need to know each other's details at the time they are created. The LSP23 standard simplifies this process by providing a unified way to deploy such interdependent contracts. It also allows for additional actions to be taken automatically after the contracts are deployed, making the whole process more streamlined and less error-prone.

## Abstract

The LSP23 Linked Contracts Factory standard introduces a unified interface for deploying interdependent smart contracts, also known as linked contracts. These contracts often require each other's addresses at the time of deployment, creating a circular dependency. LSP23 addresses this by allowing for the deployment of a primary contract and one or more secondary contracts, linking them together. The standard also supports the deployment of contracts as `ERC1167` minimal proxies and enables optional post-deployment modules for executing additional logic. This serves to simplify and standardize the deployment of complex contract systems.

## Motivation

While there are various methods for deploying smart contracts in the current ecosystem, the challenge of deploying interdependent contracts in a streamlined and secure manner remains. Custom solutions often exist, but they can be cumbersome and prone to errors. LSP23 aims to standardize this process, reducing the complexity and potential for mistakes. By generating the salt for contract deployment within the function, the standard also ensures a fully decentralized deployment process. This not only guarantees consistent contract addresses across multiple chains but also serves as a preventive measure against address squatting, enhancing the overall security and integrity of the deployment process.

## Specification

### Methods

#### LSP23LinkedContractsFactory

The `LSP23LinkedContractsFactory` contract provides two main functions for deploying linked contracts: `deployContracts` and `deployERC1167Proxies`. Both functions allow the deployment of primary and secondary contracts, with optional post-deployment modules.

##### deployContracts

```solidity
function deployContracts(
    PrimaryContractDeployment calldata primaryContractDeployment,
    SecondaryContractDeployment calldata secondaryContractDeployment,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
)
    public
    payable
    returns (
        address primaryContractAddress,
        address secondaryContractAddress
    );
```
Deploys primary and secondary contracts and links them together. Optionally executes a post-deployment module.

_Parameters:_

- `primaryContractDeployment`: Deployment parameters for the primary contract.
- `secondaryContractDeployment`: Deployment parameters for the secondary contract.
- `postDeploymentModule`: Address of the post-deployment module to execute.
- `postDeploymentModuleCalldata`: Calldata for the post-deployment module.

_Returns:_ address, address , the addresses of the deployed primary and secondary contracts.

##### deployERC1167Proxies

```solidity
function deployERC1167Proxies(
    PrimaryContractDeploymentInit calldata primaryContractDeploymentInit,
    SecondaryContractDeploymentInit calldata secondaryContractDeploymentInit,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
)
    public
    payable
    returns (
        address primaryContractAddress,
        address secondaryContractAddress
    );
```

Deploys primary and secondary contracts as ERC1167 proxies and links them together. Optionally executes a post-deployment module.

_Parameters:_

- `primaryContractDeploymentInit`: Deployment parameters for the primary contract proxy.
- `secondaryContractDeploymentInit`: Deployment parameters for the secondary contract proxy.
- `postDeploymentModule`: Address of the post-deployment module to execute.
- `postDeploymentModuleCalldata`: Calldata for the post-deployment module.

_Returns_: address, address , the addresses of the deployed primary and secondary contract proxies.

#### PostDeploymentModule

Post-deployment modules are optionals and executed after the primary and secondary contracts are deployed. The `executePostDeployment` function is called with the addresses of the deployed primary and secondary contracts as well as the calldata for the post-deployment module.

```solidity
    function executePostDeployment(
        address primaryContract,
        address secondaryContract,
        bytes calldata calldataToPostDeploymentModule
    ) public;
```

Executes post-deployment logic.

_Parameters:_

- primaryContract: Address of the primary contract.
- secondaryContract: Address of the secondary contract.
- calldataToPostDeploymentModule: Calldata for the post-deployment module.


## Implementation
An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/contracts/LSP23LinkedContractsDeployment/LSP23LinkedContractsFactory.sol)

## Interface Cheat Sheet

### ILSP23LinkedContractsFactory

```solidity
interface ILSP23LinkedContractsFactory {
    /**
     * @dev Emitted when a primary and secondary contract are deployed.
     * @param primaryContract Address of the deployed primary contract.
     * @param secondaryContract Address of the deployed secondary contract.
     * @param primaryContractDeployment Parameters used for the primary contract deployment.
     * @param secondaryContractDeployment Parameters used for the secondary contract deployment.
     * @param postDeploymentModule Address of the post-deployment module.
     * @param postDeploymentModuleCalldata Calldata passed to the post-deployment module.
     */
    event DeployedContracts(
        address indexed primaryContract,
        address indexed secondaryContract,
        PrimaryContractDeployment primaryContractDeployment,
        SecondaryContractDeployment secondaryContractDeployment,
        address postDeploymentModule,
        bytes postDeploymentModuleCalldata
    );

    /**
     * @dev Emitted when proxies of a primary and secondary contract are deployed.
     * @param primaryContract Address of the deployed primary contract proxy.
     * @param secondaryContract Address of the deployed secondary contract proxy.
     * @param primaryContractDeploymentInit Parameters used for the primary contract proxy deployment.
     * @param secondaryContractDeploymentInit Parameters used for the secondary contract proxy deployment.
     * @param postDeploymentModule Address of the post-deployment module.
     * @param postDeploymentModuleCalldata Calldata passed to the post-deployment module.
     */
    event DeployedERC1167Proxies(
        address indexed primaryContract,
        address indexed secondaryContract,
        PrimaryContractDeploymentInit primaryContractDeploymentInit,
        SecondaryContractDeploymentInit secondaryContractDeploymentInit,
        address postDeploymentModule,
        bytes postDeploymentModuleCalldata
    );


    /**
     * @param salt A unique value used to ensure each created proxies are unique. (Can be used to deploy the contract at a desired address.)
     * @param fundingAmount The value to be sent with the deployment transaction.
     * @param creationBytecode The bytecode of the contract with the constructor params.
     */
    struct PrimaryContractDeployment {
        bytes32 salt;
        uint256 fundingAmount;
        bytes creationBytecode;
    }

    /**
     * @param fundingAmount The value to be sent with the deployment transaction.
     * @param creationBytecode The constructor + runtime bytecode (without the primary contract's address as param)
     * @param addPrimaryContractAddress If set to `true`, this will append the primary contract's address + the `extraConstructorParams` to the `creationBytecode`.
     * @param extraConstructorParams Params to be appended to the `creationBytecode` (after the primary contract address) if `addPrimaryContractAddress` is set to `true`.
     */
    struct SecondaryContractDeployment {
        uint256 fundingAmount;
        bytes creationBytecode;
        bool addPrimaryContractAddress;
        bytes extraConstructorParams;
    }

    /**
     * @param salt A unique value used to ensure each created proxies are unique. (Can be used to deploy the contract at a desired address.)
     * @param fundingAmount The value to be sent with the deployment transaction.
     * @param implementationContract The address of the contract that will be used as a base contract for the proxy.
     * @param initializationCalldata The calldata used to initialise the contract. (initialization should be similar to a constructor in a normal contract.)
     */
    struct PrimaryContractDeploymentInit {
        bytes32 salt;
        uint256 fundingAmount;
        address implementationContract;
        bytes initializationCalldata;
    }

    /**
     * @param fundingAmount The value to be sent with the deployment transaction.
     * @param implementationContract The address of the contract that will be used as a base contract for the proxy.
     * @param initializationCalldata The first part of the initialisation calldata, everything before the primary contract address.
     * @param addPrimaryContractAddress If set to `true`, this will append the primary contract's address + the `extraInitializationParams` to the `initializationCalldata`.
     * @param extraInitializationParams Params to be appended to the `initializationCalldata` (after the primary contract address) if `addPrimaryContractAddress` is set to `true`
     */
    struct SecondaryContractDeploymentInit {
        uint256 fundingAmount;
        address implementationContract;
        bytes initializationCalldata;
        bool addPrimaryContractAddress;
        bytes extraInitializationParams;
    }

    /**
     * @dev Deploys a primary and a secondary linked contract.
     * @notice Contracts deployed. Contract Address: `primaryContractAddress`. Primary Contract Address: `primaryContractAddress`
     *
     * @param primaryContractDeployment Contains the needed parameter to deploy a contract. (`salt`, `fundingAmount`, `creationBytecode`)
     * @param secondaryContractDeployment Contains the needed parameter to deploy the secondary contract. (`fundingAmount`, `creationBytecode`, `addPrimaryContractAddress`, `extraConstructorParams`)
     * @param postDeploymentModule The module to be executed after deployment
     * @param postDeploymentModuleCalldata The data to be passed to the post deployment module
     *
     * @return primaryContractAddress The address of the primary contract.
     * @return secondaryContractAddress The address of the secondary contract.
     */
    function deployContracts(
        PrimaryContractDeployment calldata primaryContractDeployment,
        SecondaryContractDeployment calldata secondaryContractDeployment,
        address postDeploymentModule,
        bytes calldata postDeploymentModuleCalldata
    )
        external
        payable
        returns (
            address primaryContractAddress,
            address secondaryContractAddress
        );

    /**
     * @dev Deploys proxies of a primary contract and a secondary linked contract
     * @notice Contract proxies deployed. Primary Proxy Address: `primaryContractAddress`. Secondary Contract Proxy Address: `secondaryContractAddress`
     *
     * @param primaryContractDeploymentInit Contains the needed parameters to deploy a proxy contract. (`salt`, `fundingAmount`, `implementationContract`, `initializationCalldata`)
     * @param secondaryContractDeploymentInit Contains the needed parameters to deploy the secondary proxy contract. (`fundingAmount`, `implementationContract`, `addPrimaryContractAddress`, `initializationCalldata`, `extraInitializationParams`)
     * @param postDeploymentModule The module to be executed after deployment.
     * @param postDeploymentModuleCalldata The data to be passed to the post deployment module.
     *
     * @return primaryContractAddress The address of the deployed primary contract proxy
     * @return secondaryContractAddress The address of the deployed secondary contract proxy
     */
    function deployERC1167Proxies(
        PrimaryContractDeploymentInit calldata primaryContractDeploymentInit,
        SecondaryContractDeploymentInit
            calldata secondaryContractDeploymentInit,
        address postDeploymentModule,
        bytes calldata postDeploymentModuleCalldata
    )
        external
        payable
        returns (
            address primaryContractAddress,
            address secondaryContractAddress
        );

    /**
     * @dev Computes the addresses of a primary contract and a secondary linked contract
     *
     * @param primaryContractDeployment Contains the needed parameter to deploy the primary contract. (`salt`, `fundingAmount`, `creationBytecode`)
     * @param secondaryContractDeployment Contains the needed parameter to deploy the secondary contract. (`fundingAmount`, `creationBytecode`, `addPrimaryContractAddress`, `extraConstructorParams`)
     * @param postDeploymentModule The module to be executed after deployment
     * @param postDeploymentModuleCalldata The data to be passed to the post deployment module
     *
     * @return primaryContractAddress The address of the deployed primary contract.
     * @return secondaryContractAddress The address of the deployed secondary contract.
     */
    function computeAddresses(
        PrimaryContractDeployment calldata primaryContractDeployment,
        SecondaryContractDeployment calldata secondaryContractDeployment,
        address postDeploymentModule,
        bytes calldata postDeploymentModuleCalldata
    )
        external
        view
        returns (
            address primaryContractAddress,
            address secondaryContractAddress
        );

    /**
     * @dev Computes the addresses of a primary and a secondary linked contracts proxies to be created
     *
     * @param primaryContractDeploymentInit Contains the needed parameters to deploy a primary proxy contract. (`salt`, `fundingAmount`, `implementationContract`, `initializationCalldata`)
     * @param secondaryContractDeploymentInit Contains the needed parameters to deploy the secondary proxy contract. (`fundingAmount`, `implementationContract`, `addPrimaryContractAddress`, `initializationCalldata`, `extraInitializationParams`)
     * @param postDeploymentModule The module to be executed after deployment.
     * @param postDeploymentModuleCalldata The data to be passed to the post deployment module.
     *
     * @return primaryContractAddress The address of the deployed primary contract proxy
     * @return secondaryContractAddress The address of the deployed secondary contract proxy
     */
    function computeERC1167Addresses(
        PrimaryContractDeploymentInit calldata primaryContractDeploymentInit,
        SecondaryContractDeploymentInit
            calldata secondaryContractDeploymentInit,
        address postDeploymentModule,
        bytes calldata postDeploymentModuleCalldata
    )
        external
        view
        returns (
            address primaryContractAddress,
            address secondaryContractAddress
        );
}
```

### IPostDeploymentModule

```solidity
interface IPostDeploymentModule {
    /**
     * @dev Executes post-deployment logic.
     * @param primaryContractAddress Address of the deployed primary contract or proxy.
     * @param secondaryContractAddress Address of the deployed secondary contract or proxy.
     * @param postDeploymentModuleCalldata Calldata for the post-deployment module.
     */
    function executePostDeployment(
        address primaryContractAddress,
        address secondaryContractAddress,
        bytes calldata postDeploymentModuleCalldata
    ) external;
}
```

## Copyright
Copyright and related rights waived via CC0.

