//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;


/* The Lottery Smart Contract - Planning and Desing

- The lottery starts by accepting ETH transactions. Anyone having a Ethereum wallet can 
send a fixed amount of 0.1 ETH to the contract address.
- The players send ETH directly to the contract address and their Ethereum address is registered. 
A user can send more transactions having more chances to win.
- There is a manager, the account that deploys and controls the contract.
- At some point, if there are at least 3 players, he can pick a random winner from the players list.
Only the manager is allowed to see the contract balance and to randomly select the winner.
- The contract will transfer the entire balance to the winner's address and the lottery is
reset and ready for the next round.
*/



contract Loterry{
    address payable[] public players;
    address public manager;

    constructor(){
        /*msg.sender holds the address of the person who interact with the contract.
        In this case, setting in the constructor function, the msg.sender is the person..
        .. who creat and deploys the contract.
        The constructor is called only once, so is not possible to change the manager without
        a function that do this explicit. */
        manager = msg.sender;
    }

    //Function to receive ETH from extenal accounts.
    //The address of the sender is add to the variable players.
    receive() external payable{
        // - Here the require function check if the value sender is equal to 0.1ETH.
        // - 0.1 ETH = 100000000000000000 wei. This force everyone to always send the same amount of wei.
        // But you can still send many times for having more chances to win.
        require(msg.value == 0.1 ether);

        players.push(payable(msg.sender));
    }

    //Function that returns the amount of balance, in wei, in the contract.
    function getBalance() public view returns(uint){
        //Only the manager can see the balance:
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random() public view returns(uint){
        // This is not the most secure way to generate random numbers, but is just to ilustrate.
        // The random number created bellow is based on the block difficulty, block timestamp and the numbers of players.
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public{
        //Only the manager is allowed to pick the winner.
        require(msg.sender == manager);
        //It is necessary to be at least 3 players.
        require(players.length >= 3);

        //Selecting the winner:
        uint r = random();  //get the big random number
        address payable winner; //variable that will hold the winner address
        uint index = r % players.length;    //get the index of the winner
        winner = players[index];     //set the address of the winner player to the variable
        
        //Transfer the balance to winner
        winner.transfer(getBalance());

        //Resetting the Loterry
        players = new address payable[](0);
    }

}
