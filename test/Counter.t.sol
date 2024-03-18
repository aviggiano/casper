// SPDX-License-Identifier: UNLICSENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Ghosts} from "../src/Ghosts.sol";

contract CounterTest is Test, Ghosts {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
        _ghost("number", address(counter), abi.encodeCall(counter.number, ()));
    }

    function test_Increment() public ghosted("number") {
        _call(address(counter), abi.encodeCall(counter.increment, ()));
        assertEq(_afterUint256("number"), 1);
    }

    function testFuzz_SetNumber(uint256 x) public ghosted("number") {
        _call(address(counter), abi.encodeCall(counter.setNumber, (x)));
        assertEq(_afterUint256("number"), x);
    }
}
