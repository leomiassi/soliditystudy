//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Property{
    uint public price;
    address public owner;

    constructor(){
        owner = msg.sender;
        price = 0;
    }

    /*Function Modifiers:
    - Are used to modify the behaviour of a function. They test a condition before calling a function which
    will be executed only if the condition of the modifier evaluates to true.
    - Avoid reduntant-code and possible errors.
    - They are contract properties and are inherited.
    - They don't return and use only require().
    */
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) public onlyOwner{
        owner = _owner;
    }

    function setPrice(uint _price) public onlyOwner{
        price = _price;
    }
}
