//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

/* The Auction Smart Contract - Planning and Design

- Smart Contract for a Decentralized Auction like an eBay alternative.
- The Auction has a owner(the person who sells a good or service), a start and an end date.
- The owner can cancel the auctino if there is an emergency or can finalize the auction after its end time.
- People are sending ETH by calling a functino called placeBid(). The sender's address and the value sender
to the auction will be stored in mapping variable called bids.
- Users are incentivized to bid the maximum they're willing to pay, but they are not bound to that full amount,
but rather to the previous highest bid plus and increment. The contract will automatically bid up to a given ammount.
- The highestBindingBid is the selling price and the highestBidder the person who won the auction.
- After the action ends the owner gets the highestbindingBid and everybody else withdraws their own amount.
*/

contract Auction{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    enum State{Started, Running, Ended, Canceled}
    State public auctionState;

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping(address => uint) public bids;
    uint bidIncrement;

    constructor(){
        //It's necessery to convert the address to payable, because the owner is a payable address.
        owner = payable(msg.sender);
        //Setting the auction state as running.
        auctionState = State.Running;

        //Setting the auction to run for a week;
        //At every 15 seconds a block is created. 
        // 1min = 60s
        // 1h = 60 * 60 = 3600s
        // 1d = 24 * 3600 = 86400s 
        // 1w = 7 * 86400 = 604800s 
        // 604800/15 = 40320 blocks per week.
        startBlock = block.number;
        endBlock = startBlock + 40320;
        ipfsHash = "";  //Empty string.
        bidIncrement = 100; //wei.
    }

    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }

    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }

    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }

    function min(uint a, uint b) pure internal returns(uint){
        if(a <= b){
            return b;
        }else{
            return a;
        }
    }

    function cancelAuction() public onlyOwner{
        auctionState = State.Canceled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd{
        require(auctionState == State.Running);
        require(msg.value >= 100);

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);

        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        }else{
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }

    /*Withdrawal Pattern

    - We don't proactively send back the funds to the users that didn't win the auction.
    We'll use the withdrwal patter instead.
    - We should only send ETH to a user when he explicitly requrest it.
    - Helps us avoid re-entrance attacks that could cause unexpected behavior.
    */

    function finalizeAuction() public{
        require(auctionState == State.Canceled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);

        address payable recipient;
        uint value;

        if(auctionState == State.Canceled){
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        }else{
            if(msg.sender == owner){
                recipient = owner;
                value = highestBindingBid;
            }else{
                if(msg.sender == highestBidder){
                    recipient = highestBidder;
                    value = bids[highestBidder];
                }else{
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        recipient.transfer(value);
    }
}
