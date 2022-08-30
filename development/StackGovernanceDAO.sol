//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract MSG_ {
    
    function _msgSender() internal view virtual returns (address) {
        return _msgSender();
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

}

contract ERC20 is MSG_, IERC20 {
    using SafeMath for uint256;
    
    IERC20 token;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address payable public devFeeAddress;
    address payable public feeAddress;

    uint256 internal bp;
    uint256 internal taxFeeInBasis;
    uint256 internal devFeeInBasis;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount,true);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if(address(sender) != address(_msgSender()) && uint256(amount) > uint256(allowance(address(sender), address(_msgSender())))) {
            revert();
        }
        _transfer(sender, recipient, amount, true);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount, bool takeFee) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(takeFee == true) {
            uint256 cFee = (uint256(amount) * uint256(taxFeeInBasis)) / uint256(bp);
            uint256 dFee = (uint256(amount) * uint256(devFeeInBasis)) / uint256(bp);
            _balances[sender] = _balances[sender].sub(amount);
            amount -= cFee;
            amount -= dFee;
            _balances[recipient] = _balances[recipient].add(amount);
            _balances[feeAddress] = _balances[feeAddress].add(cFee);
            _balances[devFeeAddress] = _balances[devFeeAddress].add(dFee);
            emit Transfer(sender, recipient, amount);
            emit Transfer(sender, feeAddress, cFee);
            emit Transfer(sender, devFeeAddress, dFee);
        } else {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

contract Token is MSG_, ERC20 {
    mapping (address => bool) private _contracts;

    constructor() {
        _name = "Governance DAO Token";
        _symbol = "STACK-GV";
        _decimals = 18;
        feeAddress = payable(_msgSender());
        devFeeAddress = payable(_msgSender());
        taxFeeInBasis = 300; // 3%
        devFeeInBasis = 200; // 2%
        bp = 10000; // divisor
    }
}

contract StackGovernanceDAO is MSG_, Token {
    using SafeMath for uint256;

    uint private startTime; 
    
    address payable private OWNER;
    address payable private DEVELOPER;
    address private rebateOracleAddress;
    
    uint public totalEtherStacked;
    uint public totalTokenStacked;
    
    uint private constant DEV_FEE = 120;
    uint private constant MINT_AMOUNT = 100000 ether;      
    uint private constant PERCENT_DIVIDER = 1000;
    uint private constant PERCENT_ROUNDING = 100;
    uint private constant TIME_TO_UNSTACK = 1 minutes;
    uint private constant TIME_TO_CLAIM = 1 minutes;
    uint private constant GENERAL_CLASS = 1 ether;    
    uint private GENERAL_REBATE_SHARDS = 1*10**17; // 0.1
    uint private constant LOWR_CLASS = 10 ether;    
    uint private LOWR_REBATE_SHARDS = 5*10**17; // 0.5
    uint private constant MIDL_CLASS = 100 ether;    
    uint private MIDL_REBATE_SHARDS = 1*10**18; // 1
    uint private constant UPPR_CLASS = 1000 ether; 
    uint private UPPR_REBATE_SHARDS = 10*10**18; // 10
    uint private constant VIP_CLASS = 10000 ether;  
    uint private VIP_REBATE_SHARDS = 100*10**18; // 100
    
    mapping(address => User) private users;
    
    struct Stacking {
        uint totalStacked; 
        uint lastStackTime;    
        uint lastClaimed; 
        uint tier;
    }
    
    struct User {
        Stacking sNative;
        Stacking sToken;
    }

    event Deposit(address indexed dst, uint amount);
    event NetworkMint(address indexed dst, uint amount);
    event NetworkWithdrawal(address indexed src, uint amount);
    event Withdrawal(address indexed src, uint amount);
    event Claim(address indexed src, uint amount);
    event Received(address, uint);
    event ReceivedFallback(address, uint);

    constructor() {
        token = IERC20(address(this));
        OWNER = payable(_msgSender());
        DEVELOPER = payable(_msgSender());
        rebateOracleAddress = address(0);
        startTime = block.timestamp + 1 minutes;
        _mint(_msgSender(), MINT_AMOUNT);  
    }       
    
    modifier onlyOwner {
        require(_msgSender() == OWNER, "Only owner can call this function");
        _;
    } 
    
    fallback() external payable {
        stackNativeCoin();
        emit ReceivedFallback(_msgSender(), msg.value);
    }
    
    receive() external payable {
        stackNativeCoin();
        emit Received(_msgSender(), msg.value);
    }

    function setRebateOracle(address rebateOracle) public onlyOwner {
        rebateOracleAddress = address(rebateOracle);
    }

    function stackNativeCoin() public payable returns(bool) {
        User storage user = users[_msgSender()];
        require(address(rebateOracleAddress) != address(0),"Not enabled");
        uint256 ethAmount = msg.value;
        require(uint256(ethAmount) > uint256(0),"Zero dissallowed");
        if(address(_msgSender()) == address(rebateOracleAddress)){
            return true;
        } else {
            if(uint256(ethAmount) < uint256(GENERAL_CLASS)) {
                revert("Not enough ether to enter tier");
            } else if(uint256(ethAmount) >= uint256(GENERAL_CLASS) && uint256(ethAmount) < uint256(LOWR_CLASS)) {
                user.sNative.tier = 1;
            } else if(uint256(ethAmount) >= uint256(LOWR_CLASS) && uint256(ethAmount) < uint256(MIDL_CLASS)) {
                user.sNative.tier = 2;
            } else if(uint256(ethAmount) >= uint256(MIDL_CLASS) && uint256(ethAmount) < uint256(UPPR_CLASS)) {
                user.sNative.tier = 3;
            } else if(uint256(ethAmount) >= uint256(UPPR_CLASS) && uint256(ethAmount) < uint256(VIP_CLASS)) {
                user.sNative.tier = 4;
            } else if(uint256(ethAmount) >= uint256(VIP_CLASS)) {
                user.sNative.tier = 5;
            } else {
                revert("Hmm, please try again with a different amount of ether");
            }
            user.sNative.lastStackTime = block.timestamp;
            user.sNative.totalStacked = user.sNative.totalStacked.add(ethAmount);
            totalEtherStacked = totalEtherStacked.add(ethAmount); 
            payable(address(this)).transfer(uint256(ethAmount));
            // _mint(_msgSender(), ethAmount);
            emit Deposit(_msgSender(), msg.value);
            return true;
        }

    }
    
    function setRebateAmount(uint256 rebateAmount, uint256 class) public onlyOwner {
        require(uint256(class) > uint256(0));
        // rebateAmount = rebateAmount * 10**18; // ether
        if(uint256(class) == 1){
            GENERAL_REBATE_SHARDS = uint256(rebateAmount);
        } else if(uint256(class) == 2){
            LOWR_REBATE_SHARDS = uint256(rebateAmount);
        } else if(uint256(class) == 3){
            MIDL_REBATE_SHARDS = uint256(rebateAmount);
        } else if(uint256(class) == 4){
            UPPR_REBATE_SHARDS = uint256(rebateAmount);
        } else if(uint256(class) == 5){
            VIP_REBATE_SHARDS = uint256(rebateAmount);
        } else {
            revert("Hmm, try again...");
        }
    }

    function claim() public {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sNative.lastClaimed.add(TIME_TO_CLAIM), "Claim not available yet");
        uint tokenAmount = user.sToken.totalStacked;
        require(uint(tokenAmount) > uint(0),"Can't claim with 0 token");
        uint256 pool = address(this).balance;
        require(uint256(pool) > GENERAL_REBATE_SHARDS,"Exhausted supply");
        uint256 REBATE_AMOUNT;
        if(uint256(user.sToken.tier) < uint256(1)) {
            revert("Not enough token to enter general class tier");
        } else if(uint256(user.sToken.tier) == uint256(1)) {
            REBATE_AMOUNT = uint256(GENERAL_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(2)) {
            REBATE_AMOUNT = uint256(LOWR_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(3)) {
            REBATE_AMOUNT = uint256(MIDL_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(4)) {
            REBATE_AMOUNT = uint256(UPPR_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(5)) {
            REBATE_AMOUNT = uint256(VIP_REBATE_SHARDS);
        } else {
            revert("Hmm, please try again with a different amount of token");
        }
        payable(_msgSender()).transfer(REBATE_AMOUNT);
        user.sNative.lastClaimed = block.timestamp;
        emit Claim(_msgSender(), REBATE_AMOUNT);
    }   
    
    function withdraw() public {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sNative.lastStackTime.add(TIME_TO_CLAIM), "Claim not available yet");
        uint ethAmount = user.sNative.totalStacked;
        require(uint(ethAmount) > uint(0),"Can't withdraw 0 ether");
        totalEtherStacked = totalEtherStacked.sub(ethAmount); 
        payable(_msgSender()).transfer(totalEtherStacked);
        user.sNative.totalStacked = 0;

        emit Withdrawal(_msgSender(), ethAmount);
    }   

    function stackToken(uint tokenAmount) public {
        require(uint(tokenAmount) > uint(0),"Can't stack 0 token");
        User storage user = users[_msgSender()];
	uint256 fee = tokenAmount.mul(DEV_FEE).div(PERCENT_DIVIDER);
        require(block.timestamp >= startTime, "Stacking not available yet");
        require(tokenAmount <= balanceOf(_msgSender()), "Insufficient Token Balance");
        tokenAmount = tokenAmount.sub(fee);

        if(uint256(tokenAmount) < uint256(GENERAL_CLASS)) {
            revert("Not enough token to enter general class tier");
        } else if(uint256(tokenAmount) >= uint256(GENERAL_CLASS) && uint256(tokenAmount) < uint256(LOWR_CLASS)) {
            user.sToken.tier = 1;
        } else if(uint256(tokenAmount) >= uint256(LOWR_CLASS) && uint256(tokenAmount) < uint256(MIDL_CLASS)) {
            user.sToken.tier = 2;
        } else if(uint256(tokenAmount) >= uint256(MIDL_CLASS) && uint256(tokenAmount) < uint256(UPPR_CLASS)) {
            user.sToken.tier = 3;
        } else if(uint256(tokenAmount) >= uint256(UPPR_CLASS) && uint256(tokenAmount) < uint256(VIP_CLASS)) {
            user.sToken.tier = 4;
        } else if(uint256(tokenAmount) >= uint256(VIP_CLASS)) {
            user.sToken.tier = 5;
        } else {
            revert("Hmm, please try again with a different amount of token");
        }

        _transfer(_msgSender(), address(this), tokenAmount, false);
        _transfer(_msgSender(), address(DEVELOPER), fee, false);

        user.sToken.lastStackTime = block.timestamp;
        user.sToken.totalStacked = user.sToken.totalStacked.add(tokenAmount);
        totalTokenStacked = totalTokenStacked.add(tokenAmount); 
    } 
    
    function unStackToken() public {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sToken.lastStackTime.add(TIME_TO_UNSTACK), "Un-Stack not available yet");
        uint tokenAmount = user.sToken.totalStacked;
        require(uint(tokenAmount) > uint(0),"Can't stack 0 token");
        totalTokenStacked = totalTokenStacked.sub(tokenAmount); 
        _transfer(address(this), _msgSender(), tokenAmount, false);
        user.sToken.totalStacked = 0;
    }  
	
    function getContractETHBalance() public view returns (uint) {
    	return address(this).balance;
    }  
	
    function getContractTokenBalance() public view returns (uint) {
    	return balanceOf(address(this));
    }
	
    function getUserTokenBalance(address _addr) public view returns (uint) {
    	return balanceOf(_addr);
    }
}
