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

**The official LSP23 Linked Contracts Factory address on LUKSO is: [0x2300000A84D25dF63081feAa37ba6b62C4c89a30](https://explorer.lukso.network/address/0x2300000A84D25dF63081feAa37ba6b62C4c89a30).**

To deploy this follower system on other chains please see the [deployment section](#deployment).

## Simple Summary

Deploying smart contracts that need to interact with each other can be complicated. This is especially true when these contracts need to know each other's details at the time they are created. The LSP23 standard simplifies this process by providing a unified way to deploy such interdependent contracts. It also allows for additional actions to be taken automatically after the contracts are deployed, making the whole process more streamlined and less error-prone.

## Abstract

LSP23 simplifies the deployment of interdependent smart contracts by providing a standardized way to deploy and link contracts that require knowledge of each other's details at creation. It addresses the challenge of circular dependencies in contract deployment, enabling the establishment of complex contract systems with ease. Through the use of post-deployment modules, LSP 23 also facilitates additional actions after contracts are deployed, streamlining the process and reducing potential errors. This standard is particularly beneficial for deploying contract ecosystems where components need to interact closely, ensuring seamless integration and interaction across the deployed contracts.

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

An implementation can be found in the [lukso-network/lsp-smart-contracts](https://github.com/lukso-network/lsp-smart-contracts/blob/develop/packages/lsp23-contracts/contracts/LSP23LinkedContractsFactory.sol)

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

## Deployment

The `LSP23LinkedContractsFactory` is deplpoyed at [`0x2300000A84D25dF63081feAa37ba6b62C4c89a30`](https://explorer.lukso.network/address/0x2300000A84D25dF63081feAa37ba6b62C4c89a30) on LUKSO using the [Nick Factory contract](https://github.com/Arachnid/deterministic-deployment-proxy/tree/master). The following explains how to deploy `LSP23LinkedContractsFactory` at the same address on other EVM networks.

### LSP23LinkedContractsFactory Deployment

After the [deployment of Nick Factory on the network](https://github.com/Arachnid/deterministic-deployment-proxy/tree/master) ([`0x4e59b44847b379578588920cA78FbF26c0B4956C`](https://explorer.lukso.network/address/0x4e59b44847b379578588920cA78FbF26c0B4956C)), the `LSP23LinkedContractsFactory` can be deployed at `0x2300000A84D25dF63081feAa37ba6b62C4c89a30` using the salt: `0x12a6712f113536d8b01d99f72ce168c7e1090124db54cd16f03c20000022178c` with the following transaction data from any EOA to Nicks Factory address `0x4e59b44847b379578588920cA78FbF26c0B4956C` with 900,000 GAS:

```js
0x12a6712f113536d8b01d99f72ce168c7e1090124db54cd16f03c20000022178c608060405234801561001057600080fd5b50611247806100206000396000f3fe60806040526004361061003f5760003560e01c80636a66a7531461004457806372b19d361461007b578063754b86b51461009b578063dd5940f3146100ae575b600080fd5b610057610052366004610c0b565b6100ce565b604080516001600160a01b0393841681529290911660208301520160405180910390f35b34801561008757600080fd5b50610057610096366004610c0b565b610204565b6100576100a9366004610cb4565b61028d565b3480156100ba57600080fd5b506100576100c9366004610cb4565b610324565b6000806100e086356020890135610d28565b34146100ff57604051632fd9ca9160e01b815260040160405180910390fd5b61010c878787878761047d565b9150610118868361056c565b9050806001600160a01b0316826001600160a01b03167fe20570ed9bda3b93eea277b4e5d975c8933fd5f85f2c824d0845ae96c55a54fe8989898989604051610165959493929190610de1565b60405180910390a36001600160a01b038516156101fa576040517f28c4d14e0000000000000000000000000000000000000000000000000000000081526001600160a01b038616906328c4d14e906101c7908590859089908990600401610eed565b600060405180830381600087803b1580156101e157600080fd5b505af11580156101f5573d6000803e3d6000fd5b505050505b9550959350505050565b6000806000610216888888888861071a565b905061023161022b60608a0160408b01610f24565b82610795565b92506102806102466040890160208a01610f24565b6040516bffffffffffffffffffffffff19606087901b16602082015260340160405160208183030381529060405280519060200120610795565b9150509550959350505050565b60008061029f86356020890135610d28565b34146102be57604051632fd9ca9160e01b815260040160405180910390fd5b6102cb87878787876107fa565b91506102d78683610867565b9050806001600160a01b0316826001600160a01b03167f0e20ea3d6273aab49a7dabafc15cc94971c12dd63a07185ca810e497e4e87aa68989898989604051610165959493929190610f3f565b60008060006103368888888888610966565b90506103648161034960408b018b610fdf565b604051610357929190611026565b60405180910390206109af565b9250606061037788820160408a01611036565b156103e4576103896020890189610fdf565b604080516001600160a01b03881660208201520160408051601f198184030181529190526103ba60608c018c610fdf565b6040516020016103ce959493929190611075565b6040516020818303038152906040529050610429565b6103f16020890189610fdf565b8080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509293505050505b6040516bffffffffffffffffffffffff19606086901b16602082015261046f906034016040516020818303038152906040528051906020012082805190602001206109af565b925050509550959350505050565b60008061048d878787878761071a565b90506104a86104a26060890160408a01610f24565b826109bc565b91506000806001600160a01b03841660208a01356104c960608c018c610fdf565b6040516104d7929190611026565b60006040518083038185875af1925050503d8060008114610514576040519150601f19603f3d011682016040523d82523d6000602084013e610519565b606091505b50915091508161056057806040517f4364b6ee00000000000000000000000000000000000000000000000000000000815260040161055791906110a9565b60405180910390fd5b50505095945050505050565b60006105bb6105816040850160208601610f24565b6040516bffffffffffffffffffffffff19606086901b166020820152603401604051602081830303815290604052805190602001206109bc565b905060006105cc6040850185610fdf565b8080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929350610614925050506080850160608601611036565b1561067157604080516001600160a01b038516602082015282910160408051601f1981840301815291905261064c6080870187610fdf565b60405160200161065f94939291906110dc565b60405160208183030381529060405290505b600080836001600160a01b03168660000135846040516106919190611118565b60006040518083038185875af1925050503d80600081146106ce576040519150601f19603f3d011682016040523d82523d6000602084013e6106d3565b606091505b50915091508161071157806040517f9654a85400000000000000000000000000000000000000000000000000000000815260040161055791906110a9565b50505092915050565b6000853561072e6040870160208801610f24565b61073b6040880188610fdf565b61074b60808a0160608b01611036565b61075860808b018b610fdf565b8a8a8a6040516020016107749a99989796959493929190611134565b60405160208183030381529060405280519060200120905095945050505050565b6040513060388201526f5af43d82803e903d91602b57fd5bf3ff602482015260148101839052733d602d80600a3d3981f3363d3d373d3d3d363d738152605881018290526037600c820120607882015260556043909101206000905b90505b92915050565b60008061080a8787878787610966565b905061085c60208801358261082260408b018b610fdf565b8080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250610a5992505050565b979650505050505050565b6000806108776020850185610fdf565b8080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509293506108bf925050506060850160408601611036565b1561091c57604080516001600160a01b038516602082015282910160408051601f198184030181529190526108f76060870187610fdf565b60405160200161090a94939291906110dc565b60405160208183030381529060405290505b6040516bffffffffffffffffffffffff19606085901b16602082015261095e908535906034016040516020818303038152906040528051906020012083610a59565b949350505050565b600085356109776020870187610fdf565b6109876060890160408a01611036565b61099460608a018a610fdf565b898989604051602001610774999897969594939291906111a8565b60006107f1838330610b64565b6000763d602d80600a3d3981f3363d3d373d3d3d363d730000008360601b60e81c176000526e5af43d82803e903d91602b57fd5bf38360781b1760205281603760096000f590506001600160a01b0381166107f45760405162461bcd60e51b815260206004820152601760248201527f455243313136373a2063726561746532206661696c65640000000000000000006044820152606401610557565b600083471015610aab5760405162461bcd60e51b815260206004820152601d60248201527f437265617465323a20696e73756666696369656e742062616c616e63650000006044820152606401610557565b8151600003610afc5760405162461bcd60e51b815260206004820181905260248201527f437265617465323a2062797465636f6465206c656e677468206973207a65726f6044820152606401610557565b8282516020840186f590506001600160a01b038116610b5d5760405162461bcd60e51b815260206004820152601960248201527f437265617465323a204661696c6564206f6e206465706c6f79000000000000006044820152606401610557565b9392505050565b6000604051836040820152846020820152828152600b8101905060ff815360559020949350505050565b600060808284031215610ba057600080fd5b50919050565b80356001600160a01b0381168114610bbd57600080fd5b919050565b60008083601f840112610bd457600080fd5b50813567ffffffffffffffff811115610bec57600080fd5b602083019150836020828501011115610c0457600080fd5b9250929050565b600080600080600060808688031215610c2357600080fd5b853567ffffffffffffffff80821115610c3b57600080fd5b610c4789838a01610b8e565b96506020880135915080821115610c5d57600080fd5b9087019060a0828a031215610c7157600080fd5b819550610c8060408901610ba6565b94506060880135915080821115610c9657600080fd5b50610ca388828901610bc2565b969995985093965092949392505050565b600080600080600060808688031215610ccc57600080fd5b853567ffffffffffffffff80821115610ce457600080fd5b908701906060828a031215610cf857600080fd5b90955060208701359080821115610d0e57600080fd5b610d1a89838a01610b8e565b9550610c8060408901610ba6565b808201808211156107f4577f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b6000808335601e19843603018112610d7957600080fd5b830160208101925035905067ffffffffffffffff811115610d9957600080fd5b803603821315610c0457600080fd5b81835281816020850137506000828201602090810191909152601f909101601f19169091010190565b80358015158114610bbd57600080fd5b6080815285356080820152602086013560a08201526000610e0460408801610ba6565b6001600160a01b0380821660c0850152610e2160608a018a610d62565b9250608060e0860152610e3961010086018483610da8565b92505083820360208501528735825280610e5560208a01610ba6565b16602083015250610e696040880188610d62565b60a06040840152610e7e60a084018284610da8565b915050610e8d60608901610dd1565b15156060830152610ea16080890189610d62565b8383036080850152610eb4838284610da8565b9350505050610ece60408401876001600160a01b03169052565b8281036060840152610ee1818587610da8565b98975050505050505050565b60006001600160a01b03808716835280861660208401525060606040830152610f1a606083018486610da8565b9695505050505050565b600060208284031215610f3657600080fd5b6107f182610ba6565b6080815285356080820152602086013560a08201526000610f636040880188610d62565b606060c0850152610f7860e085018284610da8565b915050828103602084015286358152610f946020880188610d62565b60806020840152610fa9608084018284610da8565b915050610fb860408901610dd1565b15156040830152610fcc6060890189610d62565b8383036060850152610eb4838284610da8565b6000808335601e19843603018112610ff657600080fd5b83018035915067ffffffffffffffff82111561101157600080fd5b602001915036819003821315610c0457600080fd5b8183823760009101908152919050565b60006020828403121561104857600080fd5b6107f182610dd1565b60005b8381101561106c578181015183820152602001611054565b50506000910152565b848682376000858201600081528551611092818360208a01611051565b018385823760009301928352509095945050505050565b60208152600082518060208401526110c8816040850160208701611051565b601f01601f19169190910160400192915050565b600085516110ee818460208a01611051565b855190830190611102818360208a01611051565b0183858237600093019283525090949350505050565b6000825161112a818460208701611051565b9190910192915050565b8a815260006001600160a01b03808c16602084015260e0604084015261115e60e084018b8d610da8565b8915156060850152838103608085015261117981898b610da8565b905081871660a085015283810360c0850152611196818688610da8565b9e9d5050505050505050505050505050565b89815260c0602082015260006111c260c083018a8c610da8565b881515604084015282810360608401526111dd81888a610da8565b90506001600160a01b038616608084015282810360a0840152611201818587610da8565b9c9b50505050505050505050505056fea2646970667358221220add0ea42f8f9e02abd8c7da64d0b13eef395e008fa30377a6b79ea444e7d21bb64736f6c63430008110033;
```

This should deploy the `LSP23LinkedContractsFactory` at the following address: `0x2300000A84D25dF63081feAa37ba6b62C4c89a30`.

The deployed [implementation code can be found here](https://github.com/lukso-network/lsp-smart-contracts/tree/b8eca3c5696acf85239130ef67edec9e8c134bfa/contracts/LSP23LinkedContractsDeployment).

- The source code is generated with `0.8.17` compiler version and with `9999999` optimization runs.

## Copyright

Copyright and related rights waived via CC0.
