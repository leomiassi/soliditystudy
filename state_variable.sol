// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Property{
    int public price;
    string constant public location = "London";

    // price = 666; this is not permitted in solidity.

    constructor(){
        price = 666;
    }

    function f1() public pure returns(int){
        int x = 5;
        x *= 2;
        return x;
    }
}
