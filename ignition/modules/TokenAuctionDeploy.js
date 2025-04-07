const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const INITIAL_TOKEN_SUPPLY = 1000000n; // 1M tokens
const AUCTION_DURATION_HOURS = 24n; // 24 hours
const ITEM_DESCRIPTION = "Rare Space Artifact";

module.exports = buildModule("TokenAuctionModule", (m) => {
  // Parameters can be overridden when running the deployment
  const initialSupply = m.getParameter("initialSupply", INITIAL_TOKEN_SUPPLY);
  const auctionDuration = m.getParameter("auctionDuration", AUCTION_DURATION_HOURS);
  const itemDescription = m.getParameter("itemDescription", ITEM_DESCRIPTION);

  // Deploy the AstroToken contract first
  const astroToken = m.contract("AstroToken", [initialSupply]);

  // Deploy the TokenAuction contract, passing the AstroToken address
  const tokenAuction = m.contract("TokenAuction", [
    astroToken, // Token contract address
    auctionDuration,
    itemDescription
  ]);

  // Return both deployed contracts
  return { 
    astroToken,
    tokenAuction 
  };
});