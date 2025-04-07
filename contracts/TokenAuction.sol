// Simple Auction Contract using AstroToken
contract TokenAuction {
    AstroToken public token;          // Reference to the token contract
    address public auctioneer;        // The auction creator
    address public highestBidder;     // Current highest bidder
    uint256 public highestBid;        // Current highest bid amount
    uint256 public auctionEndTime;    // When the auction ends
    bool public ended;                // Auction status
    string public itemDescription;    // Item being auctioned
    
    event NewHighestBid(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    
    constructor(
        address _tokenAddress,
        uint256 _biddingTimeInHours,
        string memory _itemDescription
    ) {
        token = AstroToken(_tokenAddress);
        auctioneer = msg.sender;
        auctionEndTime = block.timestamp + (_biddingTimeInHours * 1 hours);
        itemDescription = _itemDescription;
        ended = false;
    }
    
    // Place a bid with tokens
    function bid(uint256 bidAmount) public {
        require(!ended, "Auction already ended");
        require(block.timestamp < auctionEndTime, "Auction time expired");
        require(bidAmount > highestBid, "Bid must be higher than current highest bid");
        
        // Transfer tokens from bidder to this contract
        require(
            token.transferFrom(msg.sender, address(this), bidAmount),
            "Token transfer failed"
        );
        
        // Refund previous bidder if there was one
        if (highestBidder != address(0)) {
            require(
                token.transfer(highestBidder, highestBid),
                "Refund failed"
            );
        }
        
        highestBidder = msg.sender;
        highestBid = bidAmount;
        emit NewHighestBid(msg.sender, bidAmount);
    }
    
    // End the auction and transfer funds to auctioneer
    function endAuction() public {
        require(msg.sender == auctioneer, "Only auctioneer can end auction");
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!ended, "Auction already ended");
        
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        
        // Transfer tokens to auctioneer
        if (highestBid > 0) {
            require(
                token.transfer(auctioneer, highestBid),
                "Transfer to auctioneer failed"
            );
        }
    }
    
    // Get current auction status
    function getAuctionStatus() public view returns (
        address currentHighestBidder,
        uint256 currentHighestBid,
        uint256 timeRemaining,
        bool isEnded
    ) {
        uint256 timeLeft = (block.timestamp >= auctionEndTime) ? 0 : auctionEndTime - block.timestamp;
        return (highestBidder, highestBid, timeLeft, ended);
    }
}