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

### Linked Contracts Factory Setup

#### Deployment

Before the deployment of the `LSP23LinkedContractsFactory` on any network, people should make sure that the Nick Factory is deployed on the same network.

##### Nick Factory Deployment

The Nick Factory should be located at this address `0x4e59b44847b379578588920ca78fbf26c0b4956c` on the network. If there is no code on this address, it means that the contract is not deployed yet.

To deploy, the following raw transaction should be broadcasted to the network `0xf8a58085174876e800830186a08080b853604580600e600039806000f350fe7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf31ba02222222222222222222222222222222222222222222222222222222222222222a02222222222222222222222222222222222222222222222222222222222222222` after funding the deployer address: `0x3fab184622dc19b6109349b94811493bf2a45362` with `gasPrice (100 gwei) * gasLimit (100000)`.

Check [Nick's Factory repository](https://github.com/Arachnid/deterministic-deployment-proxy/tree/master) for more information.

##### LSP23LinkedContractsFactory Deployment

After the deployment of Nick Factory on the network, the `LSP23LinkedContractsFactory` can be reproduced at the standardized address given sending the same salt and bytecode.

In order to create the UniversalFactory contract, one should send a transaction to the [Nick Factory] address with data field equal to [salt](#standardized-salt) + [bytecode](#standardized-bytecode).

The address produced should be equal to `0x2300000A84D25dF63081feAa37ba6b62C4c89a30`.

#### UniversalFactory Configuration

##### Standardized Address

`0x2300000A84D25dF63081feAa37ba6b62C4c89a30`

##### Standardized Salt

`0x12a6712f113536d8b01d99f72ce168c7e1090124db54cd16f03c20000022178c`

##### Standardized Bytecode

`0x608060405234801561001057600080fd5b50611505806100206000396000f3fe60806040526004361061003f5760003560e01c80636a66a7531461004457806372b19d3614610088578063754b86b5146100a8578063dd5940f3146100bb575b600080fd5b610057610052366004610e0e565b6100db565b6040805173ffffffffffffffffffffffffffffffffffffffff93841681529290911660208301520160405180910390f35b34801561009457600080fd5b506100576100a3366004610e0e565b61025e565b6100576100b6366004610eb7565b6102fa565b3480156100c757600080fd5b506100576100d6366004610eb7565b6103c4565b6000806100ed86356020890135610f2b565b3414610125576040517f2fd9ca9100000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b610132878787878761055b565b915061013e8683610657565b90508073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff167fe20570ed9bda3b93eea277b4e5d975c8933fd5f85f2c824d0845ae96c55a54fe89898989896040516101a5959493929190611022565b60405180910390a373ffffffffffffffffffffffffffffffffffffffff851615610254576040517f28c4d14e00000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff8616906328c4d14e90610221908590859089908990600401611148565b600060405180830381600087803b15801561023b57600080fd5b505af115801561024f573d6000803e3d6000fd5b505050505b9550959350505050565b60008060006102708888888888610850565b905061028b61028560608a0160408b0161118c565b826108cb565b92506102ed6102a06040890160208a0161118c565b6040517fffffffffffffffffffffffffffffffffffffffff000000000000000000000000606087901b166020820152603401604051602081830303815290604052805190602001206108cb565b9150509550959350505050565b60008061030c86356020890135610f2b565b3414610344576040517f2fd9ca9100000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6103518787878787610930565b915061035d868361099d565b90508073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff167f0e20ea3d6273aab49a7dabafc15cc94971c12dd63a07185ca810e497e4e87aa689898989896040516101a59594939291906111a7565b60008060006103d68888888888610ada565b9050610404816103e960408b018b611247565b6040516103f79291906112ac565b6040518091039020610b23565b9250606061041788820160408a016112bc565b156104af576104296020890189611247565b6040805173ffffffffffffffffffffffffffffffffffffffff8816602082015201604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe081840301815291905261048560608c018c611247565b6040516020016104999594939291906112fb565b60405160208183030381529060405290506104f4565b6104bc6020890189611247565b8080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509293505050505b6040517fffffffffffffffffffffffffffffffffffffffff000000000000000000000000606086901b16602082015261054d90603401604051602081830303815290604052805190602001208280519060200120610b23565b925050509550959350505050565b60008061056b8787878787610850565b90506105866105806060890160408a0161118c565b82610b30565b915060008073ffffffffffffffffffffffffffffffffffffffff841660208a01356105b460608c018c611247565b6040516105c29291906112ac565b60006040518083038185875af1925050503d80600081146105ff576040519150601f19603f3d011682016040523d82523d6000602084013e610604565b606091505b50915091508161064b57806040517f4364b6ee000000000000000000000000000000000000000000000000000000008152600401610642919061132f565b60405180910390fd5b50505095945050505050565b60006106b961066c604085016020860161118c565b6040517fffffffffffffffffffffffffffffffffffffffff000000000000000000000000606086901b16602082015260340160405160208183030381529060405280519060200120610b30565b905060006106ca6040850185611247565b8080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509293506107129250505060808501606086016112bc565b1561079a576040805173ffffffffffffffffffffffffffffffffffffffff85166020820152829101604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08184030181529190526107756080870187611247565b6040516020016107889493929190611380565b60405160208183030381529060405290505b6000808373ffffffffffffffffffffffffffffffffffffffff168660000135846040516107c791906113bc565b60006040518083038185875af1925050503d8060008114610804576040519150601f19603f3d011682016040523d82523d6000602084013e610809565b606091505b50915091508161084757806040517f9654a854000000000000000000000000000000000000000000000000000000008152600401610642919061132f565b50505092915050565b60008535610864604087016020880161118c565b6108716040880188611247565b61088160808a0160608b016112bc565b61088e60808b018b611247565b8a8a8a6040516020016108aa9a999897969594939291906113d8565b60405160208183030381529060405280519060200120905095945050505050565b6040513060388201526f5af43d82803e903d91602b57fd5bf3ff602482015260148101839052733d602d80600a3d3981f3363d3d373d3d3d363d738152605881018290526037600c820120607882015260556043909101206000905b90505b92915050565b6000806109408787878787610ada565b905061099260208801358261095860408b018b611247565b8080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250610bf492505050565b979650505050505050565b6000806109ad6020850185611247565b8080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509293506109f59250505060608501604086016112bc565b15610a7d576040805173ffffffffffffffffffffffffffffffffffffffff85166020820152829101604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0818403018152919052610a586060870187611247565b604051602001610a6b9493929190611380565b60405160208183030381529060405290505b6040517fffffffffffffffffffffffffffffffffffffffff000000000000000000000000606085901b166020820152610ad2908535906034016040516020818303038152906040528051906020012083610bf4565b949350505050565b60008535610aeb6020870187611247565b610afb6060890160408a016112bc565b610b0860608a018a611247565b8989896040516020016108aa99989796959493929190611459565b6000610927838330610d5a565b6000763d602d80600a3d3981f3363d3d373d3d3d363d730000008360601b60e81c176000526e5af43d82803e903d91602b57fd5bf38360781b1760205281603760096000f5905073ffffffffffffffffffffffffffffffffffffffff811661092a576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f455243313136373a2063726561746532206661696c65640000000000000000006044820152606401610642565b600083471015610c60576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601d60248201527f437265617465323a20696e73756666696369656e742062616c616e63650000006044820152606401610642565b8151600003610ccb576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820181905260248201527f437265617465323a2062797465636f6465206c656e677468206973207a65726f6044820152606401610642565b8282516020840186f5905073ffffffffffffffffffffffffffffffffffffffff8116610d53576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601960248201527f437265617465323a204661696c6564206f6e206465706c6f79000000000000006044820152606401610642565b9392505050565b6000604051836040820152846020820152828152600b8101905060ff815360559020949350505050565b600060808284031215610d9657600080fd5b50919050565b803573ffffffffffffffffffffffffffffffffffffffff81168114610dc057600080fd5b919050565b60008083601f840112610dd757600080fd5b50813567ffffffffffffffff811115610def57600080fd5b602083019150836020828501011115610e0757600080fd5b9250929050565b600080600080600060808688031215610e2657600080fd5b853567ffffffffffffffff80821115610e3e57600080fd5b610e4a89838a01610d84565b96506020880135915080821115610e6057600080fd5b9087019060a0828a031215610e7457600080fd5b819550610e8360408901610d9c565b94506060880135915080821115610e9957600080fd5b50610ea688828901610dc5565b969995985093965092949392505050565b600080600080600060808688031215610ecf57600080fd5b853567ffffffffffffffff80821115610ee757600080fd5b908701906060828a031215610efb57600080fd5b90955060208701359080821115610f1157600080fd5b610f1d89838a01610d84565b9550610e8360408901610d9c565b8082018082111561092a577f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b60008083357fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1843603018112610f9a57600080fd5b830160208101925035905067ffffffffffffffff811115610fba57600080fd5b803603821315610e0757600080fd5b8183528181602085013750600060208284010152600060207fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0601f840116840101905092915050565b80358015158114610dc057600080fd5b6080815285356080820152602086013560a0820152600061104560408801610d9c565b73ffffffffffffffffffffffffffffffffffffffff80821660c085015261106f60608a018a610f65565b9250608060e086015261108761010086018483610fc9565b925050838203602085015287358252806110a360208a01610d9c565b166020830152506110b76040880188610f65565b60a060408401526110cc60a084018284610fc9565b9150506110db60608901611012565b151560608301526110ef6080890189610f65565b8383036080850152611102838284610fc9565b9350505050611129604084018773ffffffffffffffffffffffffffffffffffffffff169052565b828103606084015261113c818587610fc9565b98975050505050505050565b600073ffffffffffffffffffffffffffffffffffffffff808716835280861660208401525060606040830152611182606083018486610fc9565b9695505050505050565b60006020828403121561119e57600080fd5b61092782610d9c565b6080815285356080820152602086013560a082015260006111cb6040880188610f65565b606060c08501526111e060e085018284610fc9565b9150508281036020840152863581526111fc6020880188610f65565b60806020840152611211608084018284610fc9565b91505061122060408901611012565b151560408301526112346060890189610f65565b8383036060850152611102838284610fc9565b60008083357fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe184360301811261127c57600080fd5b83018035915067ffffffffffffffff82111561129757600080fd5b602001915036819003821315610e0757600080fd5b8183823760009101908152919050565b6000602082840312156112ce57600080fd5b61092782611012565b60005b838110156112f25781810151838201526020016112da565b50506000910152565b848682376000858201600081528551611318818360208a016112d7565b018385823760009301928352509095945050505050565b602081526000825180602084015261134e8160408501602087016112d7565b601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0169190910160400192915050565b60008551611392818460208a016112d7565b8551908301906113a6818360208a016112d7565b0183858237600093019283525090949350505050565b600082516113ce8184602087016112d7565b9190910192915050565b8a8152600073ffffffffffffffffffffffffffffffffffffffff808c16602084015260e0604084015261140f60e084018b8d610fc9565b8915156060850152838103608085015261142a81898b610fc9565b905081871660a085015283810360c0850152611447818688610fc9565b9e9d5050505050505050505050505050565b89815260c06020820152600061147360c083018a8c610fc9565b8815156040840152828103606084015261148e81888a610fc9565b905073ffffffffffffffffffffffffffffffffffffffff8616608084015282810360a08401526114bf818587610fc9565b9c9b50505050505050505050505056fea2646970667358221220ad82df5e4e9383affce64f7d414008d752bcf781ee9be463f972c041ddac530564736f6c63430008110033`

##### UniversalFactory Source Code

This is an exact copy of the code of the [LSP23 LinkedContractsFactory smart contract].

- The source code is generated with `0.8.17` compiler version and with `9999999` optimization runs.
- The imported contracts are part of the `4.9.2` version of the `@openzeppelin/contracts` package.
- Navigate to [lsp-smart-contract](https://github.com/lukso-network/lsp-smart-contracts) repo and checkout to `b8eca3c5696acf85239130ef67edec9e8c134bfa` commit to obtain the exact copy of the code, change the compiler settings in `hardhat.config.ts` and compile to produce the same bytecode.

<details>
<summary>Click to Expand</summary>
<pre>

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { IPostDeploymentModule } from "./IPostDeploymentModule.sol";
import { ILSP23LinkedContractsFactory } from "./ILSP23LinkedContractsFactory.sol";
import { InvalidValueSum, PrimaryContractProxyInitFailureError, SecondaryContractProxyInitFailureError } from "./LSP23Errors.sol";

contract LSP23LinkedContractsFactory is ILSP23LinkedContractsFactory {
  /**
   * @inheritdoc ILSP23LinkedContractsFactory
   */
  function deployContracts(
    PrimaryContractDeployment calldata primaryContractDeployment,
    SecondaryContractDeployment calldata secondaryContractDeployment,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
  )
    public
    payable
    returns (address primaryContractAddress, address secondaryContractAddress)
  {
    /* check that the msg.value is equal to the sum of the values of the primary and secondary contracts */
    if (
      msg.value !=
      primaryContractDeployment.fundingAmount +
        secondaryContractDeployment.fundingAmount
    ) {
      revert InvalidValueSum();
    }

    primaryContractAddress = _deployPrimaryContract(
      primaryContractDeployment,
      secondaryContractDeployment,
      postDeploymentModule,
      postDeploymentModuleCalldata
    );

    secondaryContractAddress = _deploySecondaryContract(
      secondaryContractDeployment,
      primaryContractAddress
    );

    emit DeployedContracts(
      primaryContractAddress,
      secondaryContractAddress,
      primaryContractDeployment,
      secondaryContractDeployment,
      postDeploymentModule,
      postDeploymentModuleCalldata
    );

    /* execute the post deployment logic in the postDeploymentModule if postDeploymentModule is not address(0) */
    if (postDeploymentModule != address(0)) {
      /* execute the post deployment module logic in the postDeploymentModule */
      IPostDeploymentModule(postDeploymentModule).executePostDeployment(
        primaryContractAddress,
        secondaryContractAddress,
        postDeploymentModuleCalldata
      );
    }
  }

  /**
   * @inheritdoc ILSP23LinkedContractsFactory
   */
  function deployERC1167Proxies(
    PrimaryContractDeploymentInit calldata primaryContractDeploymentInit,
    SecondaryContractDeploymentInit calldata secondaryContractDeploymentInit,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
  )
    public
    payable
    returns (address primaryContractAddress, address secondaryContractAddress)
  {
    /* check that the msg.value is equal to the sum of the values of the primary and secondary contracts */
    if (
      msg.value !=
      primaryContractDeploymentInit.fundingAmount +
        secondaryContractDeploymentInit.fundingAmount
    ) {
      revert InvalidValueSum();
    }

    /* deploy the primary contract proxy with the primaryContractGeneratedSalt */
    primaryContractAddress = _deployAndInitializePrimaryContractProxy(
      primaryContractDeploymentInit,
      secondaryContractDeploymentInit,
      postDeploymentModule,
      postDeploymentModuleCalldata
    );

    /* deploy the secondary contract proxy */
    secondaryContractAddress = _deployAndInitializeSecondaryContractProxy(
      secondaryContractDeploymentInit,
      primaryContractAddress
    );

    emit DeployedERC1167Proxies(
      primaryContractAddress,
      secondaryContractAddress,
      primaryContractDeploymentInit,
      secondaryContractDeploymentInit,
      postDeploymentModule,
      postDeploymentModuleCalldata
    );

    /* execute the post deployment logic in the postDeploymentModule if postDeploymentModule is not address(0) */
    if (postDeploymentModule != address(0)) {
      /* execute the post deployment logic in the postDeploymentModule */
      IPostDeploymentModule(postDeploymentModule).executePostDeployment(
        primaryContractAddress,
        secondaryContractAddress,
        postDeploymentModuleCalldata
      );
    }
  }

  /**
   * @inheritdoc ILSP23LinkedContractsFactory
   */
  function computeAddresses(
    PrimaryContractDeployment calldata primaryContractDeployment,
    SecondaryContractDeployment calldata secondaryContractDeployment,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
  )
    public
    view
    returns (address primaryContractAddress, address secondaryContractAddress)
  {
    bytes32 primaryContractGeneratedSalt = _generatePrimaryContractSalt(
      primaryContractDeployment,
      secondaryContractDeployment,
      postDeploymentModule,
      postDeploymentModuleCalldata
    );

    primaryContractAddress = Create2.computeAddress(
      primaryContractGeneratedSalt,
      keccak256(primaryContractDeployment.creationBytecode)
    );

    bytes memory secondaryContractByteCodeWithAllParams;
    if (secondaryContractDeployment.addPrimaryContractAddress) {
      secondaryContractByteCodeWithAllParams = abi.encodePacked(
        secondaryContractDeployment.creationBytecode,
        abi.encode(primaryContractAddress),
        secondaryContractDeployment.extraConstructorParams
      );
    } else {
      secondaryContractByteCodeWithAllParams = secondaryContractDeployment
        .creationBytecode;
    }

    secondaryContractAddress = Create2.computeAddress(
      keccak256(abi.encodePacked(primaryContractAddress)),
      keccak256(secondaryContractByteCodeWithAllParams)
    );
  }

  /**
   * @inheritdoc ILSP23LinkedContractsFactory
   */
  function computeERC1167Addresses(
    PrimaryContractDeploymentInit calldata primaryContractDeploymentInit,
    SecondaryContractDeploymentInit calldata secondaryContractDeploymentInit,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
  )
    public
    view
    returns (address primaryContractAddress, address secondaryContractAddress)
  {
    bytes32 primaryContractGeneratedSalt = _generatePrimaryContractProxySalt(
      primaryContractDeploymentInit,
      secondaryContractDeploymentInit,
      postDeploymentModule,
      postDeploymentModuleCalldata
    );

    primaryContractAddress = Clones.predictDeterministicAddress(
      primaryContractDeploymentInit.implementationContract,
      primaryContractGeneratedSalt
    );

    secondaryContractAddress = Clones.predictDeterministicAddress(
      secondaryContractDeploymentInit.implementationContract,
      keccak256(abi.encodePacked(primaryContractAddress))
    );
  }

  function _deployPrimaryContract(
    PrimaryContractDeployment calldata primaryContractDeployment,
    SecondaryContractDeployment calldata secondaryContractDeployment,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
  ) internal returns (address primaryContractAddress) {
    bytes32 primaryContractGeneratedSalt = _generatePrimaryContractSalt(
      primaryContractDeployment,
      secondaryContractDeployment,
      postDeploymentModule,
      postDeploymentModuleCalldata
    );

    /* deploy the primary contract */
    primaryContractAddress = Create2.deploy(
      primaryContractDeployment.fundingAmount,
      primaryContractGeneratedSalt,
      primaryContractDeployment.creationBytecode
    );
  }

  function _deploySecondaryContract(
    SecondaryContractDeployment calldata secondaryContractDeployment,
    address primaryContractAddress
  ) internal returns (address secondaryContractAddress) {
    /**
     * If `addPrimaryContractAddress` is `true`, the following will be appended to the constructor params:
     * - The primary contract address
     * - `extraConstructorParams`
     */
    bytes memory secondaryContractByteCode = secondaryContractDeployment
      .creationBytecode;

    if (secondaryContractDeployment.addPrimaryContractAddress) {
      secondaryContractByteCode = abi.encodePacked(
        secondaryContractByteCode,
        abi.encode(primaryContractAddress),
        secondaryContractDeployment.extraConstructorParams
      );
    }

    secondaryContractAddress = Create2.deploy(
      secondaryContractDeployment.fundingAmount,
      keccak256(abi.encodePacked(primaryContractAddress)),
      secondaryContractByteCode
    );
  }

  function _deployAndInitializePrimaryContractProxy(
    PrimaryContractDeploymentInit calldata primaryContractDeploymentInit,
    SecondaryContractDeploymentInit calldata secondaryContractDeploymentInit,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
  ) internal returns (address primaryContractAddress) {
    bytes32 primaryContractGeneratedSalt = _generatePrimaryContractProxySalt(
      primaryContractDeploymentInit,
      secondaryContractDeploymentInit,
      postDeploymentModule,
      postDeploymentModuleCalldata
    );

    /* deploy the primary contract proxy with the primaryContractGeneratedSalt */
    primaryContractAddress = Clones.cloneDeterministic(
      primaryContractDeploymentInit.implementationContract,
      primaryContractGeneratedSalt
    );

    /* initialize the primary contract proxy */
    (bool success, bytes memory returnedData) = primaryContractAddress.call{
      value: primaryContractDeploymentInit.fundingAmount
    }(primaryContractDeploymentInit.initializationCalldata);
    if (!success) {
      revert PrimaryContractProxyInitFailureError(returnedData);
    }
  }

  function _deployAndInitializeSecondaryContractProxy(
    SecondaryContractDeploymentInit calldata secondaryContractDeploymentInit,
    address primaryContractAddress
  ) internal returns (address secondaryContractAddress) {
    /* deploy the secondary contract proxy with the primaryContractGeneratedSalt */
    secondaryContractAddress = Clones.cloneDeterministic(
      secondaryContractDeploymentInit.implementationContract,
      keccak256(abi.encodePacked(primaryContractAddress))
    );

    /**
     * If `addPrimaryContractAddress` is `true`, the following will be appended to the `initializationCalldata`:
     * - The primary contract address
     * - `extraInitializationBytes`
     */
    bytes memory secondaryInitializationBytes = secondaryContractDeploymentInit
      .initializationCalldata;

    if (secondaryContractDeploymentInit.addPrimaryContractAddress) {
      secondaryInitializationBytes = abi.encodePacked(
        secondaryInitializationBytes,
        abi.encode(primaryContractAddress),
        secondaryContractDeploymentInit.extraInitializationParams
      );
    }

    /* initialize the primary contract proxy */
    (bool success, bytes memory returnedData) = secondaryContractAddress.call{
      value: secondaryContractDeploymentInit.fundingAmount
    }(secondaryInitializationBytes);
    if (!success) {
      revert SecondaryContractProxyInitFailureError(returnedData);
    }
  }

  function _generatePrimaryContractSalt(
    PrimaryContractDeployment calldata primaryContractDeployment,
    SecondaryContractDeployment calldata secondaryContractDeployment,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
  ) internal pure virtual returns (bytes32 primaryContractGeneratedSalt) {
    /* generate salt for the primary contract
     *  the salt is generated by hashing the following elements:
     *   - the salt
     *   - the secondary contract bytecode
     *   - the secondary addPrimaryContractAddress boolean
     *   - the secondary extraConstructorParams
     *   - the postDeploymentModule address
     *   - the postDeploymentModuleCalldata
     *
     */
    primaryContractGeneratedSalt = keccak256(
      abi.encode(
        primaryContractDeployment.salt,
        secondaryContractDeployment.creationBytecode,
        secondaryContractDeployment.addPrimaryContractAddress,
        secondaryContractDeployment.extraConstructorParams,
        postDeploymentModule,
        postDeploymentModuleCalldata
      )
    );
  }

  function _generatePrimaryContractProxySalt(
    PrimaryContractDeploymentInit calldata primaryContractDeploymentInit,
    SecondaryContractDeploymentInit calldata secondaryContractDeploymentInit,
    address postDeploymentModule,
    bytes calldata postDeploymentModuleCalldata
  ) internal pure virtual returns (bytes32 primaryContractProxyGeneratedSalt) {
    /**
     * Generate the salt for the primary contract
     * The salt is generated by hashing the following elements:
     *  - the salt
     *  - the secondary implementation contract address
     *  - the secondary contract initialization calldata
     *  - the secondary contract addPrimaryContractAddress boolean
     *  - the secondary contract extra initialization params (if any)
     *  - the postDeploymentModule address
     *  - the callda to the post deployment module
     *
     */
    primaryContractProxyGeneratedSalt = keccak256(
      abi.encode(
        primaryContractDeploymentInit.salt,
        secondaryContractDeploymentInit.implementationContract,
        secondaryContractDeploymentInit.initializationCalldata,
        secondaryContractDeploymentInit.addPrimaryContractAddress,
        secondaryContractDeploymentInit.extraInitializationParams,
        postDeploymentModule,
        postDeploymentModuleCalldata
      )
    );
  }
}
```

</pre>
</details>


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

