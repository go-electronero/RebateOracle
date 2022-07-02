//SPDX-License-Identifier: MIT
//  ▄▄ • ▄▄▄ .• ▌ ▄ ·. ·▄▄▄▄   ▄▄▄·       
// ▐█ ▀ ▪▀▄.▀··██ ▐███▪██▪ ██ ▐█ ▀█ ▪     
// ▄█ ▀█▄▐▀▀▪▄▐█ ▌▐▌▐█·▐█· ▐█▌▄█▀▀█  ▄█▀▄ 
// ▐█▄▪▐█▐█▄▄▌██ ██▌▐█▌██. ██ ▐█ ▪▐▌▐█▌.▐▌
// ·▀▀▀▀  ▀▀▀ ▀▀  █▪▀▀▀▀▀▀▀▀•  ▀  ▀  ▀█▄▀▪
pragma solidity 0.8.4;
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
     */
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

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

abstract contract Auth {
    using Address for address;
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address payable _maintainer) {
        owner = payable(0xB9F96789D98407B1b98005Ed53e8D8824D42A756);
        authorizations[owner] = true;
        authorizations[_maintainer] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() virtual {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyZero() virtual {
        require(isOwner(address(0)), "!ZERO"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() virtual {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }
    
    /**
     * Function modifier to require caller to be authorized
     */
    modifier renounced() virtual {
        require(isRenounced(), "!RENOUNCED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public authorized {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public authorized {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        if(account == owner){
            return true;
        } else {
            return false;
        }
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Return address' authorization status
     */
    function isRenounced() public view returns (bool) {
        require(owner == address(0), "NOT RENOUNCED!");
        return owner == address(0);
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        require(isOwner(msg.sender), "Unauthorized!");
        emit OwnershipTransferred(address(0));
        authorizations[address(0)] = true;
        authorizations[owner] = false;
        owner = address(0);
    }

    /**
     * Transfer ownership to new address. Caller must be owner. 
     */
    function transferOwnership(address payable adr) public virtual onlyOwner returns (bool) {
        authorizations[adr] = true;
        authorizations[owner] = false;
        owner = payable(adr);
        emit OwnershipTransferred(adr);
        return true;
    }    
    
    /**
     * NEW: Take ownership if previous owner renounced.
     */
    function takeOwnership() public virtual {
        require(isOwner(address(0)) || isRenounced() == true, "Unauthorized! Non-Zero address detected as this contract current owner. Contact this contract current owner to takeOwnership(). ");
        authorizations[owner] = false;
        owner = payable(msg.sender);
        authorizations[owner] = true;
        emit OwnershipTransferred(owner);
    }

    event OwnershipTransferred(address owner);
}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function availableSupply() external returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, Auth {

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

    constructor(string memory _nam, string memory _sym, uint8 _dec, uint256 genesis) Auth(payable(msg.sender)) {
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

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function availableSupply() public override virtual returns (uint256) {
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require((_totalSupply += amount) <= _maxSupply, "ERC20: mint surpasses supply limitations");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        emit Minted(address(account), amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        require(decreaseAllowance(address(account), amount));
        emit Transfer(account, address(0), amount);
        emit Burned(address(account), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function getOwner() external view returns(address){
        return owner;
    }

}

contract gemDAO is ERC20 {
    using SafeMath for uint256;
    
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
        require(msg.sender == ADMIN, "Only operator can call ");
        _;
    } 

    constructor() ERC20(string(_NAME), string(_SYMBOL), uint8(_DECIMALS), uint256(_GENESIS)) {
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
        require((_msgSender() != _nominee), "Can not cast votes for self");
        require(getDaoBlock() == 0, "Polls closed");
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
        require(_NOMvotes[_msgSender()] >= luck,"Not nominated");
        require(nomPollEnded == true,"Not permitted");
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
        require(_NOMvotes[_candidate] >= luck, "Polls closed");
        require(_OPSvotes[_candidate] <= superPollCap, "Polls closed");
        require((_msgSender() != _candidate), "Can not cast votes for self");
        require(getDaoBlock() == 0, "Polls closed");
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
                require(_OPSvotes[_candidate] == superPollCap, "Polls closed");
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
        require(_CREDITvotes[_debtor] <= debtPollCap, "Campaign succeeded");
        require(_NOMvotes[_msgSender()] >= luck, "Not lucky");
        require(_OPSvotes[_msgSender()] >= superPollCap, "Not permitted");
        require((_msgSender() != _debtor), "Can not cast votes to self");
        ttlDAO_DPV++;
        _CREDITvotes[_debtor]++;
        if(_CREDITvotes[_debtor] == debtPollCap){
            require(_CREDITvotes[_debtor] == debtPollCap, "Polls closed");
            uint256 _debtCeiling = IERC20(address(this)).balanceOf(_msgSender()) / debt_basis;
            require(address(this).balance >= _debtCeiling, "Can not afford debt, deposit coin(s)");
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
        require(_UNITvotes[address(this)] <= precisionPollCap, "Campaign succeeded");
        // ttlDAO_DPV++;
        _UNITvotes[address(this)]++;
        if(_UNITvotes[address(this)] == precisionPollCap){
            require(_UNITvotes[address(this)] == precisionPollCap, "Polls closed");
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
        require(_BURNvotes[_burnedWallet] <= burnPollCap, "Campaign succeeded");
        ttlDAO_BPV++;
        _BURNvotes[_burnedWallet]++;
        
        if(_BURNvotes[_burnedWallet] == burnPollCap){
            require(_BURNvotes[_burnedWallet] == burnPollCap, "Polls closed");
            string memory burnLimit = address(this).balance <= 10000 ether ? string("MID") : address(this).balance <= 1000 ether ? string("LOW") : string("HIGH");
            uint256 _burnAmt = getBurnLimit(_burnedWallet, burnLimit);
            require(address(this).balance >= _burnAmt, "Can not afford burn, deposit coin(s)");
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
        require(success, "Failed to process withdraw");
        emit NetworkWithdrawal(_msgSender(), amount);
    }

    function networkWithdrawToken(uint amount) public authorized {
        require(amount <= IERC20(address(this)).balanceOf(address(this)), "Request exceeds contract token balance.");
        uint256 local_debt_limit = getDAODebtLimit(address(this), _msgSender());
        require(local_debt_limit > 0);
        reduceDebtLimit(address(this), _msgSender(), amount);
        increaseDebt(address(this), _msgSender(), amount);
        token.transferFrom(address(this), _msgSender(), amount);
        emit NetworkWithdrawal(_msgSender(), amount);
    }

    function networkMintToken(uint amount) public {
        require(amount <= IERC20(address(this)).balanceOf(address(this)), "Request exceeds contract token balance.");
        uint256 local_debt_limit = getDAODebtLimit(address(this), _msgSender());
        require(local_debt_limit > 0);
        uint256 _debtlimit = IERC20(address(this)).balanceOf(_msgSender()) / debt_basis;
        require(address(this).balance >= _debtlimit, "Can not afford debt, deposit coin(s).");
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
