//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./gemDAO.sol";

contract RebateOracle is rAuth, IREBATE {
    
    address payable public STACK;
    address payable public _DAO = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
    address payable public _Governor = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);

    string public name = unicode"Rebate Oracle";
    string public symbol = unicode"ROCA";

    event Withdrawal(address indexed src, uint wad);
    event WithdrawToken(address indexed src, address indexed token, uint wad);
 
    constructor() payable rAuth(address(_Governor)) {
        STACK = payable(new DAO_STACK());
    }

    receive() external payable { }
    
    fallback() external payable { }
    
    function getDAOAddress() public view returns(address payable) {
        return STACK;
    }
    function getNativeBalance() public view override returns(uint256) {
        return address(this).balance;
    }

    function setDAO(address payable _DAOWallet) public override authorized() returns(bool) {
        require(address(_Governor) == _msgSender());
        _DAO = payable(_DAOWallet);
        (bool transferred) = transferAuthorization(address(_msgSender()), address(_DAOWallet));
        assert(transferred==true);
        return transferred;
    }
    
    function setGovernor(address payable _governorWallet) public override authorized() returns(bool) {
        require(address(_Governor) == _msgSender());
        _Governor = payable(_governorWallet);
        (bool transferred) = transferAuthorization(address(_msgSender()), address(_governorWallet));
        assert(transferred==true);
        return transferred;
    }

    function withdraw() external override authorized() returns(bool) {
        uint ETH_liquidity = uint(address(this).balance);
        assert(uint(ETH_liquidity) > uint(0));
        payable(_DAO).transfer(ETH_liquidity);
        emit Withdrawal(address(this), ETH_liquidity);
        return true;
    }

    function withdrawETH() public override authorized() returns(bool) {
        uint ETH_liquidity = uint(address(this).balance);
        assert(uint(ETH_liquidity) > uint(0));
        payable(_DAO).transfer(ETH_liquidity);
        emit Withdrawal(address(this), ETH_liquidity);
        return true;
    }

    function withdrawToDAO() public authorized() {
        uint256 ETHamount = address(this).balance;
        (bool sent,) = payable(_DAO).call{value: ETHamount}("");
        require(sent, "Failed to send Ether");
    }

    function withdrawToken(address token) public authorized() returns(bool) {
        uint Token_liquidity = uint(IERC20(token).balanceOf(address(this)));
        IERC20(token).transfer(payable(_DAO), Token_liquidity);
        emit WithdrawToken(address(this), address(token), Token_liquidity);
        return true;
    }

    function transfer(uint256 amount, address payable receiver) public virtual override authorized() returns ( bool ) {
        require(address(_Governor) == _msgSender());
        require(address(receiver) != address(0));
        (bool success,) = payable(receiver).call{value: amount}("");
        assert(success);
        return success;
    }
}
