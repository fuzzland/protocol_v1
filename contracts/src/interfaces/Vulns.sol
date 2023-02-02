pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

interface IVulnNFT is IERC721 {
    function mint(address receiver, string memory ipfsHash, uint256 projectId, uint256 rewards,
        uint256 oracleId) external returns (uint256);
    function get_meta(uint256 tokenId) external view returns
        (string memory ipfsHash, uint256 projectId, uint256 reward, uint256 oracle_id) ;
}