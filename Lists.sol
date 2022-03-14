//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Listas{
    string[] public names;

    function addName(string memory _name) external{
        names.push(_name);
    }

    function getName(uint _position) external view returns(string memory){
        return names[_position];
    }

    function renameName(uint _position, string memory _newName) external{
        names[_position] = _newName;
    }

    function deleteName(uint _position) external{
        delete names[_position];
    }
}
