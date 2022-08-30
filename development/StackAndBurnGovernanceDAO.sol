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
        _name = "Stack && Burn Governance DAO Token";
        _symbol = "STACK-BURN-GV-DAO";
        _decimals = 18;
        feeAddress = payable(_msgSender());
        devFeeAddress = payable(_msgSender());
        taxFeeInBasis = 300; // 3%
        devFeeInBasis = 200; // 2%
        bp = 10000; // divisor
    }
}

contract StackAndBurnGovernanceDAO is MSG_, Token {
    using SafeMath for uint256;

    uint256 private startTime; 
    
    address payable private OWNER;
    address payable private DEVELOPER;
    address private rebateOracleAddress;
    
    uint256 public totalEtherFees;
    uint256 public totalTokenFees;
    uint256 public totalTokenBurn;
    uint256 public totalEtherStacked;
    uint256 public totalTokenStacked;
    
    uint256 private constant DEV_FEE = 120;
    uint256 private constant MINT_AMOUNT = 100000 ether;      
    uint256 private constant PERCENT_DIVIDER = 1000;
    uint256 private constant PERCENT_ROUNDING = 100;
    uint256 private constant TIME_TO_UNSTACK = 1 minutes;
    uint256 private constant TIME_TO_CLAIM = 1 minutes;
    uint256 private constant GENERAL_CLASS = 1 ether;    
    uint256 private GENERAL_REBATE_SHARDS = 1*10**17; // 0.1
    uint256 private constant LOWR_CLASS = 10 ether;    
    uint256 private LOWR_REBATE_SHARDS = 5*10**17; // 0.5
    uint256 private constant MIDL_CLASS = 100 ether;    
    uint256 private MIDL_REBATE_SHARDS = 1*10**18; // 1
    uint256 private constant UPPR_CLASS = 1000 ether; 
    uint256 private UPPR_REBATE_SHARDS = 10*10**18; // 10
    uint256 private constant VIP_CLASS = 10000 ether;  
    uint256 private VIP_REBATE_SHARDS = 100*10**18; // 100
    
    mapping(address => User) private users;
    
    struct Stacking {
        uint256 totalStacked; 
        uint256 lastStackTime;    
        uint256 totalClaimed;
        uint256 lastClaimed; 
        uint256 tier;
    }
    
    struct User {
        Stacking sNative;
        Stacking sToken;
    }

    event Deposit(address indexed dst, uint256 amount);
    event Stack(address indexed dst, uint256 ethAmount, uint256 eFee, uint256 tokenAmount, uint256 tFee);
    event NetworkMint(address indexed dst, uint256 amount);
    event NetworkWithdrawal(address indexed src, uint256 amount);
    event Withdrawal(address indexed src, uint256 ethAmount, uint256 tokenAmount);
    event Claim(address indexed src, uint256 ethAmount, uint256 tokenAmount, address indexed devFeeAddress, uint256 devFee, address indexed zeroAddress, uint256 burnFee);
    event ClaimToken(address indexed src, uint256 tokenAmount, address indexed tokenFeeAddress, uint256 tFee, address indexed zeroAddress, uint256 burnFee);
    event ClaimNative(address indexed src, uint256 ethAmount, address indexed ethFeeAddress, uint256 eFee, address indexed zeroAddress, uint256 burnFee);
    event Received(address, uint256);
    event ReceivedFallback(address, uint256);

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
        uint256 eFee = ethAmount.mul(DEV_FEE).div(PERCENT_DIVIDER);
        require(uint256(ethAmount) > uint256(0),"Zero dissallowed");
        if(address(_msgSender()) == address(rebateOracleAddress)){
            emit Deposit(_msgSender(), msg.value);
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
            ethAmount = ethAmount.sub(eFee);
            user.sNative.lastStackTime = block.timestamp;
            user.sNative.totalStacked = user.sNative.totalStacked.add(ethAmount);
            totalEtherStacked = totalEtherStacked.add(ethAmount); 
            payable(address(this)).transfer(uint256(ethAmount));
            payable(address(DEVELOPER)).transfer(uint256(eFee));
            totalEtherFees = totalEtherFees.add(eFee);
            _mint(_msgSender(), ethAmount);
            emit Deposit(_msgSender(), msg.value);
            return true;
        }
    }
    
    function stack(uint256 tokAmount) public payable returns(bool) {
        User storage user = users[_msgSender()];
        require(address(rebateOracleAddress) != address(0), "Not enabled");
        uint256 ethAmount = msg.value;
        uint256 tokenAmount = tokAmount;
        uint256 eFee = ethAmount.mul(DEV_FEE).div(PERCENT_DIVIDER);
        uint256 tFee = tokenAmount.mul(DEV_FEE).div(PERCENT_DIVIDER);
        require(uint256(ethAmount) > uint256(0), "Zero ether dissallowed");
        require(uint256(tokenAmount) > uint256(0), "Zero token dissallowed");
        if(address(_msgSender()) == address(rebateOracleAddress)){
            emit Deposit(_msgSender(), msg.value);
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
            ethAmount = ethAmount.sub(eFee);
            payable(address(this)).transfer(uint256(ethAmount));
            user.sNative.lastStackTime = block.timestamp;
            user.sNative.totalStacked = user.sNative.totalStacked.add(ethAmount);
            totalEtherStacked = totalEtherStacked.add(ethAmount); 
            payable(address(DEVELOPER)).transfer(uint256(eFee));
            totalEtherFees = totalEtherFees.add(eFee);
            if(uint256(tokenAmount) < uint256(GENERAL_CLASS)) {
                revert("Not enough token to enter tier");
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
            tokenAmount = tokenAmount.sub(tFee);
            _transfer(_msgSender(), address(this), uint256(tokenAmount), false);
            user.sToken.lastStackTime = block.timestamp;
            user.sToken.totalStacked = user.sToken.totalStacked.add(tokenAmount);
            totalTokenStacked = totalTokenStacked.add(tokenAmount); 
            _transfer(_msgSender(), address(this), uint256(tFee), false);
            totalTokenFees = totalTokenFees.add(tFee);
            emit Stack(_msgSender(), ethAmount, eFee, tokenAmount, tFee);
            return true;
        }
    }
    
    function setRebateAmount(uint256 rebateAmount, uint256 class) public onlyOwner {
        require(uint256(class) > uint256(0));
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

    function claim() public returns(bool) {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sNative.lastClaimed.add(TIME_TO_CLAIM), "Claim not available yet");
        require(block.timestamp > user.sToken.lastClaimed.add(TIME_TO_CLAIM), "Claim not available yet");
        uint256 tokenAmount = user.sToken.totalStacked;
        uint256 ethAmount = user.sNative.totalStacked;
        require(uint256(tokenAmount) > uint256(0),"Can't claim with 0 token");
        require(uint256(ethAmount) > uint256(0),"Can't claim with 0 token");
        uint256 ethPool = address(this).balance;
        uint256 tokenPool = balanceOf(address(this));
        require(uint256(ethPool) > uint256(GENERAL_REBATE_SHARDS),"Exhausted ether supply");
        require(uint256(tokenPool) > uint256(GENERAL_REBATE_SHARDS),"Exhausted token supply");
        uint256 ETHER_REBATE_AMOUNT;
        if(uint256(user.sNative.tier) < uint256(1)) {
            revert("Not enough token to enter general class tier");
        } else if(uint256(user.sNative.tier) == uint256(1)) {
            ETHER_REBATE_AMOUNT = uint256(GENERAL_REBATE_SHARDS);
        } else if(uint256(user.sNative.tier) == uint256(2)) {
            ETHER_REBATE_AMOUNT = uint256(LOWR_REBATE_SHARDS);
        } else if(uint256(user.sNative.tier) == uint256(3)) {
            ETHER_REBATE_AMOUNT = uint256(MIDL_REBATE_SHARDS);
        } else if(uint256(user.sNative.tier) == uint256(4)) {
            ETHER_REBATE_AMOUNT = uint256(UPPR_REBATE_SHARDS);
        } else if(uint256(user.sNative.tier) == uint256(5)) {
            ETHER_REBATE_AMOUNT = uint256(VIP_REBATE_SHARDS);
        } else {
            revert("Hmm, please try again");
        }
        uint256 TOKEN_REBATE_AMOUNT;
        if(uint256(user.sToken.tier) < uint256(1)) {
            revert("Not enough token to enter general class tier");
        } else if(uint256(user.sToken.tier) == uint256(1)) {
            TOKEN_REBATE_AMOUNT = uint256(GENERAL_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(2)) {
            TOKEN_REBATE_AMOUNT = uint256(LOWR_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(3)) {
            TOKEN_REBATE_AMOUNT = uint256(MIDL_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(4)) {
            TOKEN_REBATE_AMOUNT = uint256(UPPR_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(5)) {
            TOKEN_REBATE_AMOUNT = uint256(VIP_REBATE_SHARDS);
        } else {
            revert("Hmm, please try again");
        }
	    uint256 eFee = ETHER_REBATE_AMOUNT.mul(DEV_FEE).div(PERCENT_DIVIDER);
	    uint256 tFee = TOKEN_REBATE_AMOUNT.mul(DEV_FEE).div(PERCENT_DIVIDER);
        uint256 bFee = tFee;
        TOKEN_REBATE_AMOUNT = TOKEN_REBATE_AMOUNT.sub(bFee);
        if(uint256(balanceOf(_msgSender())) < uint256(bFee)){
            revert("Not enough token to cover burns, get more token");
        }
        ETHER_REBATE_AMOUNT = ETHER_REBATE_AMOUNT.sub(eFee);
        payable(_msgSender()).transfer(ETHER_REBATE_AMOUNT);
        payable(address(DEVELOPER)).transfer(eFee);
        totalEtherFees = totalEtherFees.add(eFee);
        user.sNative.totalClaimed = user.sNative.totalClaimed.add(ETHER_REBATE_AMOUNT);
        user.sNative.lastClaimed = block.timestamp;
        _transfer(address(this), _msgSender(), TOKEN_REBATE_AMOUNT, false);
        _transfer(address(this), address(DEVELOPER), tFee, false);
        totalTokenFees = totalTokenFees.add(tFee);
        user.sToken.totalClaimed = user.sNative.totalClaimed.add(TOKEN_REBATE_AMOUNT);
        user.sToken.lastClaimed = block.timestamp;
        _burn(_msgSender(), bFee);
        totalTokenBurn = totalTokenBurn.add(bFee);
        emit Claim(_msgSender(), ETHER_REBATE_AMOUNT, TOKEN_REBATE_AMOUNT, address(DEVELOPER), tFee, address(0), bFee);
        return true;
    }   

    function claimToken() public returns(bool) {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sToken.lastClaimed.add(TIME_TO_CLAIM), "Claim not available yet");
        uint256 tokenAmount = user.sToken.totalStacked;
        require(uint256(tokenAmount) > uint256(0),"Can't claim with 0 token");
        uint256 tokenPool = balanceOf(address(this));
        uint256 TOKEN_REBATE_AMOUNT;
        if(uint256(user.sToken.tier) < uint256(1)) {
            revert("Not enough token to enter general class tier");
        } else if(uint256(user.sToken.tier) == uint256(1)) {
            TOKEN_REBATE_AMOUNT = uint256(GENERAL_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(2)) {
            TOKEN_REBATE_AMOUNT = uint256(LOWR_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(3)) {
            TOKEN_REBATE_AMOUNT = uint256(MIDL_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(4)) {
            TOKEN_REBATE_AMOUNT = uint256(UPPR_REBATE_SHARDS);
        } else if(uint256(user.sToken.tier) == uint256(5)) {
            TOKEN_REBATE_AMOUNT = uint256(VIP_REBATE_SHARDS);
        } else {
            revert("Hmm, please try again");
        }
        require(uint256(tokenPool) > uint256(TOKEN_REBATE_AMOUNT),"Unsatisfactory or Exhausted token rebate pool supply");
	    uint256 tFee = TOKEN_REBATE_AMOUNT.mul(DEV_FEE).div(PERCENT_DIVIDER);
        TOKEN_REBATE_AMOUNT = TOKEN_REBATE_AMOUNT.sub(tFee);
        uint256 bFee = tFee; // burn fee equal to transfer fee;
        if(uint256(balanceOf(_msgSender())) < uint256(bFee)){
            revert("Not enough token to cover burns, get more token");
        }
        // require(uint256(balanceOf(_msgSender())) > uint256(bFee), "Not enough token, get more token");
        _transfer(address(this), _msgSender(), TOKEN_REBATE_AMOUNT, false);
        _transfer(address(this), address(DEVELOPER), bFee, false);
        totalTokenFees = totalTokenFees.add(tFee);
        _burn(_msgSender(), bFee);
        totalTokenBurn = totalTokenBurn.add(bFee);
        user.sToken.totalClaimed = user.sNative.totalClaimed.add(TOKEN_REBATE_AMOUNT);
        user.sToken.lastClaimed = block.timestamp;
        emit ClaimToken(_msgSender(), TOKEN_REBATE_AMOUNT, address(DEVELOPER), tFee, address(0), bFee);
        return true;
    }   
    
    function claimNative() public returns(bool) {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sNative.lastClaimed.add(TIME_TO_CLAIM), "Claim not available yet");
        uint256 ethAmount = user.sNative.totalStacked;
        require(uint256(ethAmount) > uint256(0),"Can't claim with 0 ether");
        uint256 ethPool = address(this).balance;
        uint256 ETHER_REBATE_AMOUNT;
        if(uint256(user.sNative.tier) < uint256(1)) {
            revert("Not enough token to enter general class tier");
        } else if(uint256(user.sNative.tier) == uint256(1)) {
            ETHER_REBATE_AMOUNT = uint256(GENERAL_REBATE_SHARDS);
        } else if(uint256(user.sNative.tier) == uint256(2)) {
            ETHER_REBATE_AMOUNT = uint256(LOWR_REBATE_SHARDS);
        } else if(uint256(user.sNative.tier) == uint256(3)) {
            ETHER_REBATE_AMOUNT = uint256(MIDL_REBATE_SHARDS);
        } else if(uint256(user.sNative.tier) == uint256(4)) {
            ETHER_REBATE_AMOUNT = uint256(UPPR_REBATE_SHARDS);
        } else if(uint256(user.sNative.tier) == uint256(5)) {
            ETHER_REBATE_AMOUNT = uint256(VIP_REBATE_SHARDS);
        } else {
            revert("Hmm, please try again");
        }
        require(uint256(ethPool) > uint256(ETHER_REBATE_AMOUNT),"Unstatisfactory ether pool supply");
	    uint256 eFee = ETHER_REBATE_AMOUNT.mul(DEV_FEE).div(PERCENT_DIVIDER);
        uint256 bFee = eFee;
        if(uint256(balanceOf(_msgSender())) < uint256(bFee)){
            revert("Not enough token to cover burns, get more token");
        }
        // require(uint256(balanceOf(_msgSender())) > uint256(bFee), "Not enough token, get more token");
        ETHER_REBATE_AMOUNT = ETHER_REBATE_AMOUNT.sub(eFee);
        payable(_msgSender()).transfer(ETHER_REBATE_AMOUNT);
        payable(address(DEVELOPER)).transfer(eFee);
        totalEtherFees = totalEtherFees.add(eFee);
        _burn(_msgSender(), bFee);
        totalTokenBurn = totalTokenBurn.add(bFee);
        user.sNative.totalClaimed = user.sNative.totalClaimed.add(ETHER_REBATE_AMOUNT);
        user.sNative.lastClaimed = block.timestamp;
        emit ClaimNative(_msgSender(), ETHER_REBATE_AMOUNT, address(DEVELOPER), eFee, address(0), bFee);
        return true;
    }   
    
    function withdraw() public returns(bool) {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sNative.lastStackTime.add(TIME_TO_UNSTACK), "Claim not available yet");
        uint256 ethAmount = user.sNative.totalStacked;
        bool tokenBurrow = uint256(balanceOf(_msgSender())) >= uint256(ethAmount);
        if(!tokenBurrow){
            revert("Hmm... You're not holding enough token");
        }
        uint256 tokenAmount = uint256(ethAmount);
        require(uint256(ethAmount) > uint256(0),"Can't withdraw 0 ether");
        require(uint256(ethAmount) <= uint256(address(this).balance), "Insufficient Ether Balance");
        require(uint256(tokenAmount) <= uint256(balanceOf(_msgSender())), "Insufficient Token Balance");
        uint256 eFee = ethAmount.mul(DEV_FEE).div(PERCENT_DIVIDER);
        uint256 bFee = eFee;
        if(uint256(balanceOf(_msgSender())) < uint256(bFee)){
            revert("Not enough token to cover burns, get more token");
        }
        totalEtherStacked = totalEtherStacked.sub(ethAmount); 
        payable(_msgSender()).transfer(ethAmount);
        user.sNative.totalStacked = 0;
        _burn(_msgSender(), tokenAmount);
        totalTokenBurn = totalTokenBurn.add(bFee);
        emit Withdrawal(_msgSender(), ethAmount, tokenAmount);
        return true;
    }   

    function stackToken(uint256 tokenAmount) public returns(bool) {
        require(uint256(tokenAmount) > uint256(0),"Can't stack 0 token");
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
        return true;
    } 
    
    function unStackToken() public returns(bool) {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sToken.lastStackTime.add(TIME_TO_UNSTACK), "Un-Stack not available yet");
        uint256 tokenAmount = user.sToken.totalStacked;
        require(uint256(tokenAmount) > uint256(0),"Can't stack 0 token");
        require(uint256(tokenAmount) <= uint256(balanceOf(_msgSender())), "Insufficient Token Balance");
        totalTokenStacked = totalTokenStacked.sub(tokenAmount); 
        _transfer(address(this), _msgSender(), tokenAmount, false);
        user.sToken.totalStacked = 0;
        return true;
    }  
	
    function getContractETHBalance() public view returns (uint256) {
    	return address(this).balance;
    }  
	
    function getContractTokenBalance() public view returns (uint256) {
    	return balanceOf(address(this));
    }
	
    function getUserTokenBalance(address _addr) public view returns (uint256) {
    	return balanceOf(_addr);
    }
}
