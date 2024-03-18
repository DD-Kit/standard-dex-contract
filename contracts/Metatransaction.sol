// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaTransactionForwarder is Ownable {
    using ECDSA for bytes32;

    mapping(address => bool) public whitelist;

    function setWhitelisted(address account, bool status) external onlyOwner {
        whitelist[account] = status;
    }

    function forwardMetaTransaction(
        address signer,
        bytes calldata signature,
        address to,
        bytes calldata data
    ) external {
        require(whitelist[signer], "Signer is not whitelisted");

        bytes32 hash = keccak256(abi.encodePacked(signer, to, data));
        address recoveredSigner = hash.toEthSignedMessageHash().recover(signature);

        require(recoveredSigner == signer, "Invalid signature");

        (bool success, ) = to.call(data);
        require(success, "Forwarding transaction failed");
    }
}