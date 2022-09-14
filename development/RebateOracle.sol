//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
 * ██╗███╗   ██╗████████╗███████╗██████╗  ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗███████╗██████╗ 
 * ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗██╔════╝██║  ██║██╔══██╗██║████╗  ██║██╔════╝██╔══██╗
 * ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██║     ███████║███████║██║██╔██╗ ██║█████╗  ██║  ██║
 * ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║     ██╔══██║██╔══██║██║██║╚██╗██║██╔══╝  ██║  ██║
 * ██║██║ ╚████║   ██║   ███████╗██║  ██║╚██████╗██║  ██║██║  ██║██║██║ ╚████║███████╗██████╔╝
 * ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═════╝ 
 */

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract MSG_ {
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

}

/**
 * Interchained GemOne aka "RebateOracle" (GEM-(CA))
 * DAO-CA Contract
 * Proper certificate of authority (CA) to process DAO implementations
 */
contract RebateOracle is IERC20, MSG_ {
    /**
     * address  
     */
    address public immutable _owner = address(this);
    address payable public _community;
    address payable public _governor;
    address payable public _DAO;
    address public _token;
    /**
     * strings  
     */
    string constant _name = unicode"💎 Rebate Oracle (certificate of authority)";
    string constant _symbol = "RO-CA(b)";
    /**
     * precision  
     */
    uint8 constant _decimals = 18;
    uint256 internal currencyOpsIndex;
    uint256 internal luck = 7;
    uint256 internal sp = 1024;
    uint256 internal bp = 10000;
    /**
     * supply  /  limits
     */
    uint256 public _totalSupply = 200000 * (10 ** 18);
    uint256 public _ETHdrawn = 0;
    uint256 public _proposedLimit = 0;
    uint public _propLimitBlock = 0;
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
    mapping (address => bool) public _voted;
    mapping (uint => uint) public _voteLUCK;
    mapping (uint => uint) public _voteLIMIT;
    mapping (bool => uint) public _tallyLIMIT;
    mapping (address => uint) public _votedAt;
    mapping (address => uint) public _voteDAO;
    mapping (address => uint) public _voteAUTH;
    mapping (address => bool) public _authorized;
    mapping (uint256 => address) public _aIndexes;
    mapping (address => bool) public _votedOnLuck;
    mapping (address => bool) public _votedOnLimit;
    mapping (address => uint) public _votedOnLuckAt;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) public _votes;
    mapping (address => mapping (address => uint256)) public _allowances;

    /**
     * bools  
     */
    bool internal initialized;
    bool public isPublicOffice = false;
    /**
     * Events  
     */
    event Launched(uint256 launchedAt, address daoAddress, address deployer);
    
    /**
     * Function modifiers 
     */
    modifier onlyGovernor() virtual {
        require(isGovernor(_msgSender()), "!GOVERNOR"); _;
    }

    modifier onlyZero() virtual {
        require(isGovernor(payable(0)), "!ZERO"); _;
    }

    modifier isAuthorized() virtual {
        require(_authorized[_msgSender()], "!AUTHORIZED"); _;
    }

    modifier onlyToken() virtual {
        require(isToken(_msgSender()), "!TOKEN"); _;
    }
    
    modifier inChambers() virtual {
        require(isPublicOffice == false, "PUBLIC OFFICE, VOTING REQUIRED"); _;
    }

    constructor () payable {
        // governance
        _governor = payable(0xdF01E4213A38B463F4f04e9D3Ec3E28cA90b81Be);
        _community = payable(0x987576AEc36187887FC62A19cb3606eFfA8B4023);
        // DAO == 0 on genesis
        _DAO = payable(0);
        // ca
        _token = address(this);
        // lucky number 7
        luck = 7;
        // genesis block
        genesis = block.number;
        // mint token
        _balances[address(this)] = _totalSupply;
        // init
        initialize(_governor,_community);
        emit Transfer(address(0), address(this), _totalSupply);
    }

    receive() external payable { }
    fallback() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function name() external pure returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return Governor(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

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

    function authorized() public view virtual returns (bool) {
        address sender = _msgSender();
        if(_authorized[sender] == true) {
            return true;
        } else {
            return false;
        }
    }

    function isGovernor(address account) public view returns (bool) {
        if(address(account) == address(_governor)){
            return true;
        } else {
            return false;
        }
    }

    function authorize(address adr) public onlyGovernor() inChambers() {
        _authorized[adr] = true;
    }

    function unauthorize(address adr) public onlyGovernor() inChambers() {
        _authorized[adr] = false;
    }

    function openOffice() public onlyGovernor() inChambers() {
        isPublicOffice = true;
    }
    
    function closeOffice() public onlyGovernor() {
        isPublicOffice = false;
    }

    function initialize(address payable governance,address payable community) private {
        require(initialized == false);
        _governor = payable(governance);
        _authorized[address(governance)] = true;
        _authorized[address(community)] = true;
        initialized = true;
    }

    function nominateAuthorized(address payable nominee) public virtual returns(bool) {
        require(_DAO != address(0),"Not launched");
        require(_msgSender() != address(nominee),"Can not cast votes for self");
        require(!_voted[_msgSender()],"Can not vote twice");
        uint256 tokenAmount = uint256(getDaoShards(_msgSender()));
        if(uint256(balanceOf(_msgSender())) > uint256(tokenAmount)){
            IERC20(address(this)).transferFrom(_msgSender(), address(this), tokenAmount);
            _voteAUTH[address(nominee)]++;
            uint256 daoLuck = getDAOLuck(currencyOpsIndex);
            if(_voteAUTH[address(nominee)] == daoLuck){
                authorizeParty(payable(nominee));
            }
            _voted[_msgSender()] = true;
            return _voted[_msgSender()];
        } else {
            revert("Not enough Governance token to nominate");
        }
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.
        return account.code.length > 0;
    }

    function nominateCA(address payable _nominateDAO) public virtual isAuthorized() {
        require(address(_nominateDAO) != address(0),"DAO ca not recognized");
        require(isContract(address(_nominateDAO)),"Only Smart Contracts could be nominated for DAO CA");
        if(_DAO == payable(0)){
            _allowances[address(this)][address(_nominateDAO)] = _totalSupply;
            _allowances[_msgSender()][address(this)] = _totalSupply;
            _DAO = payable(_nominateDAO);
            IERC20(address(this)).approve(address(_DAO),_totalSupply);
        } else {
            _votedAt[_msgSender()] = block.number;
            require(_votes[_msgSender()][address(_nominateDAO)]<=1,"Unlucky votes rejected");
            require(enforceVoterPollBlocks(block.number),"Unlucky votes rejected");
            require(_voted[_msgSender()], "Must vote first");
            uint256 tokenAmount = uint256(getDaoShards(_msgSender()));
            IERC20(address(this)).transferFrom(_msgSender(), address(this), tokenAmount);
            _voteDAO[address(_nominateDAO)]++;
            _votes[_msgSender()][address(_nominateDAO)]++;
            uint256 daoLuck = getDAOLuck(currencyOpsIndex);
            if(_voteDAO[address(_nominateDAO)] == daoLuck){
                _allowances[address(this)][address(_nominateDAO)] = _totalSupply;
                _allowances[address(_nominateDAO)][address(this)] = _totalSupply;
                _DAO = payable(_nominateDAO);
            }
        }
    }
    
    function getDaoDrawLimit() public view returns(uint256) {
        return (uint256(address(this).balance) * uint256(sp) / uint256(bp));
    }

    function getDaoProposedLimit() public view returns(uint256) {
        return _proposedLimit;
    }

    function enforceVoterPollBlocks(uint _blockNumber) public view returns(bool) {
        return _blockNumber > (_votedAt[_msgSender()] + (luck*(luck*luck)));
    }

    function enforceLuckPollBlocks(uint _blockNumber) public view returns(bool) {
        return _blockNumber > (_votedOnLuckAt[_msgSender()] + (luck*(luck*luck)));
    }
    
    function getDAOLuck(uint256 cOpsIndex) public view returns(uint256) {
        uint256 coiMin = cOpsIndex >= 2 ? (cOpsIndex - 1) : 1;
        uint256 goodLuck = (coiMin / 2) + 1;            
        uint256 daoLuck = coiMin <= luck ? coiMin : goodLuck;
        return daoLuck;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }
    
    function approveCA(address nominee, uint256 amount) internal returns (bool) {
        _allowances[address(nominee)][address(this)] = amount;
        emit Approval(address(nominee), address(this), amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns(bool) {
        return _transferFrom(_msgSender(), recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns(bool) {
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        address caller = _msgSender();
        if(address(caller) != address(sender)){
            require(uint256(_allowances[sender][_msgSender()]) >= uint256(amount),"Insufficient Allowance!");
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()] - amount;
        }
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getDaoShards(address _wallet) public view returns(uint256) {
        return IERC20(address(this)).balanceOf(_wallet) / luck;
    }

    function getDaoNative() public view returns(uint256) {
        return address(this).balance;
    }

    function withdrawToDAO() public payable isAuthorized() {
        uint draw = getDaoDrawLimit();
        uint shards = getDaoShards(_msgSender());
        IERC20(address(this)).transferFrom(_msgSender(), address(this), shards);
        (bool sent,) = _DAO.call{value: uint256(draw)}("");
        _ETHdrawn+=draw;
        require(sent, "Failed to send Ether");
    }

    function withdrawToDAOPrecise(uint256 ETHamount) public payable isAuthorized() {
        require(uint256(ETHamount) <= uint256(getDaoDrawLimit()),"Excessive draw prevented");
        uint shards = getDaoShards(_msgSender());
        IERC20(address(this)).transferFrom(_msgSender(), address(this), shards);
        (bool sent,) = _DAO.call{value: ETHamount}("");
        _ETHdrawn+=ETHamount;
        require(sent, "Failed to send Ether");
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function getPropLimit() internal virtual returns (uint) {
        if(enforcePropLimt()){
            return _propLimitBlock;
        } else {
            return block.number;
        }
    }

    function enforcePropLimt() internal view returns (bool) {
        return _propLimitBlock < (_propLimitBlock + 3 days);
    }

    function proposeDrawLimit(uint256 _limit, bool _tally) public virtual returns(bool){
        require(uint256(_limit) <= uint256(5100),"51% max");
        require(uint(0) != uint(_limit),"non-zero prevention");
        require(_proposedLimit == 0 || _proposedLimit == _limit, "Limit proposed, send votes");
        require(enforceLuckPollBlocks(block.number),"Unlucky votes rejected");
        require(!_votedOnLimit[_msgSender()],"Can not vote twice");
        uint256 tokenAmount = uint256(getDaoShards(_msgSender()));
        if(getPropLimit() == block.number && _proposedLimit == 0){
            _propLimitBlock = block.number;
        }
        IERC20(address(this)).transferFrom(_msgSender(), address(this), tokenAmount);
        _votedAt[_msgSender()] = block.number;
        _proposedLimit = _limit;
        require(_proposedLimit > 0,"can not vote on genesis");
        _voteLIMIT[_limit]++;
        _tallyLIMIT[_tally]++;
        if(uint256(_voteLIMIT[_limit]) == uint256(getDAOLuck(currencyOpsIndex))){
            if(uint(_tallyLIMIT[true]) > uint(_tallyLIMIT[false])){
                sp = _limit;
                _voteLIMIT[_limit] = 0;
                _tallyLIMIT[_tally] = 0;
                _proposedLimit = 0;
            } else {
                _voteLIMIT[_limit] = 0;
                _tallyLIMIT[_tally] = 0;
                _proposedLimit = 0;
            }
        }
        _votedOnLimit[_msgSender()] = true;
        assert(_votedOnLimit[_msgSender()]==true);
        return _votedOnLimit[_msgSender()];
    }

    function setLuck(uint256 _luck) public virtual returns(bool){
        require(luck != _luck,"No luck can not == _luck");
        require(enforceLuckPollBlocks(block.number),"Unlucky votes rejected");
        _votedAt[_msgSender()] = block.number;
        _voteLUCK[_luck]++;
        uint256 daoLuck = getDAOLuck(currencyOpsIndex);
        if(_voteLUCK[_luck] == daoLuck){
            luck = _luck;
        }
        return true;
    }

    function launch(address payable caDAOaddress) public onlyGovernor() payable {
        require(launchedAt == 0, "Already launched");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
        authorizeParty(payable(_msgSender()));
        nominateCA(payable(caDAOaddress));
        emit Launched(launchedAt, caDAOaddress, _msgSender());
    }

    function authorizeParty(address payable wallet) internal virtual returns(bool) {
        if(_authorized[address(wallet)] == true && address(_msgSender()) != address(_governor)){
            revert("already authorized");
        } else {
            currencyOpsIndex++;
            _authorized[address(wallet)] = true;
        }
        _aIndexes[currencyOpsIndex] = address(wallet);
        uint256 partyLuck = getDaoShards(address(this));
        if(_allowances[address(this)][wallet] < partyLuck){
            _allowances[address(this)][wallet] = partyLuck;
            approveCA(address(wallet), uint256(partyLuck));
        }
        IERC20(address(this)).transfer(payable(wallet), partyLuck);
        return _authorized[address(wallet)];
    }
    
    function deauthorizeParty(address wallet) internal virtual returns(bool) {
        require(_authorized[address(wallet)] == true,"already deauthorized");
        _authorized[address(wallet)] = false;            
        _allowances[address(this)][wallet] = 0;
        return _authorized[address(wallet)];
    }

    function deAuthorizeWallet(address wallet) public virtual onlyGovernor() returns(bool) {
        _authorized[address(wallet)] = false;
        return _authorized[address(wallet)];
    }

    function transferGovernership(address payable newGovernor) public virtual onlyGovernor() returns(bool) {
        require(newGovernor != payable(0), "Ownable: new owner is the zero address");
        _authorized[address(_governor)] = false;
        _governor = payable(newGovernor);
        _authorized[address(newGovernor)] = true;
        return true;
    }
}
