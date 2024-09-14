// SPDX-License-Identifier: APACHE 2.0
pragma solidity 0.8.27;

interface ILSP27Registry {
  /**
   * @dev The registry MUST emit the LSP27ProfileCreated event upon successful profile creation.
   */
  event LSP27ProfileCreated(
    address profile,
    address indexed implementation,
    bytes32 salt,
    uint256 chainId,
    address indexed tokenContract,
    uint256 indexed tokenId
  );

  /**
   * @dev The registry MUST revert with ProfileCreationFailed error if the create2 operation fails.
   */
  error ProfileCreationFailed();

  /**
   * @dev Creates a token bound profile for a non-fungible token.
   *
   * If profile has already been created, returns the profile address without calling create2.
   *
   * Emits LSP27ProfileCreated event.
   *
   * @return profile The address of the token bound profile
   */
  function createProfile(
    address implementation,
    bytes32 salt,
    uint256 chainId,
    address tokenContract,
    uint256 tokenId
  ) external returns (address profile);

  /**
   * @dev Returns the computed token bound profile address for a non-fungible token.
   *
   * @return profile The address of the token bound profile
   */
  function profile(
    address implementation,
    bytes32 salt,
    uint256 chainId,
    address tokenContract,
    uint256 tokenId
  ) external view returns (address profile);

  /**
   * @dev Retrieve the Universal Profile associated with an LSP8 token
   *
   * @return profile The address of the token bound profile
   * */
  function getProfile(
    address tokenContract,
    bytes32 tokenId
  ) external view returns (address profile);
}

contract LSP27Registry is ILSP27Registry {
  // Mapping from (LSP8 token contract => token ID) to Universal Profile contract
  mapping(address token => mapping(bytes32 id => address profile))
    public s_profiles;

  function createProfile(
    address implementation,
    bytes32 salt,
    uint256 chainId,
    address tokenContract,
    uint256 tokenId
  ) external returns (address profile) {}

  function profile(
    address implementation,
    bytes32 salt,
    uint256 chainId,
    address tokenContract,
    uint256 tokenId
  ) external view returns (address) {
    // Construct the bytecode for UniversalProfile with constructor args (tokenContract and tokenId)
    bytes memory bytecode = abi.encodePacked(
      type(UniversalProfile).creationCode, // The contract's bytecode
      abi.encode(tokenContract, tokenId) // Constructor params (tokenContract, tokenId)
    );

    // Compute the salt for CREATE2, using chainId, tokenContract, tokenId, and user-provided salt
    bytes32 saltHash = keccak256(
      abi.encodePacked(chainId, tokenContract, tokenId, salt)
    );

    // Compute the CREATE2 address
    bytes32 hash = keccak256(
      abi.encodePacked(
        bytes1(0xff), // The CREATE2 prefix
        implementation, // The address that will deploy the contract
        saltHash, // The salt value
        keccak256(bytecode) // The bytecode hash (contract + constructor params)
      )
    );

    // Return the computed address (converted to address format)
    return address(uint160(uint256(hash)));
  }

  function getProfile(
    address tokenContract,
    bytes32 tokenId
  ) external view returns (address profile) {
    return s_profiles[tokenContract][tokenId];
  }
}
