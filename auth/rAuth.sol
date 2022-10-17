//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../interfaces/INTERFACES_REBATE_ORACLE.sol";
import "../utils/MSG.sol";

abstract contract rAuth is _MSG {
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address _auth) {
        initialize(address(_auth));
    }

    modifier onlyOwner() virtual {
        require(isOwner(_msgSender()), "!OWNER"); _;
    }

    modifier onlyZero() virtual {
        require(isOwner(address(0)), "!ZERO"); _;
    }

    modifier authorized() virtual {
        require(isAuthorized(_msgSender()), "!AUTHORIZED"); _;
    }
    
    function initialize(address _auth) private {
        owner = _auth;
        authorizations[_auth] = true;
    }

    function authorize(address adr) public virtual authorized() {
        authorizations[adr] = true;
    }

    function rAuthorize(address adr) public virtual authorized() returns(bool) {
        authorizations[adr] = true;
        return authorizations[adr];
    }

    function unauthorize(address adr) public virtual authorized() {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        if(account == owner){
            return true;
        } else {
            return false;
        }
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    
    function transferAuthorization(address fromAddr, address toAddr) public virtual authorized() returns(bool) {
        require(fromAddr == _msgSender());
        bool transferred = false;
        authorize(address(toAddr));
        initialize(address(toAddr));
        unauthorize(address(fromAddr));
        transferred = true;
        return transferred;
    }
}
