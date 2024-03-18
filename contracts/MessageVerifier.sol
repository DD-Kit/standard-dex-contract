// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MessageVerifier {
    function verifyMessage(
        bytes32 messageHash,
        bytes memory signature
    ) external pure returns (address) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, messageHash));
        address signer =  address(ecrecover(prefixedHashMessage, v, r, s));

        return signer;
    }
}