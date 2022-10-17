//SPDX-License-Identifier: MIT
//  ▄▄ • ▄▄▄ .• ▌ ▄ ·. ·▄▄▄▄   ▄▄▄·       
// ▐█ ▀ ▪▀▄.▀··██ ▐███▪██▪ ██ ▐█ ▀█ ▪     
// ▄█ ▀█▄▐▀▀▪▄▐█ ▌▐▌▐█·▐█· ▐█▌▄█▀▀█  ▄█▀▄ 
// ▐█▄▪▐█▐█▄▄▌██ ██▌▐█▌██. ██ ▐█ ▪▐▌▐█▌.▐▌
// ·▀▀▀▀  ▀▀▀ ▀▀  █▪▀▀▀▀▀▀▀▀•  ▀  ▀  ▀█▄▀▪
pragma solidity 0.8.13;

import "./auth/rAuth.sol";

contract ERC1030 is IERC20, rAuth {

    IERC20 token;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string internal _name;
    string internal _symbol;

    uint8 internal _decimals;
    uint256 internal _totalSupply;
    uint256 internal _supplyLimit;
    uint256 internal _maxSupply;

    event Minted(address indexed src, uint amount);
    event Burned(address indexed src, uint amount);

    constructor(string memory _nam, string memory _sym, uint8 _dec, uint256 genesis) rAuth(payable(msg.sender)) {
        token = IERC20(address(this));
        if(keccak256(abi.encodePacked(_nam)) != keccak256(abi.encodePacked(string("na")))){
            _name = _nam;
        } else {
            _name = unicode"Gem DAO 💎";
        }
        if(keccak256(abi.encodePacked(_sym)) != keccak256(abi.encodePacked(string("na")))){
            _symbol = _sym;
        } else {
            _symbol = unicode"💎";
        }
        if(keccak256(abi.encodePacked(_dec)) != keccak256(abi.encodePacked(uint8(0)))){
            _decimals = uint8(_dec);
        } else {
            _decimals = uint8(18);
        }
        if(keccak256(abi.encodePacked(genesis)) != keccak256(abi.encodePacked(uint256(0)))){
            require(genesis>0);
            _mint(payable(msg.sender), genesis*(10**_decimals));  
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function availableSupply() public virtual returns (uint256) {
        return _totalSupply;
    }    

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC1030: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from,address to,uint256 amount) internal virtual {
        require(from != address(0), "ERC1030: transfer from the zero address");
        require(to != address(0), "ERC1030: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC1030: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC1030: mint to the zero address");
        require((_totalSupply + amount) <= _maxSupply, "ERC1030: mint surpasses supply limitations");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        emit Minted(address(account), amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) public virtual {
        require(account != address(0), "ERC1030: burn from the zero address");
        address owner = _msgSender();
        require(owner == address(account), "ERC1030: Can't burn from someone elses wallet");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC1030: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        require(decreaseAllowance(address(account), amount));
        emit Transfer(account, address(0), amount);
        emit Burned(address(account), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0));
        require(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner,address spender,uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount);
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from,address to,uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from,address to,uint256 amount) internal virtual {}

    function getOwner() external view returns(address){
        return owner;
    }

}

contract gemDAO is ERC1030 {
    
    address payable private ADMIN;

    // alter name, and symbol
    string public _NAME = unicode"Gem DAO";
    string public _SYMBOL = unicode"💎 DAO";

    mapping (address => mapping (address => uint256)) public debt_limit;
    mapping (address => mapping (address => uint256)) public debt;
    mapping (address => uint256) public _NOMvotes;
    mapping (address => uint256) public _OPSvotes;
    mapping (address => uint256) public _CREDITvotes;
    mapping (address => uint256) public _UNITvotes;
    mapping (address => uint256) public _BURNvotes;

    // establish the DAO
    uint public daoGenesisBlock;
    // token precision
    uint8 public _DECIMALS = 18;
    // mint genesis 
    uint256 public _GENESIS = 0;
    // establish DAO poll stats/caps
    // nominations, debt, governance, burn poll votes tally
    uint256 public ttlDAO_NPV;
    uint256 public ttlDAO_DPV;
    uint256 public ttlDAO_GPV;
    uint256 public ttlDAO_BPV;
    // lucky number
    uint256 public luck = 7;
    // poll caps
    uint256 public nomPollCap;
    uint256 public propPollCap;
    uint256 public govPollCap;
    uint256 public superPollCap;
    uint256 public precisionPollCap;
    uint256 public debtPollCap;
    uint256 public burnPollCap;
    // nominations poll count/limits 
    bool public nomPollStarted = false;
    bool public nomPollEnded = false;
    uint public nomPollGenesis = 0;
    uint public nomPolling = 4 weeks;
    uint public nomPollEnd = 0;
    // poll count/limits 
    bool public pollStarted = false;
    bool public pollEnded = false;
    uint public pollGenesis = 0;
    uint public polling = 4 weeks;
    uint public pollEnd = 0;
    // dao limits
    uint256 public debt_basis = 10;
    uint256 public _burnLimit;

    event Genesis(uint genesisBlock, uint genesisTimestamp);
    event Deposit(address indexed dst, uint amount);
    event NetworkMint(address indexed dst, uint amount);
    event NetworkWithdrawal(address indexed src, uint amount);
    event Withdrawal(address indexed src, uint amount);
    event Received(address, uint);
    event ReceivedFallback(address, uint);

    modifier onlyOperator {
        require(msg.sender == ADMIN);
        _;
    } 

    constructor() ERC1030(string(_NAME), string(_SYMBOL), uint8(_DECIMALS), uint256(_GENESIS)) {
        daoGenesisBlock = block.number;
        ADMIN = payable(msg.sender);
        nomPollStarted = false;
        nomPollEnded = false;
        nomPollGenesis = 0;
        nomPolling = 4 weeks;
        nomPollEnd = pollEnded ? (pollGenesis + polling) : 0;
        pollStarted = false;
        pollEnded = false;
        pollGenesis = 0;
        polling = 4 weeks;
        pollEnd = pollEnded ? (pollGenesis + polling) : 0;
        debt_basis = 10;
        emit Genesis(block.number, block.timestamp);
    }       
    
    fallback() external payable {
        deposit();
        emit ReceivedFallback(_msgSender(), msg.value);
    }
    
    receive() external payable {
        deposit();
        emit Received(_msgSender(), msg.value);
    }

    function getDAOGenesis() public view returns(uint) {
        return daoGenesisBlock;
    }

    function getDAONomPollGenesis() public view returns(uint) {
        return nomPollGenesis;
    }

    function getDAOPollGenesis() public view returns(uint) {
        return pollGenesis;
    }

    function startNomPolls() internal virtual returns(uint) {
        nomPollStarted = true;
        nomPollGenesis = block.timestamp;
        return getDAONomPollGenesis();
    }

    function endNomPolls(uint pollTally, uint daoNomTally) internal virtual returns(bool) {
        nomPollEnded = true;
        nomPollEnd = block.timestamp;
        setPollToll(pollTally * daoNomTally);
        return nomPollEnded;
    }
    
    function pollDAOGovernanceNoms(address _nominee) public returns(bool) {
        require((_msgSender() != _nominee));
        require(getDaoBlock() == 0);
        uint DAO_nom_genesis = nomPollGenesis;
        if(nomPollStarted == false){
            DAO_nom_genesis = startNomPolls();
        } else {
            DAO_nom_genesis = getDAONomPollGenesis();
        }
        require(DAO_nom_genesis > 0);
        if(!nomPollEnded && block.timestamp < (nomPollGenesis + nomPolling)) {
            nomPollCap++;
            _NOMvotes[_nominee]++;
            // with 7 votes, a lucky nominee is granted a debt limit increase 
            // _creditExt should equal to balance divided by 10000
            if(_NOMvotes[_nominee] == luck){
                ttlDAO_NPV++;
                uint256 _creditExt = address(this).balance / (debt_basis * (debt_basis*(debt_basis*debt_basis)));
                increaseDebtLimit(address(this), address(_nominee), _creditExt);
            }
        } else if(!nomPollEnded && block.timestamp > (nomPollGenesis + nomPolling)){
            return endNomPolls(nomPollCap , ttlDAO_NPV);
        } else {
            return true;
        }
        return true;
    }

    function claimNomRebate(uint256 amount) public {
        require(_NOMvotes[_msgSender()] >= luck);
        require(nomPollEnded == true);
        uint256 local_debt_limit = getDAODebtLimit(address(this), _msgSender());
        require(local_debt_limit > 0);
        require(amount <= local_debt_limit);
        reduceDebtLimit(address(this), _msgSender(), amount);
        if(amount > IERC20(address(this)).balanceOf(address(this))){
            _mint(_msgSender(), amount);
        } else {
            IERC20(address(this)).transferFrom(address(this), _msgSender(), amount);
        }
        increaseDebt(address(this), _msgSender(), amount);
        emit NetworkMint(address(this), amount);
    }

    function startPolls() internal virtual returns(uint) {
        pollStarted = true;
        pollGenesis = block.timestamp;
        return getDAOPollGenesis();
    }

    function endPolls(uint pollTally, uint daoNomTally) internal virtual returns(bool) {
        pollEnded = true;
        pollEnd = block.timestamp;
        setPollToll(pollTally * daoNomTally);
        return pollEnded;
    }
    
    function pollDAOGovernance(address _candidate) public returns(bool) {
        require(_NOMvotes[_candidate] >= luck);
        require(_OPSvotes[_candidate] <= superPollCap);
        require((_msgSender() != _candidate));
        require(getDaoBlock() == 0);
        _OPSvotes[_candidate]++;
        uint DAO_genesis = pollGenesis;
        if(pollStarted == false){
            DAO_genesis = startPolls();
        } else {
            DAO_genesis = getDAOPollGenesis();
        }
        require(DAO_genesis > 0);
        if(!pollEnded && block.timestamp < (pollGenesis + polling)) {
            govPollCap++;
            _OPSvotes[_candidate]++;
            // with x=superPollCap votes, a vetted candidate is granted authorizations 
            // to vote on debt limit raises && reductions, and various other CA maintenance 
            if(_OPSvotes[_candidate] == superPollCap){
                ttlDAO_GPV++;
                require(_OPSvotes[_candidate] == superPollCap);
                authorize(_candidate);
            }
        } else if(!pollEnded && block.timestamp > (pollGenesis + polling)){
            return endPolls(govPollCap , ttlDAO_GPV);
        } else {
            return true;
        }
        return true;
    }

    function pollDAODebtLimit(address _debtor, string memory _direction) public authorized returns(bool) {
        require(_CREDITvotes[_debtor] <= debtPollCap);
        require(_NOMvotes[_msgSender()] >= luck);
        require(_OPSvotes[_msgSender()] >= superPollCap);
        require((_msgSender() != _debtor));
        ttlDAO_DPV++;
        _CREDITvotes[_debtor]++;
        if(_CREDITvotes[_debtor] == debtPollCap){
            require(_CREDITvotes[_debtor] == debtPollCap);
            uint256 _debtCeiling = IERC20(address(this)).balanceOf(_msgSender()) / debt_basis;
            require(address(this).balance >= _debtCeiling);
            if(keccak256(abi.encodePacked(_direction)) == keccak256(abi.encodePacked(string("UP")))){
                increaseDebtLimit(address(this), _debtor, _debtCeiling);
            } else if(keccak256(abi.encodePacked(_direction)) == keccak256(abi.encodePacked(string("DOWN")))){
                reduceDebtLimit(address(this), _debtor, _debtCeiling);
            } else {
                increaseDebtLimit(address(this), _debtor, _debtCeiling);
            }
        }
        return true;
    }

    function increasePrecision(uint8 precision) internal virtual returns(uint8) {
        _DECIMALS += precision;
        return _DECIMALS;
    }
    function reducePrecision(uint8 precision) internal virtual returns(uint8) {
        _DECIMALS -= precision;
        return _DECIMALS;
    }
    function adjustUnit(uint256 unit, string memory direction) public onlyOperator {
        if(keccak256(abi.encodePacked(direction)) == keccak256(abi.encodePacked(string("UP"))) && _DECIMALS < 18){
            increasePrecision(uint8(unit));
        } else if(keccak256(abi.encodePacked(direction)) == keccak256(abi.encodePacked(string("DOWN"))) && _DECIMALS > 1){
            reducePrecision(uint8(unit));
        } else {}
    }

    function pollDAOPrecision(string memory _direction) public authorized returns(bool) {
        require(_UNITvotes[address(this)] <= precisionPollCap);
        // ttlDAO_DPV++;
        _UNITvotes[address(this)]++;
        if(_UNITvotes[address(this)] == precisionPollCap){
            require(_UNITvotes[address(this)] == precisionPollCap);
            if(keccak256(abi.encodePacked(_direction)) == keccak256(abi.encodePacked(string("UP"))) && _DECIMALS < 18){
                increasePrecision(1);
            } else if(keccak256(abi.encodePacked(_direction)) == keccak256(abi.encodePacked(string("DOWN"))) && _DECIMALS > 1){
                reducePrecision(1);
            } else {}
        }
        return true;
    }
    
    function pollDAOBurn() public returns(bool) {
        address _burnedWallet = address(this);
        require(_BURNvotes[_burnedWallet] <= burnPollCap);
        ttlDAO_BPV++;
        _BURNvotes[_burnedWallet]++;
        
        if(_BURNvotes[_burnedWallet] == burnPollCap){
            require(_BURNvotes[_burnedWallet] == burnPollCap);
            string memory burnLimit = address(this).balance <= 10000 ether ? string("MID") : address(this).balance <= 1000 ether ? string("LOW") : string("HIGH");
            uint256 _burnAmt = getBurnLimit(_burnedWallet, burnLimit);
            require(address(this).balance >= _burnAmt);
            _burn(address(_burnedWallet), _burnAmt);
        }
        return true;
    }

    function getBurnLimit(address _burnedWallet, string memory _burnCeiling) internal virtual returns(uint256) {
        if(keccak256(abi.encodePacked(_burnCeiling)) == keccak256(abi.encodePacked(string("LOW")))){
            _burnLimit = IERC20(address(this)).balanceOf(address(_burnedWallet)) / (debt_basis * debt_basis);
        } else if(keccak256(abi.encodePacked(_burnCeiling)) == keccak256(abi.encodePacked(string("MID")))){
            _burnLimit = IERC20(address(this)).balanceOf(address(_burnedWallet)) / (debt_basis * (debt_basis / 2));
        } else if(keccak256(abi.encodePacked(_burnCeiling)) == keccak256(abi.encodePacked(string("HIGH")))){
            _burnLimit = IERC20(address(this)).balanceOf(address(_burnedWallet)) / debt_basis;
        } else {
            _burnLimit = IERC20(address(this)).balanceOf(address(_burnedWallet)) / (debt_basis * debt_basis);
        }
        return _burnLimit;
    }

    function getDAODebtLimit(address _creditor, address _debtor) public view returns(uint256) {
        return debt_limit[_creditor][_debtor];
    }

    function getDAODebt(address _creditor, address _debtor) public view returns(uint256) {
        return debt[_creditor][_debtor];
    }

    function reduceDebtLimit(address _creditor, address _debtor, uint256 _debtLimit) internal virtual {
        debt_limit[_creditor][_debtor] -= _debtLimit;
    }

    function increaseDebtLimit(address _creditor, address _debtor, uint256 _debtLimit) internal virtual {
        debt_limit[_creditor][_debtor] += _debtLimit;
    }

    function reduceDebt(address _creditor, address _debtor, uint256 _debt) internal virtual {
        debt[_creditor][_debtor] -= _debt;
    }

    function increaseDebt(address _creditor, address _debtor, uint256 _debt) internal virtual {
        debt[_creditor][_debtor] += _debt;
    }

    function getDaoBlock() public virtual returns(uint) {
        if(ttlDAO_GPV == 0){
            daoGenesisBlock = 0;
        } else if(ttlDAO_GPV > 0 && ttlDAO_GPV == superPollCap){
            daoGenesisBlock = block.number;
        } else if(daoGenesisBlock != 0 && block.number == (daoGenesisBlock + uint(42048000))){
            daoGenesisBlock = 0;
            resetDaoPoll();
            setPollToll(debtPollCap * 2);
        } else {}
        return daoGenesisBlock;
    }

    function resetDaoPoll() internal {
        ttlDAO_GPV = 0;
    }

    function resetDebtLimitPoll() internal {
        // if(_OPSvotes[_debtor] >= superPollCap)
        ttlDAO_DPV = 0;
    }

    function setPollToll(uint256 _toll) internal {
        debtPollCap = _toll;
        superPollCap = debtPollCap * 2;
    }

    function networkWithdrawCoin(uint amount) public authorized {
        require(address(this).balance >= amount);
        uint256 local_debt_limit = getDAODebtLimit(address(this), _msgSender());
        require(local_debt_limit > 0);
        reduceDebtLimit(address(this), _msgSender(), amount);
        increaseDebt(address(this), _msgSender(), amount);
        // payable(_msgSender()).transfer(amount);
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);
        emit NetworkWithdrawal(_msgSender(), amount);
    }

    function networkWithdrawToken(uint amount) public authorized {
        require(amount <= IERC20(address(this)).balanceOf(address(this)));
        uint256 local_debt_limit = getDAODebtLimit(address(this), _msgSender());
        require(local_debt_limit > 0);
        reduceDebtLimit(address(this), _msgSender(), amount);
        increaseDebt(address(this), _msgSender(), amount);
        token.transferFrom(address(this), _msgSender(), amount);
        emit NetworkWithdrawal(_msgSender(), amount);
    }

    function networkMintToken(uint amount) public {
        require(amount <= IERC20(address(this)).balanceOf(address(this)));
        uint256 local_debt_limit = getDAODebtLimit(address(this), _msgSender());
        require(local_debt_limit > 0);
        uint256 _debtlimit = IERC20(address(this)).balanceOf(_msgSender()) / debt_basis;
        require(address(this).balance >= _debtlimit);
        reduceDebtLimit(address(this), _msgSender(), amount);
        increaseDebt(address(this), _msgSender(), amount);
        _mint(address(this), amount);
        // token.transferFrom(address(this), msg.sender, amount);
        emit NetworkMint(address(this), amount);
    }

    function networkBurnToken(uint256 _amount) public authorized {
        return _burn(address(this), _amount * (10**_decimals));
    } 

    function deposit() public payable {
        uint256 tokenAmount = msg.value;
        _mint(_msgSender(), tokenAmount);
        uint256 local_debt_limit = getDAODebtLimit(address(this), _msgSender());
        if(local_debt_limit > 0){
            increaseDebtLimit(address(this), _msgSender(), tokenAmount);
            reduceDebt(address(this), _msgSender(), tokenAmount);
        }

        emit Deposit(_msgSender(), msg.value);
    }

    function withdraw(uint amount) public {
        require(balanceOf(msg.sender) >= amount);
        _burn(_msgSender(), amount);
        payable(_msgSender()).transfer(amount);
        uint256 local_debt_limit = getDAODebtLimit(address(this), _msgSender());
        if(local_debt_limit > 0){
            reduceDebtLimit(address(this), _msgSender(), amount);
            increaseDebt(address(this), _msgSender(), amount);
        }

        emit Withdrawal(_msgSender(), amount);
    }    

    function adjustAdminAddr(address payable adminAddr) public virtual authorized {
        if(_OPSvotes[_msgSender()] >= superPollCap)
            ADMIN = payable(adminAddr);
    }

    function adjustAuthorized(address authAddr) public onlyOperator {
        return authorize(address(authAddr));
    }
    
	function getContractNativeBalance() public view returns (uint) {
	    return address(this).balance;
	}  
	
	function getContractTokenBalance() public view returns (uint) {
		return balanceOf(address(this));
	}  
	
	function getUserNativeBalance(address _addr) public view returns (uint) {
		return address(_addr).balance;
	}	
	
	function getUserTokenBalance(address _addr) public view returns (uint) {
		return balanceOf(_addr);
	}
}
