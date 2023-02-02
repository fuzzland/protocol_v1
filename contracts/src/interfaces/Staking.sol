// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IStaking {
    event Staked(address staker);
    event Unstaked(address staker);
    event ReducedStake(address staker);

    function Stake(uint256 amount) external;
    function Unstake(uint256 amt) external;
    function UnstakeAll() external;

    function SetDefaultScore(uint256 score) external;
    function SetMinStakeAmount(uint256 amt) external;
    function SetCoolDownBlocks(uint256 blocks) external;
    function SetSlashAmt(uint256 amt) external;

    function StakeAmount(address account) external view returns (uint256);
    function IsStaker(address account) external view returns (bool);
    function IsVoteReady(uint256 nftId) external view returns (bool);
}