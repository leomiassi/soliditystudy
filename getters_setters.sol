// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Property{
    int public price;
    string public location;

    /* When a variable is set as public
    the solidity will automatic create a "get function"
    for the variable.
    */

    /* The constructor is used to initialize state variables 
    when the contract is deployed by a externally owned 
    account or by another contract.
    */
    constructor(int _price, string memory _location){
        price = _price;
        location = _location;
    }

    function setPrice(int _price) public{
        price = _price;
    }

    function setLocation(string memory _location) public{
        location = _location;
    }
}
