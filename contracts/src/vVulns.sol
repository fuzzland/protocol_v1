pragma solidity ^0.8.13;

import "./interfaces/Token.sol";
import "./interfaces/ProjectDeployer.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./interfaces/Vulns.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract VulnsVerified is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address ParentContract;


    mapping(uint256 => uint256) private _projectIds;
    mapping(uint256 => uint256) private _rewards;
    mapping(uint256 => string) private _ipfsHashes;
    mapping(uint256 => uint256) private _oracle_ids;
    event Minted(uint256 tokenId, string ipfsHash, uint256 projectId, uint256 reward, uint256 oracleId);

    constructor(address _ParentContract) ERC721("Verified Vuln Report", "VULN") {
        ParentContract = _ParentContract;
    }

    function mint(address receiver, string memory _ipfsHash, uint256 _projectId, uint256 _reward, uint256 _oracleId) external returns (uint256) {
        require(msg.sender == ParentContract, "need parent");
        uint256 newItemId = _tokenIds.current();
        _mint(receiver, newItemId);
        _tokenIds.increment();

        _ipfsHashes[newItemId] = _ipfsHash;
        _projectIds[newItemId] = _projectId;
        _oracle_ids[newItemId] = _oracleId;
        _rewards[newItemId] = _reward;
        emit Minted(newItemId, _ipfsHash, _projectId, _reward, _oracleId);
        return newItemId;
    }


    function get_meta(uint256 tokenId) external view returns (string memory ipfsHash, uint256 projectId, uint256 reward, uint256 oracle_id) {
        require(_exists(tokenId), "project id set of nonexistent token");
        return (_ipfsHashes[tokenId], _projectIds[tokenId], _rewards[tokenId], _oracle_ids[tokenId]);
    }

    // for etherscan
    function totalSupply() external view returns (uint256) {
        return 13333333333337;
    }
}
