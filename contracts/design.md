## ProjectDeployer
Vars:
* ProjectList mapping(uint256 => ProjectInfo)
```
struct ProjectInfo {
    uint256 Reward
    string memory IpfsHash
    bool isImplicit
}
```
  
Functions:
* AddProject(string memory ipfsHash, uint256 initialDeposit, bool isImplicit) -> uint256: projectId

View:
* GetProjectInfo(uint256 projectId) -> ProjectInfo

## MiningVuln
Vars:
* Vulns: mapping(tokenId => Vuln)
```
struct Vuln {
    uint256 projectId
    uint256 claimingReward
    string memory ipfsHash
    []address seals
    uint8 status
}
```

Functions:
* SubmitVuln(string memory ipfsHash, uint256 projectId)
* BurnVulnRequest(uint256 vulnId)
* ClaimReward(uint256 vulnId)

View:
* GetVulnStatus(uint256 vulnId)

## ConsensusGroup
* StakingAmount: mapping(address => uint256)
* StakingTime: mapping(address => uint256)
* KickVote: mapping(address => uint16)

Functions:
* Stake()
* Unstake()
* VotePenalty(address member)

View:
* GetStakers()
* IsStaker()

