//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

/* ERC20 Token Standard. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- A token is designed to represent something of value but also things like voting
rights or discount vouchers. It can represent any fungible trading good.
- ERC stands for 'Ethereum Request for Comments'. An ERC is a form of proposal
and its purpose is to define standards and practices.
- EIP stands for 'Ethereum Improvement Proposal' and makes changes to the actual
code of Ethereum. ERC is just guidance on how to use different features of Ethereum.
- ERC20 is a proposal that intends to standardize how a token contract should be
defined, how we interact with such a token contract and how these contracts 
interact with each other.
- ERC20 is a standard interface used by applications such as wallets, decentralized
exchanges, and so on to interact with tokens.
- The ERC20 introduces a standard for Fungible Token, in other words, they have  a
property that makes each Token be exactly the same (in type and value) of another
Token. For example, an ERC20 Token acts just like the ETH, meaning that 1 token 
is and will always be equal to all the other Tokens.
- A token holder has full control and complete ownership of their tokens. The token's
contract keeps track of token ownership in the same way the Ethereum network keeps 
track of who owns ETH.
- We use the same wallet in which we store ETH to buy, sell or transfer a token, but
we are actually interacting with a contract.
- There are tokens that are fully ERC20-compliant and tokens that are only partially.
- A fully compatible ERC20 Token must implement 6 functions and 2 events.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

interface ERC20Interface{
    function totalSupply() external view returns(uint);
    function balanceOF(address tokenOwner) external view returns(uint balance);
    function transfer(address to,  uint tokens) external returns(bool success);

    function allowance(address tokenOwner, address spender) external view returns(uint remaining);
    function approve(address spender, uint tokens) external returns(bool success);
    function transferFrom(address from, address to, uint tokens) external returns(bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Lenha is ERC20Interface{
    string public name= "Lenha";
    string public symbol = "LNH";
    uint public decimals = 0; //18
    uint public override totalSupply;

    address public founder;
    // balances[0x1111...] = 100.
    mapping(address => uint) public balances;

    // ax1111...(owner) allows 0x2222...(spender) --> 100 tokens.
    // allowed[0x1111...][0x2222...] = 100.
    mapping(address => mapping(address => uint)) allowed;

    constructor(){
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOF(address tokenOwner) public view override returns(uint balance){
        // Returning the token's balance of the owner.
        return balances[tokenOwner];
    }    

    function transfer(address to,  uint tokens) public override returns(bool success){
        // It's necessary to have the amount of tokens you want to send.
        require(balances[msg.sender] >= tokens);

        balances[to] += tokens;
        balances[msg.sender] -= tokens;

        // After updating the new values, we must emit this event.
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns(uint){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns(bool success){
        // It's necessary to have the amount of tokens you want to approve.
        require(balances[msg.sender] >= tokens);
        // Numbers of tokens must be more than zero.
        require(tokens > 0);

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns(bool success){
        // It's necessary to have the amount of allowed tokens you want to send.
        require(allowed[from][to] >= tokens);
        // It's necessary to have the amount of tokens you want to send.
        require(balances[from] >= tokens);

        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][to] -= tokens;

        return true;
    }
}
