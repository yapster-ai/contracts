// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "lib/OAO/contracts/interfaces/IAIOracle.sol";
import "lib/OAO/contracts/AIOracleCallbackReceiver.sol";
import "./ERC7007.sol";

contract Yapster is AIOracleCallbackReceiver {
    mapping(uint256 => bool) public requestPending; // Track AIOracle requests
    mapping(uint256 => bytes) public requestPrompt; // Store prompt before request
    ERC7007 public erc7007;

    event AIGCDataRequested(uint256 indexed requestId, uint256 modelId, address sender);
    event AIGCDataUpdated(uint256 indexed tokenId, bytes aigcData, bytes proof, string proofType);

    constructor(address _aiOracleAddress)
        AIOracleCallbackReceiver(IAIOracle(_aiOracleAddress))
    {
        erc7007 = new ERC7007("YAPSER AI","YAPS");
        aiOracle = IAIOracle(_aiOracleAddress);
    }

    /**
     * @dev Calculates AI-generated Yaps and triggers AIOracle request.
     */
    function calculateYaps(uint256 modelId, bytes calldata input) external payable {
        bytes memory callbackData = abi.encode(msg.sender, modelId);
        address callbackAddress = address(this);

        uint256 requestId = aiOracle.requestCallback{value: msg.value}(
            modelId,
            input,
            callbackAddress,
            500000, // Example gas limit, adjust if needed
            callbackData
        );

        // Store prompt before request
        requestPrompt[requestId] = input;
        requestPending[requestId] = true;

        emit AIGCDataRequested(requestId, modelId, msg.sender);
    }

    /**
     * @dev Handles AI Oracle response and mints/updates NFTs.
     */
    function aiOracleCallback(
        uint256 requestId,
        bytes calldata output,
        bytes calldata callbackData
    ) external override onlyAIOracleCallback {
        require(requestPending[requestId], "Invalid AI request");
        delete requestPending[requestId];

        (address sender, uint256 modelId) = abi.decode(callbackData, (address, uint256));
        bytes memory aigcData = output; // AI Oracle only returns output

        string memory proofType = "Fraud Proof";
        bytes memory storedPrompt = requestPrompt[requestId];

        require(storedPrompt.length > 0, "No prompt stored for this request");

        // Delete stored prompt after use
        delete requestPrompt[requestId];

        uint256 tokenId;
        uint256 balance = erc7007.balanceOf(sender);

        // Construct proof including `requestId` and `modelId`
        bytes memory proof = abi.encode(requestId, modelId);

        if (balance == 0) {
            // User does NOT own an NFT, mint a new one
            tokenId = erc7007.totalSupply(); // Assign new tokenId
            erc7007.mint(sender);

            // Call ERC7007 addAigcData function to store AI results
            erc7007.addAigcDataForYaps(
                tokenId,
                "AI-Yap",
                "Generated via Verified AI",
                storedPrompt,
                "Verified AI Content",
                aigcData,
                proof,
                proofType
            );
        } else {
            // Get the first owned NFT
             tokenId = erc7007.getFirstTokenId(sender);


            // If user already has an NFT, update the existing one
            erc7007.addAigcDataForYaps(
                tokenId,
                "AI-Yap",
                "Generated via AI",
                storedPrompt,
                "AI Content",
                aigcData,
                proof,
                proofType
            );
        }

        emit AIGCDataUpdated(tokenId, aigcData, proof, proofType);
    }
}
