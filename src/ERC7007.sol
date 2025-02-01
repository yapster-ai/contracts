// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./interfaces/IERC7007Updatable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ERC7007 is ERC721Enumerable, IERC7007Updatable, Ownable {
    struct AigcMetadata {
        string name;
        string description;
        bytes prompt;
        string aigcType;
        bytes aigcData;
        bytes proof;
        string proofType;
    }

    mapping(uint256 => AigcMetadata) private _aigcData;
    uint256 private _tokenCounter;

    /**
     * @dev Modifier to restrict access to only the contract owner or token owner.
     */
    modifier onlyOwnerOrTokenOwner(uint256 tokenId) {
        require(
            ownerOf(tokenId) == msg.sender || owner() == msg.sender,
            "ERC7007: Only token owner or contract owner can update"
        );
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {}

    /**
     * @dev Mint a new ERC721 token.
     */
    function mint(address to) external onlyOwner {
        uint256 tokenId = _tokenCounter;
        _safeMint(to, tokenId);
        _tokenCounter++;
    }

    /**
     * @dev Add AI-generated data to token at `tokenId`.
     */
    function addAigcDataForYaps(
        uint256 tokenId,
        string calldata name,
        string calldata description,
        bytes calldata prompt,
        string calldata aigcType,
        bytes calldata aigcData,
        bytes calldata proof,
        string calldata proofType
    ) external onlyOwnerOrTokenOwner(tokenId) {
        require(_exists(tokenId), "ERC7007: Token does not exist");

        AigcMetadata storage metadata = _aigcData[tokenId];
        metadata.name = name;
        metadata.description = description;
        metadata.prompt = prompt;
        metadata.aigcType = aigcType;
        metadata.aigcData = aigcData;
        metadata.proof = proof;
        metadata.proofType = proofType;

        emit AigcData(tokenId, prompt, aigcData, proof);
    }

    /**
     * @dev Returns the total number of minted tokens.
     */
    function totalSupply() public view override returns (uint256) {
        return _tokenCounter;
    }

    function getAigcMetadata(uint256 tokenId) external view returns (AigcMetadata memory) {
        require(_exists(tokenId), "ERC7007: Token does not exist");
        return _aigcData[tokenId];
    }

    /**
     * @dev Get the first owned token for a given address.
     */
    function getFirstTokenId(address owner) external view returns (uint256) {
        uint256 balance = balanceOf(owner);
        require(balance > 0, "ERC7007: No tokens owned by this address");
        return tokenOfOwnerByIndex(owner, 0);
    }

    /**
     * @dev Verify if the given `prompt`, `aigcData`, and `proof` exist in any minted token.
     * Returns true if a matching token is found, otherwise false.
     */
    function verify(
        bytes calldata prompt,
        bytes calldata aigcData,
        bytes calldata proof
    ) external view override returns (bool success) {
        for (uint256 tokenId = 0; tokenId < _tokenCounter; tokenId++) {
            if (_exists(tokenId)) {
                AigcMetadata storage data = _aigcData[tokenId];

                if (
                    keccak256(data.prompt) == keccak256(prompt) &&
                    keccak256(data.aigcData) == keccak256(aigcData) &&
                    keccak256(data.proof) == keccak256(proof)
                ) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * @dev Override supportsInterface to include ERC721Enumerable.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Check if a token exists.
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Add AI-generated data (restricted to only token owner or contract owner).
     */
    function addAigcData(
        uint256 tokenId,
        bytes calldata prompt,
        bytes calldata aigcData,
        bytes calldata proof
    ) external onlyOwnerOrTokenOwner(tokenId) {
        require(_exists(tokenId), "ERC7007: Token does not exist");

        AigcMetadata storage metadata = _aigcData[tokenId];
        metadata.prompt = prompt;
        metadata.aigcData = aigcData;
        metadata.proof = proof;

        emit AigcData(tokenId, prompt, aigcData, proof);
    }

    /**
     * @dev Update AI-generated data (restricted to only token owner or contract owner).
     */
    function update(
        uint256 tokenId,
        bytes calldata prompt,
        bytes calldata aigcData,
        bytes calldata proof
    ) external onlyOwnerOrTokenOwner(tokenId) {
        require(_exists(tokenId), "ERC7007: Token does not exist");

        AigcMetadata storage metadata = _aigcData[tokenId];
        metadata.prompt = prompt;
        metadata.aigcData = aigcData;
        metadata.proof = proof;

        emit AigcData(tokenId, prompt, aigcData, proof);
    }
}
