//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

/* The CrowdFunding Contract - Planning and Design

- The Admin will start a campaign for CrowdFunding with a specific monetary goal and deadline.
- Contributors will contribute to that project by sending ETH.
- The admin has to create a Spending Request to spend money for the campaign.
- Once the spending request was created, the  Contributors can start voting for that specific
spending request.
- If more than 50% of the total contributors voted for that request, then the admin would have 
the permission to spend the amount specified in the spending request.
- The power is moved from the campaign's admin to those that donated money.
- The contributors can request a refund if the monetary goal was not reached within the deadline.
*/

contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public numberOfContributors;
    uint public minimumContribution;
    uint public deadline; //timestamp
    uint public goal;
    uint public raisedAmount;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint numberOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint=> Request) public requests;
    uint public numRequests;

    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
        admin = msg.sender;
    }

    /* Events:
    - Allow JS callback functions that listen for them in the user interface to update
    the interface accordingly.
    - Generated events are not accessible from within contracts, not even from the one
    wich has created and emitted them. Events can only be accessed by external actors 
    such as JS.
    - Events are inheritable members of contracts, so if you declare an event in an
    interface or a base contract you don't need to declare it in the derived contracts.
    */
    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address _recipient, uint _value);

    function contribute() public payable{
        require(block.timestamp < deadline, "Deadline has passed!");
        require(msg.value >= minimumContribution, "Minimum contribution not met!");

        if(contributors[msg.sender] == 0){ //Checking if is the first contribution from that address.
            numberOfContributors++;    
        }

        contributors[msg.sender] += msg.value; //Update the total contribution of an address.
        raisedAmount += msg.value;      //Update the total contribution of the campaign.

        emit ContributeEvent(msg.sender, msg.value);
    }

    receive() payable external{
        contribute();
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getRefund() public{
        require(block.timestamp > deadline && goal > raisedAmount);
        //It's only possible get a refund if the address made a contribution:
        require(contributors[msg.sender] > 0, "You don't have any valeu to be refunded!");

        //Refund:
        payable(msg.sender).transfer(contributors[msg.sender]);

        //Now, it's necessary to reset the contribution from the address:
        raisedAmount -= contributors[msg.sender];
        contributors[msg.sender] = 0;
        numberOfContributors--;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin, "Only Admin can call this function!");
        _;
    }

    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin{
        Request storage newRequest = requests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.numberOfVoters = 0;

        emit CreateRequestEvent(_description,_recipient,_value);
    }

    function voteRequest(uint _requestNumber) public{
        //Only contributors can vote.
        require(contributors[msg.sender] > 0, "You must be a contributor to vote.");

        //Grabing the request to a variable that can be modified.
        Request storage thisRequest = requests[_requestNumber];

        //Only unfinished requests can be voted.
        require(thisRequest.completed == false, "This request has been completed.");

        //Only one vote per address:
        require(thisRequest.voters[msg.sender] == false, "You have already voted!");

        thisRequest.numberOfVoters++;
        thisRequest.voters[msg.sender] = true;
    }

    function makePayment(uint _requestNum) public onlyAdmin{
        //The goal must be reached.
        require(raisedAmount >= goal);
        Request storage thisRequest = requests[_requestNum];
        require(thisRequest.completed == false, "The request has been completed!");

        //"51%" of the contributors:
        require(thisRequest.numberOfVoters > (numberOfContributors/2));

        //Transfering the value and marking this request as completed.
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;

        emit MakePaymentEvent(thisRequest.recipient, thisRequest.value);
    }

}
