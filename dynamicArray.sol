//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract DynamicArrays{
    uint[] public array; //Dynamic array

    function getLength() public view returns(uint){
        return array.length;
    }

    function addElement(uint num) public{
        array.push(num);
    }

    function getElement(uint i) public view returns(uint){
        if(i < array.length){
            return array[i];
        }
        return 0;
    }

    function popElement() public{
        array.pop();
    }

}
