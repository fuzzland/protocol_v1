pragma solidity ^0.8.13;

import "./interfaces/Token.sol";
import "./interfaces/ProjectDeployer.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "./interfaces/Vulns.sol";
import "./interfaces/ConsensusGroup.sol";
import "./interfaces/Staking.sol";

struct ProjectInfo {
    string ipfsHash;
    uint256 reward;
    uint256 base_reward;
    bool isImplicit;
    address owner;
    ProjectStatus status;
    string projectName;
}


contract Protocol is IFuzzProjectDeployer, IConsensusGroup, IStaking, Ownable, Pausable{
    IFuzzToken public Token;
    ProjectInfo[] public Projects;
    mapping(uint256 => uint256[]) ProjectSplittings;
    mapping(uint256 => uint256[]) FreezeOracle;
    uint256 public MIN_DEPOSIT = 20e18;
    mapping(uint256 => string[]) Testcases;
    mapping(uint256 => string) RewardSplittingSpec;
    uint256 public MAX_DEPOSIT = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;


    uint256 internal SPLITTING_MASK_STATUS = 0x8000000000000000000000000000000000000000000000000000000000000000;
    uint256 internal SPLITTING_MASK_EXITCODE = 0x7f80000000000000000000000000000000000000000000000000000000000000;
    uint256 internal SPLITTING_MASK_EXITCODE_OFFSET = 247;
    uint256 internal SPLITTING_MASK_AMOUNT = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;


    /// Staking

    mapping(address => uint256) Staker;
    uint256 StakerCount;
    mapping(address => uint256) StakeTime;
    mapping(address => uint256) Score;
    address[] Stakers;

    uint256 public DEFAULT_SCORE = 1000;
    uint256 MIN_STAKE_AMOUNT = 1000e18;
    uint256 COOL_DOWN_BLOCKS = 400000; // around 14 daya for bsc
    uint SLASH_AMOUNT = 1;

    IVulnNFT vVulnNFT;
    IVulnNFT uVulnNFT;

    constructor(address _TokenAddress)  {
        Token = IFuzzToken(_TokenAddress);
    }

    function AddProject(string memory ipfsHash, uint256 initialDeposit, bool isImplicit, string memory initialTestcases, string memory rewardSplittingSpec, string memory projectName )
        external returns (uint256 projectId){
        require(Token.allowance(msg.sender, address(this)) >= initialDeposit, "no enough balance approved");
        require(initialDeposit >= MIN_DEPOSIT, "minimum deposit not reached");
        projectId = Projects.length;
        Projects.push(ProjectInfo(ipfsHash, initialDeposit, initialDeposit, isImplicit, msg.sender, ProjectStatus.NORMAL, projectName));
        Token.transferFrom(msg.sender, address(this), initialDeposit);

        Testcases[projectId].push(initialTestcases);
        RewardSplittingSpec[projectId] = rewardSplittingSpec;

        emit ProjectDeployed(projectId);
    }

    function UpdateRewardSpec(uint256 projectId, string memory rewardSplittingSpec) external {
        require(Projects[projectId].owner == msg.sender, "not your project");

        RewardSplittingSpec[projectId] = rewardSplittingSpec;

        emit RewardUpdated(projectId, rewardSplittingSpec);

    }

//    function SetSplitting(uint256 projectId, uint256[] memory splittings) external {
//        require(Projects[projectId].owner == msg.sender, "not your project");
//        uint256 totalAmount = 0;
//        for (uint32 i = 0; i < splittings.length; i++) {
//            totalAmount += splittings[i] & SPLITTING_MASK_AMOUNT;
//        }
//        require(totalAmount <= Projects[projectId].reward, "no enough reward");
//        ProjectSplittings[projectId] = splittings;
//        emit SplittingsAdded(projectId);
//    }
//
//    function RemoveSplitting(uint256 projectId, uint32 splittingId) external {
//        require(Projects[projectId].owner == msg.sender, "not your project");
//        ProjectSplittings[projectId][splittingId] |= SPLITTING_MASK_STATUS;
//        emit SplittingDestroyed(projectId, splittingId);
//    }
//
//    function RemoveSplittingBulk(uint256 projectId, uint32[] memory splittingIds) external {
//        require(Projects[projectId].owner == msg.sender, "not your project");
//        for (uint32 i = 0; i < splittingIds.length; i++) {
//            uint32 splittingId = splittingIds[i];
//            ProjectSplittings[projectId][splittingId] |= SPLITTING_MASK_STATUS;
//            emit SplittingDestroyed(projectId, splittingId);
//        }
//    }

//    struct SplittingInfo {
//        uint32 splittingId;
//        uint8 exitCode;
//        uint256 rewardAmount;
//    }
//
//    function ListSplitting(uint256 projectId) external view returns (uint256[] memory results){
////        SplittingInfo[] memory _result;
////        for (uint32 i = 0; i < ProjectSplittings[projectId].length; i++) {
////            uint256 splitting = ProjectSplittings[projectId][i];
////            if (splitting & SPLITTING_MASK_STATUS > 0) {
////                _result.push(SplittingInfo(i,
////                    uint8((splitting & SPLITTING_MASK_EXITCODE) >> SPLITTING_MASK_EXITCODE_OFFSET),
////                    splitting & SPLITTING_MASK_AMOUNT));
////            }
////        }
//        results = ProjectSplittings[projectId];
//    }

    function WithdrawDeposit(uint256 projectId, uint256 amount) external {
        require(Projects[projectId].owner == msg.sender, "not your project");
        require(Projects[projectId].reward >= amount, "project lack balance");
        require(Token.balanceOf(address(this)) >= amount, "contract has no enough Token");
        uint256 newReward = Projects[projectId].reward - amount;
        Projects[projectId].base_reward -= amount;
        Projects[projectId].reward = newReward;
        if (newReward < MIN_DEPOSIT) {
            Projects[projectId].status = ProjectStatus.DESTROYED;
            Token.transfer(msg.sender, Projects[projectId].reward);
            emit ProjectDestroyed(projectId);
        } else {
            Token.transfer(msg.sender, amount);
            emit ProjectDepositDecreased(projectId, newReward);
        }
    }

    function IsOracleFreezed(uint256 projectId, uint256 oracleId) external view returns (bool){
        uint256[] memory freeze_oracle = FreezeOracle[projectId];
        for (uint32 i = 0; i < freeze_oracle.length; i++) {
            if (freeze_oracle[i] == oracleId) {
                return true;
            }
        }
        return false;
    }

    function AddDeposit(uint256 projectId, uint256 amount) external {
        require(Projects[projectId].owner == msg.sender, "not your project");
        require(Token.allowance(msg.sender, address(this)) >= amount, "no enough balance approved");
        uint256 newReward = Projects[projectId].reward + amount;
        Projects[projectId].reward = newReward;
        Projects[projectId].base_reward += amount;
        Token.transferFrom(msg.sender, address(this), amount);
        emit ProjectDepositIncreased(projectId, newReward);
    }

    function GetProjectInfo(uint256 projectId) external view
        returns (string memory ipfsHash, uint256 reward, uint256 base_reward, bool isImplicit, address owner, string memory splittings, ProjectStatus status, string memory projectName){
        ipfsHash = Projects[projectId].ipfsHash;
        reward = Projects[projectId].reward;
        base_reward = Projects[projectId].base_reward;
        isImplicit = Projects[projectId].isImplicit;
        owner = Projects[projectId].owner;
        splittings = RewardSplittingSpec[projectId];
        status = Projects[projectId].status;
        projectName = Projects[projectId].projectName;
    }

    function GetProjectCount() external view
    returns (uint256){
        return Projects.length;
    }

    function SetMinDeposit(uint256 minDeposit) external onlyOwner {
        MIN_DEPOSIT = minDeposit;
    }

    function SetMaxDeposit(uint256 maxDeposit) external onlyOwner {
        MAX_DEPOSIT = maxDeposit;
    }

    function SetToken(address token) external onlyOwner {
        Token = IFuzzToken(token);
    }

    function SetNFT(address vVuln, address uVuln) external onlyOwner {
        vVulnNFT = IVulnNFT(vVuln);
        uVulnNFT = IVulnNFT(uVuln);
    }


    /// Staking
    function Stake(uint256 amount) external {
        require(Token.allowance(msg.sender, address(this)) >= amount, "no enough balance approved");
        require(amount >= MIN_STAKE_AMOUNT, "minimum stake not reached");
        Token.transferFrom(msg.sender, address(this), amount);
        StakerCount += 1;
        Staker[msg.sender] += amount;
        StakeTime[msg.sender] = block.number;
        Score[msg.sender] = DEFAULT_SCORE;
        emit Staked(msg.sender);
    }

    function StakeAmount(address account) external view returns (uint256) {
        return Staker[account];
    }

    function IsStaker(address account) external view returns (bool) {
        return Staker[account] >= MIN_STAKE_AMOUNT;
    }

    function Unstake(uint256 amt) external {
        require(block.number - StakeTime[msg.sender] >= COOL_DOWN_BLOCKS, "cool down");
        require(Token.balanceOf(address(this)) > amt, "out of balance");
        require(Staker[msg.sender] >= amt + MIN_STAKE_AMOUNT, "more than staked");
        Staker[msg.sender] -= amt;
        Token.transfer(msg.sender, amt * Score[msg.sender] / DEFAULT_SCORE);
        emit ReducedStake(msg.sender);
    }

    function UnstakeAll() external {
        require(block.number - StakeTime[msg.sender] >= COOL_DOWN_BLOCKS, "cool down");
        require(Token.balanceOf(address(this)) > Staker[msg.sender], "out of balance");
        StakerCount -= 1;
        Staker[msg.sender] = 0;
        _removeStaker(msg.sender);
        Token.transfer(msg.sender, Staker[msg.sender] * Score[msg.sender] / DEFAULT_SCORE);
        emit Unstaked(msg.sender);
    }

    function _decreaseScoreBatch(address[] memory stakers, uint256 slashScore) internal {
        uint i = 0;
        for (i = 0; i < stakers.length; i++) {
            if (Score[stakers[i]] < slashScore) {
                _removeStaker(stakers[i]);
            }
            Score[stakers[i]] -= slashScore;
        }
    }

    function _removeStaker(address toRemove) internal {
        Staker[toRemove] = 0;
        StakerCount -= 1;
    }

    function SetDefaultScore(uint256 score) external onlyOwner {
        DEFAULT_SCORE = score;
    }

    function SetMinStakeAmount(uint256 amt) external onlyOwner {
        MIN_STAKE_AMOUNT = amt;
    }

    function SetCoolDownBlocks(uint256 blocks) external onlyOwner {
        COOL_DOWN_BLOCKS = blocks;
    }

    function SetSlashAmt(uint256 amt) external onlyOwner {
        SLASH_AMOUNT = amt;
    }

    // Validators

    mapping(uint256 => address[]) votesAye;
    mapping(uint256 => address[]) votesNay;
    mapping(bytes32 => bool) voted;

    function VoteAye(uint256 nftId) external {
        require(Staker[msg.sender] >= MIN_STAKE_AMOUNT, "not a staker");
        bytes32 entropy = keccak256(abi.encodePacked(msg.sender, nftId));
        require(!voted[entropy], "already voted");
        voted[entropy] = true;
        votesAye[nftId].push(msg.sender);
        emit Aye(nftId);
    }

    function VoteNay(uint256 nftId) external {
        require(Staker[msg.sender] >= MIN_STAKE_AMOUNT, "not a staker");
        bytes32 entropy = keccak256(abi.encodePacked(msg.sender, nftId));
        require(!voted[entropy], "already voted");
        voted[entropy] = true;
        votesNay[nftId].push(msg.sender);
        emit Nay(nftId);
    }

    function IsVoteReady(uint256 nftId) external view returns (bool) {
        return votesAye[nftId].length * 2 > StakerCount;
    }

    function VotePostProcessAye(uint256 nftId) external {
        require(votesAye[nftId].length * 2 > StakerCount, "votes not enough");
        // mint verified NFT
        (string memory ipfsHash, uint256 projectId, uint256 reward, uint256 oracleId) = uVulnNFT.get_meta(nftId);


        vVulnNFT.mint(uVulnNFT.ownerOf(nftId), ipfsHash, projectId, reward, oracleId);

        // send rewards
        if (Projects[projectId].reward < reward) {
            reward = Projects[projectId].reward;
        }
        require(Token.balanceOf(address(this)) >= reward, "out of balance");


         Projects[projectId].reward -= reward;
        // instead of slash reward, lets just freeze the oracle
        FreezeOracle[projectId].push(oracleId);


        if (Projects[projectId].reward < MIN_DEPOSIT) {
            Projects[projectId].status = ProjectStatus.DESTROYED;
        }

        Token.transfer(uVulnNFT.ownerOf(nftId), reward - reward / 10);

        uint256 valRewards = reward / 10 / votesAye[nftId].length;
        for (uint32 i = 0; i < votesAye[nftId].length; i++) {
            Token.transfer(votesAye[nftId][i], valRewards);
        }

        // find all falsely voted and decrease score
        _decreaseScoreBatch(votesNay[nftId], SLASH_AMOUNT);

        emit AyeDone(nftId);

    }

    function VotePostProcessNay(uint256 nftId) external {
        require(votesNay[nftId].length > votesAye[nftId].length * 2, "votes not enough");

        // find all falsely voted and decrease score
        _decreaseScoreBatch(votesAye[nftId], SLASH_AMOUNT);

        emit NayDone(nftId);
    }

    // todo: address flakiness
}
