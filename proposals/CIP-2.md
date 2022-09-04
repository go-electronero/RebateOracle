
Airdrop:
Design (pseudo):
- Team/Owner enters amount to airdrop
- Team/Owner enters address(es) to receive airdrop
- Team/Owner sends airdrop through contract 

Example:
// ToDo apply to token (ERC20)

    function airdrop(address recipient, uint256 amount) external onlyOwner() {
        _transfer(_msgSender(), recipient, amount * 10**9);
    }
    
    function airdropInternal(address recipient, uint256 amount) internal {
        _transfer(_msgSender(), recipient, amount);
    }
    
    function airdropArray(address[] calldata newholders, uint256[] calldata amounts) external onlyOwner(){
        uint256 iterator = 0;
        require(newholders.length == amounts.length, "must be the same length");
        while(iterator < newholders.length){
            airdropInternal(newholders[iterator], amounts[iterator] * 10**9);
            iterator += 1;
        }
    }
    

