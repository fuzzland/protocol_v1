// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/vVulns.sol";
import "../src/uVulns.sol";
import "../src/Protocol.sol";
import "forge-std/console.sol";
import "../src/interfaces/ProjectDeployer.sol";

contract TokenTest is Test {
    IFuzzToken token;
    Protocol protocol;
    VulnsUnverified uV;
    VulnsVerified vV;
    address deployer;
    uint256 project_id;
    uint256 nft_id;
    function setUp() public {
        token = new FuzzToken(10000000, 18);
        deployer = address(this);
        protocol = new Protocol(address(token));
        for (uint160 i = 0; i < 6; i++) {
            token.transfer(address(i), 10000e18);
            vm.prank(address(i));
            token.approve(address(protocol), 1200e18);
            vm.stopPrank();
        }
        uV = new VulnsUnverified(address(protocol));
        vV = new VulnsVerified(address(protocol));

        protocol.SetNFT(address(vV), address(uV));
    }

    function project_deployer() private {
        // user 1 - project deployer
        vm.prank(address(1));

        // add project

        project_id = protocol.AddProject("testhash", 30e18, true, "testcase", "test", "test");

        (string memory ipfsHash, uint256 reward, uint256 breward, bool isImplicit, address owner, string memory splittings, ProjectStatus status, string memory pn) =
            protocol.GetProjectInfo(project_id);
        assertEq(project_id, 0, "not match");
        assertEq(reward, 30e18, "not match");
        assertEq(owner, address(1), "not match");

        vm.prank(address(1));
        protocol.AddDeposit(project_id, 10e18);

        (string memory ipfsHash2, uint256 reward2,uint256 breward2,  bool isImplicit2, address owner2, string memory splittings2, ProjectStatus status2, string memory pn2) =
            protocol.GetProjectInfo(project_id);
        assertEq(reward2, 40e18, "not match");

        vm.stopPrank();
    }

    function miner() private {
        // user 2
        vm.prank(address(2));

        // mint unverified nft
        nft_id = uV.mint(address(2), "testhash2", project_id, 12e18, 1);

        vm.stopPrank();
    }

    function validator(address v) private {
        vm.startPrank(v);
        // stake
        protocol.Stake(1200e18);

        // vote aye
        protocol.VoteAye(nft_id);

        // vote post process
        vm.stopPrank();
    }

    function testE2E_def() public {
        project_deployer();

        miner();

        for (uint160 i = 3; i < 6; i++) {
            validator(address(i));
        }

        protocol.VotePostProcessAye(nft_id);

        assertEq(token.balanceOf(address(2)),
            (10000e18 + 12e18 - 12e18 / 10), "balance not match"
        );
        for (uint160 i = 3; i < 6; i++) {
            assertEq(token.balanceOf(address(i)),
                (10000e18 - 1200e18 + 12e18 / 10 / 3), "balance not match"
            );
        }

        (string memory ipfsHash, uint256 reward,  uint256 breward, bool isImplicit, address owner, string memory splittings, ProjectStatus status, string memory pn) =
        protocol.GetProjectInfo(project_id);

        assertEq(reward, 40e18 - 12e18, "not match");

    }
}
