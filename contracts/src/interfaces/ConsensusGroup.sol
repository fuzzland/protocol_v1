// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IConsensusGroup {
    event Nay(uint256 nftId);
    event Aye(uint256 nftId);

    event NayDone(uint256 nftId);
    event AyeDone(uint256 nftId);

    function VoteAye(uint256 nftId) external;
    function VoteNay(uint256 nftId) external;
    function VotePostProcessAye(uint256 nftId) external;
    function VotePostProcessNay(uint256 nftId) external;
}