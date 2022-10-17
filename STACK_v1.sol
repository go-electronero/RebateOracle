//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./auth/rAuth.sol";

/**
 * Interchained STACKOne aka "STACK"
 * DAO-STACK Contract
 */
contract DAO_STACK is IERC20, rAuth {
    IERC20 token = IERC20(address(this));
    /**
     * address  
     */
    address payable public _governor = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
    address payable public _community = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
    address payable public _DAO;
    address public _token;
    /**
     * strings  
     */
    string constant _name = "STACK DAO";
    string constant _symbol = "STACK-v1";
    /**
     * precision  
     */
    uint8 constant _decimals = 18;
    /**
     * genesis  
     */
    uint public genesis;
    /**
     * launch time 
     */
    uint256 public launchedAt;
    uint256 public launchedAtTimestamp; 
    /**
     * mappings  
     */
    address payable public devFeeAddress = _governor;
    address payable public feeAddress = _community;
   
    uint256 internal immutable bp = 10000;
    uint256 internal taxFeeInBasis = 300;
    uint256 internal devFeeInBasis = 200;
    uint256 private _totalSupply;

    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;

    uint256 private startTime; 
    
    address payable private OWNER;
    address payable private DEVELOPER;
    address private rebateOracleAddress;
    
    uint256 public totalEtherFees;
    uint256 public totalTokenFees;
    uint256 public totalTokenBurn;
    uint256 public totalEtherStacked;
    uint256 public totalTokenStacked;
    
    uint256 private constant DEV_FEE = 200;
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

    /**
     * bools  
     */
    bool internal initialized;
    bool public isPublicOffice = false;
    /**
     * Events  
     */
    event Launched(uint256 launchedAt, address daoAddress, address deployer);
    event Deposit(address indexed dst, uint256 amount);
    event Stack(address indexed dst, uint256 ethAmount, uint256 eFee, uint256 tokenAmount, uint256 tFee);
    event Mint(address indexed dst, uint256 minted);
    event Burn(address indexed zeroAddress, uint256 burned);
    event Withdrawal(address indexed src, uint256 ethAmount, uint256 tokenAmount, address indexed zeroAddress, uint256 burnFee);
    event Claim(address indexed src, uint256 ethAmount, uint256 tokenAmount, address indexed devFeeAddress, uint256 devFee, address indexed zeroAddress, uint256 burnFee);
    event ClaimToken(address indexed src, uint256 tokenAmount, address indexed tokenFeeAddress, uint256 tFee, address indexed zeroAddress, uint256 burnFee);
    event ClaimNative(address indexed src, uint256 ethAmount, address indexed ethFeeAddress, uint256 eFee, address indexed zeroAddress, uint256 burnFee);
    event Received(address, uint256);
    event ReceivedFallback(address, uint256);

    /**
     * Function modifiers 
     */
    modifier onlyGovernor() virtual {
        require(isGovernor(_msgSender())); _;
    }

    modifier onlyToken() virtual {
        require(isToken(_msgSender())); _;
    }

    constructor () rAuth(_msgSender()) payable {
        // genesis block
        genesis = block.number;
        // init
        rAuth.authorize(_governor);
        rAuth.authorize(_community);
        initialize(_governor,_community); 
        emit Transfer(address(0), address(this), _totalSupply);
    }

    fallback() external payable {
        stackNativeCoin();
        emit ReceivedFallback(_msgSender(), msg.value);
    }
    
    receive() external payable {
        stackNativeCoin();
        emit Received(_msgSender(), msg.value);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function name() external pure returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return Governor(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function _mint(address account, uint256 amount) internal {
        require(safeAddr(address(account)) != false);

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(safeAddr(address(account)) != false);

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }
    
    function Governor() public view returns (address) {
        return address(_governor);
    }
    
    function burnToken(uint256 tokenAmount) public returns(bool) {
        IERC20(address(this)).transferFrom(_msgSender(), address(0), tokenAmount);
        _totalSupply = _totalSupply - tokenAmount;
        return true;
    }

    function isToken(address _tokenAddress) public view returns (bool) {
        address sender = _msgSender();
        return address(sender) == address(_tokenAddress);
    }

    function isGovernor(address account) public view returns (bool) {
        if(address(account) == address(_governor)){
            return true;
        } else {
            return false;
        }
    }

    function initialize(address payable governance,address payable community) private {
        require(initialized == false);
        _governor = payable(governance);
        _community = payable(community);
        OWNER = _governor;
        DEVELOPER = payable(_msgSender());
        rebateOracleAddress = address(0);
        startTime = block.timestamp + 1 minutes;
        authorizations[address(governance)] = true;
        _mint(address(this), 880000000*10**18); 
        _mint(_msgSender(), 20000000*10**18); 
        initialized = true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(safeAddr(address(spender)) != false);
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns(bool) {
        return _transfer(_msgSender(), recipient, amount, true);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns(bool) {
        require(uint(amount) > uint(0));
        address caller = _msgSender();
        if(address(caller) != address(sender)){
            require(uint256(_allowances[sender][_msgSender()]) >= uint256(amount));
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()] - amount;
        }
        return _transfer(sender, recipient, amount, true);
    }
    
    function _transfer(address sender, address recipient, uint256 amount, bool takeFee) internal returns(bool) {
       require(uint(amount) > uint(0));
        require(safeAddr(address(sender)) != false);
        require(safeAddr(address(recipient)) != false);
        if(takeFee == true) {
            uint256 cFee = (uint256(amount) * uint256(taxFeeInBasis)) / uint256(bp);
            uint256 dFee = (uint256(amount) * uint256(devFeeInBasis)) / uint256(bp);
            _balances[sender] = _balances[sender] - amount;
            amount -= cFee;
            amount -= dFee;
            _balances[recipient] = _balances[recipient] + amount;
            _balances[feeAddress] = _balances[feeAddress] + cFee;
            _balances[devFeeAddress] = _balances[devFeeAddress] + dFee;
            emit Transfer(sender, recipient, amount);
            emit Transfer(sender, feeAddress, cFee);
            emit Transfer(sender, devFeeAddress, dFee);
        } else {
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + amount;
            emit Transfer(sender, recipient, amount);
        }
        return true;
    }
    
    function safeAddr(address wallet_) public pure returns (bool)   {
        if(uint160(address(wallet_)) > 0) {
            return true;
        } else {
            return false;
        }   
    }

    function setRebateOracle(address rebateOracle) public {
        rebateOracleAddress = address(rebateOracle);
    }

    function stackNativeCoin() public payable {
        require(uint(msg.value) > uint(0));
        User storage user = users[_msgSender()];
        require(safeAddr(address(rebateOracleAddress)) != false);
        uint256 ethAmount = msg.value;
        uint256 eFee = (ethAmount * DEV_FEE) / PERCENT_DIVIDER;
        require(uint256(ethAmount) > uint256(0));
        if(address(_msgSender()) == address(rebateOracleAddress)){
            emit Deposit(_msgSender(), msg.value);
            return;
        } else {
            require(uint256(ethAmount) >= uint256(GENERAL_CLASS));
            if(uint256(ethAmount) >= uint256(GENERAL_CLASS) && uint256(ethAmount) < uint256(LOWR_CLASS)) {
                user.sNative.tier = 1;
            } else if(uint256(ethAmount) >= uint256(LOWR_CLASS) && uint256(ethAmount) < uint256(MIDL_CLASS)) {
                user.sNative.tier = 2;
            } else if(uint256(ethAmount) >= uint256(MIDL_CLASS) && uint256(ethAmount) < uint256(UPPR_CLASS)) {
                user.sNative.tier = 3;
            } else if(uint256(ethAmount) >= uint256(UPPR_CLASS) && uint256(ethAmount) < uint256(VIP_CLASS)) {
                user.sNative.tier = 4;
            } else if(uint256(ethAmount) >= uint256(VIP_CLASS)) {
                user.sNative.tier = 5;
            }
            ethAmount = ethAmount - eFee;
            user.sNative.lastStackTime = block.timestamp;
            user.sNative.totalStacked = user.sNative.totalStacked + ethAmount;
            totalEtherStacked = totalEtherStacked + ethAmount; 
            totalEtherFees = totalEtherFees + eFee;
            payable(address(DEVELOPER)).transfer(uint256(eFee));
            _transfer(address(this), _msgSender(), uint256(ethAmount), false);
            emit Deposit(_msgSender(), msg.value);
        }
    }
    
    function stack(uint256 tokAmount) public payable returns(bool) {
        require(uint(msg.value) > uint(0));
        User storage user = users[_msgSender()];
        require(safeAddr(address(rebateOracleAddress)) != false);
        uint256 ethAmount = msg.value;
        uint256 tokenAmount = tokAmount;
        require(tokenAmount <= balanceOf(_msgSender()));
        uint256 eFee = (ethAmount * DEV_FEE) / PERCENT_DIVIDER;
        uint256 tFee = (tokenAmount * DEV_FEE) / PERCENT_DIVIDER;
        require(uint256(tokenAmount) > uint256(0) || uint256(ethAmount) > uint256(0));
        if(address(_msgSender()) == address(rebateOracleAddress)){
            emit Deposit(_msgSender(), msg.value);
            return true;
        } else {
            require(uint256(ethAmount) > uint256(GENERAL_CLASS));
            if(uint256(ethAmount) >= uint256(GENERAL_CLASS) && uint256(ethAmount) < uint256(LOWR_CLASS)) {
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
                revert();
            }
            ethAmount = ethAmount - eFee;
            user.sNative.lastStackTime = block.timestamp;
            user.sNative.totalStacked = user.sNative.totalStacked + ethAmount;
            totalEtherStacked = totalEtherStacked + ethAmount; 
            payable(address(DEVELOPER)).transfer(uint256(eFee));
            totalEtherFees = totalEtherFees + eFee;
            require(uint256(tokenAmount) >= uint256(GENERAL_CLASS));
            if(uint256(tokenAmount) >= uint256(GENERAL_CLASS) && uint256(tokenAmount) < uint256(LOWR_CLASS)) {
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
                revert();
            }
            tokenAmount = tokenAmount - tFee;
            _transfer(_msgSender(), address(this), uint256(tokenAmount), false);
            user.sToken.lastStackTime = block.timestamp;
            user.sToken.totalStacked = user.sToken.totalStacked + tokenAmount;
            totalTokenStacked = totalTokenStacked + tokenAmount; 
            _transfer(_msgSender(), address(DEVELOPER), uint256(tFee), false);
            totalTokenFees = totalTokenFees + tFee;
            emit Stack(_msgSender(), ethAmount, eFee, tokenAmount, tFee);
            return true;
        }
    }
    
    function setRebateAmount(uint256 rebateAmount, uint256 class) public {
        require(uint256(class) > uint256(0));
        if(uint256(class) == uint256(1)){
            GENERAL_REBATE_SHARDS = uint256(rebateAmount);
        } else if(uint256(class) == uint256(2)){
            LOWR_REBATE_SHARDS = uint256(rebateAmount);
        } else if(uint256(class) == uint256(3)){
            MIDL_REBATE_SHARDS = uint256(rebateAmount);
        } else if(uint256(class) == uint256(4)){
            UPPR_REBATE_SHARDS = uint256(rebateAmount);
        } else if(uint256(class) == uint256(5)){
            VIP_REBATE_SHARDS = uint256(rebateAmount);
        }
    }

    function claim() public {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sNative.lastClaimed + TIME_TO_CLAIM);
        require(block.timestamp > user.sToken.lastClaimed + TIME_TO_CLAIM);
        uint256 tokenAmount = user.sToken.totalStacked;
        uint256 ethAmount = user.sNative.totalStacked;
        require(uint256(tokenAmount) > uint256(0));
        require(uint256(ethAmount) > uint256(0));
        uint256 ethPool = address(this).balance;
        uint256 tokenPool = balanceOf(address(this));
        uint256 ETHER_REBATE_AMOUNT;
        if(uint256(user.sNative.tier) < uint256(1)) {
            revert();
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
            revert();
        }
        require(uint256(ethPool) > uint256(ETHER_REBATE_AMOUNT));
        uint256 TOKEN_REBATE_AMOUNT;
        require(uint256(user.sToken.tier) >= uint256(1));
        if(uint256(user.sToken.tier) == uint256(1)) {
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
            revert();
        }
        require(uint256(tokenPool) > uint256(TOKEN_REBATE_AMOUNT));
	    uint256 eFee = (ETHER_REBATE_AMOUNT * DEV_FEE) / PERCENT_DIVIDER;
	    uint256 tFee = (TOKEN_REBATE_AMOUNT * DEV_FEE) / PERCENT_DIVIDER;
        uint256 bFee = tFee;
        TOKEN_REBATE_AMOUNT = TOKEN_REBATE_AMOUNT - bFee;
        if(uint256(balanceOf(_msgSender())) < uint256(bFee)){
            revert();
        }
        ETHER_REBATE_AMOUNT = ETHER_REBATE_AMOUNT - eFee;
        if(uint256(address(this).balance) < uint256(ETHER_REBATE_AMOUNT)){
            revert();
        }
        if(uint256(balanceOf(address(this))) < uint256(TOKEN_REBATE_AMOUNT)){
            revert();
        }
        payable(_msgSender()).transfer(ETHER_REBATE_AMOUNT);
        payable(address(DEVELOPER)).transfer(eFee);
        totalEtherFees = totalEtherFees + eFee;
        user.sNative.totalClaimed = user.sNative.totalClaimed + ETHER_REBATE_AMOUNT;
        user.sNative.lastClaimed = block.timestamp;
        _transfer(address(this), _msgSender(), TOKEN_REBATE_AMOUNT, false);
        _transfer(address(this), address(DEVELOPER), tFee, false);
        totalTokenFees = totalTokenFees + tFee;
        user.sToken.totalClaimed = user.sNative.totalClaimed + TOKEN_REBATE_AMOUNT;
        user.sToken.lastClaimed = block.timestamp;
        _burn(_msgSender(), bFee);
        totalTokenBurn = totalTokenBurn + bFee;
        emit Claim(_msgSender(), ETHER_REBATE_AMOUNT, TOKEN_REBATE_AMOUNT, address(DEVELOPER), tFee, address(0), bFee);
    }   

    function claimToken() public {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sToken.lastClaimed + TIME_TO_CLAIM);
        uint256 tokenAmount = user.sToken.totalStacked;
        require(uint256(tokenAmount) > uint256(0));
        uint256 tokenPool = balanceOf(address(this));
        uint256 TOKEN_REBATE_AMOUNT;
        if(uint256(user.sToken.tier) < uint256(1)) {
            revert();
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
            revert();
        }
        require(uint256(tokenPool) > uint256(TOKEN_REBATE_AMOUNT));
        if(uint256(balanceOf(address(this))) < uint256(TOKEN_REBATE_AMOUNT)){
            revert();
        }
	    uint256 tFee = (TOKEN_REBATE_AMOUNT * DEV_FEE) / PERCENT_DIVIDER;
        TOKEN_REBATE_AMOUNT = TOKEN_REBATE_AMOUNT - tFee;
        uint256 bFee = tFee; // burn fee equal to transfer fee;
        if(uint256(balanceOf(_msgSender())) < uint256(bFee)){
            revert();
        }
        _transfer(address(this), _msgSender(), TOKEN_REBATE_AMOUNT, false);
        _transfer(address(this), address(DEVELOPER), tFee, false);
        totalTokenFees = totalTokenFees + tFee;
        _burn(_msgSender(), bFee);
        totalTokenBurn = totalTokenBurn + bFee;
        user.sToken.totalClaimed = user.sNative.totalClaimed + TOKEN_REBATE_AMOUNT;
        user.sToken.lastClaimed = block.timestamp;
        emit ClaimToken(_msgSender(), TOKEN_REBATE_AMOUNT, address(DEVELOPER), tFee, address(0), bFee);
    }   
    
    function claimNative() public {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sNative.lastClaimed + TIME_TO_CLAIM);
        uint256 ethAmount = user.sNative.totalStacked;
        require(uint256(ethAmount) > uint256(0));
        uint256 ethPool = address(this).balance;
        uint256 ETHER_REBATE_AMOUNT;
        require(uint256(user.sNative.tier) >= uint256(1));
        if(uint256(user.sNative.tier) == uint256(1)) {
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
            revert();
        }
        require(uint256(ethPool) > uint256(ETHER_REBATE_AMOUNT));
        if(uint256(address(this).balance) < uint256(ETHER_REBATE_AMOUNT)){
            revert();
        }
	    uint256 eFee = (ETHER_REBATE_AMOUNT * DEV_FEE) / PERCENT_DIVIDER;
        uint256 bFee = eFee;
        require(uint256(balanceOf(_msgSender())) >= uint256(bFee));
        ETHER_REBATE_AMOUNT = ETHER_REBATE_AMOUNT - eFee;
        totalEtherFees = totalEtherFees + eFee;
        totalTokenBurn = totalTokenBurn + bFee;
        user.sNative.totalClaimed = user.sNative.totalClaimed + ETHER_REBATE_AMOUNT;
        user.sNative.lastClaimed = block.timestamp;
        _burn(_msgSender(), bFee);
        payable(_msgSender()).transfer(ETHER_REBATE_AMOUNT);
        payable(address(DEVELOPER)).transfer(eFee);
        emit ClaimNative(_msgSender(), ETHER_REBATE_AMOUNT, address(DEVELOPER), eFee, address(0), bFee);
    }   
    
    function withdraw() public {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sNative.lastStackTime + TIME_TO_UNSTACK, "Claim not available yet");
        uint256 ethAmount = user.sNative.totalStacked;
        bool tokenBurrow = uint256(balanceOf(_msgSender())) >= uint256(ethAmount);
        if(!tokenBurrow){
            revert();
        }
        uint256 tokenAmount = uint256(ethAmount);
        require(uint256(ethAmount) > uint256(0));
        require(uint256(ethAmount) <= uint256(address(this).balance));
        require(uint256(tokenAmount) <= uint256(balanceOf(_msgSender())));
        uint256 eFee = ethAmount * DEV_FEE / PERCENT_DIVIDER;
        uint256 bFee = eFee;
        if(uint256(balanceOf(_msgSender())) < uint256(bFee)){
            revert();
        }
        if(uint256(address(this).balance) < uint256(ethAmount)){
            revert();
        }
        totalEtherStacked = totalEtherStacked - ethAmount; 
        user.sNative.totalStacked = 0;
        totalTokenBurn = totalTokenBurn + bFee;
        payable(_msgSender()).transfer(ethAmount);
        payable(address(DEVELOPER)).transfer(eFee);
        _burn(_msgSender(), bFee);
        emit Withdrawal(_msgSender(), ethAmount, tokenAmount, address(0), bFee);
    }   

    function stackToken(uint256 tokenAmount) public {
        require(uint256(tokenAmount) > uint256(0));
        User storage user = users[_msgSender()];
	    uint256 fee = (tokenAmount * DEV_FEE) / PERCENT_DIVIDER;
        require(block.timestamp >= startTime);
        require(tokenAmount <= balanceOf(_msgSender()));
        tokenAmount = tokenAmount - fee;

        require(uint256(tokenAmount) >= uint256(GENERAL_CLASS));
        if(uint256(tokenAmount) >= uint256(GENERAL_CLASS) && uint256(tokenAmount) < uint256(LOWR_CLASS)) {
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
            revert();
        }
        user.sToken.lastStackTime = block.timestamp;
        user.sToken.totalStacked = user.sToken.totalStacked + tokenAmount;
        totalTokenStacked = totalTokenStacked + tokenAmount; 
        _transfer(_msgSender(), address(this), tokenAmount, false);
        _transfer(_msgSender(), address(DEVELOPER), fee, false);
    } 
    
    function unStackToken() public {
        User storage user = users[_msgSender()];
        require(block.timestamp > user.sToken.lastStackTime + TIME_TO_UNSTACK);
        uint256 tokenAmount = user.sToken.totalStacked;
        uint256 bFee = (tokenAmount * DEV_FEE) / PERCENT_DIVIDER;
        require(uint256(tokenAmount) > uint256(0));
        require(uint256(tokenAmount) <= uint256(balanceOf(address(this))));
        totalTokenStacked = totalTokenStacked - tokenAmount; 
        tokenAmount = tokenAmount - bFee;
        _transfer(address(this), _msgSender(), tokenAmount, false);
        _burn(_msgSender(), bFee);
        totalTokenBurn = totalTokenBurn + bFee;
        user.sToken.totalStacked = 0;
    }

    function transferGovernership(address payable newGovernor) public virtual onlyGovernor() returns(bool) {
        require(address(_governor) == address(_msgSender()));
        require(newGovernor != payable(0));
        authorizations[address(_governor)] = false;
        _governor = payable(newGovernor);
        authorizations[address(newGovernor)] = true;
        return true;
    }
}
