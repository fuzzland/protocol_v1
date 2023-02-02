// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
enum ProjectStatus {
    NORMAL, DESTROYED
}
interface IFuzzProjectDeployer {
    event ProjectDeployed(uint256 projectId);
    event RewardUpdated(uint256 projectId, string newSpec);
    event ProjectDepositIncreased(uint256 projectId, uint256 newAmount);
    event ProjectDepositDecreased(uint256 projectId, uint256 newAmount);
    event ProjectDestroyed(uint256 projectId);

    event SplittingsAdded(uint256 projectId);
    event SplittingDestroyed(uint256 projectId, uint32 splittingId);

    function AddProject(string memory ipfsHash, uint256 initialDeposit, bool isImplicit, string memory initialTestcases, string memory rewardSplittingSpec, string memory projectName)    external returns (uint256 projectId);
    function UpdateRewardSpec(uint256 projectId, string memory rewardSplittingSpec) external;
    function WithdrawDeposit(uint256 projectId, uint256 amount) external;
    function AddDeposit(uint256 projectId, uint256 amount) external;
    function GetProjectInfo(uint256 projectId) external view returns (string memory ipfsHash, uint256 reward, uint256 base_reward, bool isImplicit, address owner, string memory splittings, ProjectStatus status, string memory projectName);
    function GetProjectCount() external view returns (uint256);
    function IsOracleFreezed(uint256 projectId, uint256 oracleId) external view returns (bool);
//
//    function SetSplitting(uint256 projectId, uint256[] memory splittings) external;
//    function RemoveSplitting(uint256 projectId, uint32 splittingId) external;
//    function RemoveSplittingBulk(uint256 projectId, uint32[] memory splittingIds) external;
//    function ListSplitting(uint256 projectId) external view returns (uint256[] memory results);


    function SetMinDeposit(uint256 minDeposit) external ;
    function SetMaxDeposit(uint256 minDeposit) external ;
    function SetToken(address token) external ;
    function SetNFT(address vVuln, address uVuln) external;
}