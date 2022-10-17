//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IREBATE {
    event Transfer(address indexed from, address indexed to, uint value);

    function withdrawToDAO() external;
    function withdraw() external returns (bool);
    function withdrawETH() external returns(bool);
    function getNativeBalance() external view returns(uint256);
    function withdrawToken(address token) external returns (bool);
    function setDAO(address payable _DAO_CA) external returns(bool);
    function setSTACK(address payable _STACK_CA) external returns(bool);
    function appointGovernor(address payable _governorWallet) external returns(bool);
    function transfer(uint256 eth, address payable receiver) external returns (bool success);
    function transferToken(uint256 amount, address payable receiver, address token) external returns(bool);
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}

interface I_iVAULT {
    function withdraw() external;
    function withdrawToken(address token) external;
    function withdrawFrom(uint256 number) external;
    function getVIP() external returns(address payable);
    function walletOfIndex(uint256 id) external view returns(address);
    function withdrawTokenFrom(address token, uint256 number) external;
    function balanceOf(uint256 receiver) external view returns(uint256);
    function indexOfWallet(address wallet) external view returns(uint256);
    function setVIP(address payable iWTOKEN,address payable iTOKEN, uint iNum, bool tokenFee, uint tFee, uint bMaxAmt) external;
    function deployVaults(uint256 number) external payable returns(address payable);
    function batchVaultRange(address token, uint256 fromWallet, uint256 toWallet) external;
    function balanceOfToken(uint256 receiver, address token) external view returns(uint256);
    function balanceOfVaults(address token, uint256 _from, uint256 _to) external view returns(uint256,uint256);
    function withdrawFundsFromVaultTo(uint256 _id, uint256 amount, address payable receiver) external returns (bool);
}

interface IRECEIVE_TOKEN {
    event Transfer(address indexed from, address indexed to, uint value);

    function withdraw() external;
    function withdrawToken(address token) external;
    function bridgeTOKEN(uint256 amountTOKEN) external payable returns(bool);
    function bridgeTOKEN_bulk(uint256 amountTOKEN) external payable returns(bool);
    function vaultDebt(address vault) external view returns(uint,uint,uint,uint,uint,uint,uint);
    function bridgeTransferOutBulkTOKENSupportingFee(uint[] memory _amount, address[] memory _addresses, address token) external returns (bool);
    function bridgeTransferOutBulkTOKEN(uint[] memory _amount, address[] memory _addresses, address token) external returns (bool);
    function bridgeTransferOutTOKEN(uint256 amount, address payable receiver) external returns (bool);
    function bridgeTransferOutBulk(uint[] memory _amount, address[] memory _addresses) external payable returns (bool);
    function transfer(address sender, uint256 eth, address payable receiver) external returns(bool success);
    function setShards(address payable iTOKEN, address payable iWTOKEN, uint _m, bool tFee, uint txFEE, uint bMaxAmt) external;
}
