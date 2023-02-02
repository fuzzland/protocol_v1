// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/vVulns.sol";
import "../src/uVulns.sol";
import "../src/Protocol.sol";
import "forge-std/console.sol";
import "../src/interfaces/ProjectDeployer.sol";

contract StakeTest is Test {
    IFuzzToken token;
    Protocol protocol;
    function setUp() public {
        token = new FuzzToken(10000000, 18);
        address deployer = address(this);
        protocol = new Protocol(address(token));
        for (uint160 i = 0; i < 6; i++) {
            token.transfer(address(i), 10000e18);
            vm.prank(address(i));
            token.approve(address(protocol), 1200e18);
            vm.stopPrank();
        }
    }

    function testE2E_def() public {
        vm.prank(address(1));
        protocol.Stake(1000e18);
        vm.stopPrank();
    }
}
