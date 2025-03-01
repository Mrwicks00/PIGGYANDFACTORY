//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "./PiggyCA.sol";

contract PiggyFactory {
    address public developerAddress;
    uint256 public piggyCount;
    error youHaveFailed();

    constructor() {
        developerAddress = msg.sender;
    }

    mapping(address => address[]) public deployedContracts;

    function getPiggyByteCode(
        string memory _savingPurpose,
        uint256 _endTime
    ) external view returns (bytes memory) {
        bytes memory _bytecode = type(PiggyCA).creationCode;

        return
            abi.encodePacked(
                _bytecode,
                abi.encode(
                    _savingPurpose,
                    _endTime,
                    msg.sender,
                    developerAddress
                )
            );
    }

    function createPiggy(bytes memory _bytecode) external returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, piggyCount));
        piggyCount++;

        address piggyAddress;
        assembly {
            piggyAddress := create2(
                0,
                add(_bytecode, 0x20),
                mload(_bytecode),
                salt
            )
            if iszero(piggyAddress) {
                revert(0, 0)
            }
        }

        deployedContracts[msg.sender].push(piggyAddress);
        return piggyAddress;
    }

    // // 🔍 Predict the address of a PiggyCA contract before deployment
    // function predictPiggyAddress(bytes memory _bytecode) external view returns (address) {
    //     bytes32 salt = keccak256(abi.encodePacked(msg.sender, piggyCount));
    //     bytes32 bytecodeHash = keccak256(_bytecode);
    //     bytes32 data = keccak256(abi.encodePacked(
    //         bytes1(0xff),       // Prefix for create2
    //         address(this),      // Deployer address (factory)
    //         salt,               // Salt
    //         bytecodeHash        // Bytecode hash
    //     ));

    //     // Predicted address
    //     return address(uint160(uint256(data)));
    // }

    function getUserDeployedContracts(
        address user
    ) external view returns (address[] memory) {
        return deployedContracts[user];
    }
}
