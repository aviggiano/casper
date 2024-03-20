// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Ghosts {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct Ghost {
        bytes32 b;
        bytes32 a;
        address target;
        bytes data;
    }

    mapping(bytes32 => Ghost) internal _ghosts;
    EnumerableSet.Bytes32Set internal _keys;
    bytes32 internal _ghosted;

    modifier ghosted(bytes32 key) {
        _ghosted = key;
        _;
        _ghosted = bytes32(0);
    }

    function __snapshot(bytes32 key) internal returns (bytes32) {
        Ghost memory g = _ghosts[key];
        (bool success, bytes memory returnData) = g.target.call(g.data);
        Address.verifyCallResult(success, returnData);
        return bytes32(returnData);
    }

    function _ghost(bytes32 key, address target, bytes memory data) public {
        _ghosts[key] = Ghost({target: target, data: data, b: bytes32(0), a: bytes32(0)});
        _keys.add(key);
    }

    function _ghost(bytes32 key, address target, function() external view returns(uint256) fn) public {
        _ghosts[key] = Ghost({target: target, data: abi.encodeCall(fn, ()), b: bytes32(0), a: bytes32(0)});
        _keys.add(key);
    }

    function _call(address target, bytes memory data) internal {
        _ghosts[_ghosted].b = __snapshot(_ghosted);
        (bool success, bytes memory returnData) = target.call(data);
        Address.verifyCallResult(success, returnData);
        _ghosts[_ghosted].a = __snapshot(_ghosted);
    }

    function _before(bytes32 key) internal view returns (uint256) {
        return uint256(_ghosts[key].b);
    }

    function _after(bytes32 key) internal view returns (uint256) {
        return uint256(_ghosts[key].a);
    }
}
