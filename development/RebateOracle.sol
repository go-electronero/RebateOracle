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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

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

interface IWETH {
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address guy, uint wad) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
    function transfer(address dst, uint256 wad) external returns (bool success);
    function transferFrom(address src, address destination, uint256 wad) external returns (bool success);
    function deposit() external payable;
    function withdraw(uint wad) external;
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
    using Address for address;
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
        _governor = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
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
        initialize(_governor,_community,_msgSender());
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

    function nominateAuthorized(address nominee) public virtual returns(bool) {
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

    function nominateCA(address payable _nominateDAO) public virtual isAuthorized() {
        require(address(_nominateDAO) != address(0),"DAO ca not recognized");
        require(Address.isContract(address(_nominateDAO)),"Only Smart Contracts could be nominated for DAO CA");
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
