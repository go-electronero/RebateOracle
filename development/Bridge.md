
Bridge:
(base currencies)
+ [ETH/KEK] 
(fee structure)
+ $5 USDT adjustable transfer fee
+ 20% devFee, 80% team
(transaction construction)
+ Fee on transfer split 
+ Withdrawals to Vault
Design (pseudo):
- User enters amount to bridge
- User clicks submitTransferA()

- Bridge displays: 
  form:
    - (input) Field for amount to Send
    - (span) Amount to Receive
    - (span) TX fee 
    - (span) Wait time
  table: 
    - History of transactions
    - Link(s) to explorer(s)
    - Amounts Sent/Received
    - Timestamp
    - Path
    
  DApp does magic:
    - handling transactions with 2 smart contracts (Vault/Records)
    - enforced by return values
    - double checking transaction artifacts against local MySql database
  How we do this?
  database && contracts:
    - Address of sender
    - Amounts of transferA (sent)
    - Amount of transferB (received)
    - Path [A=>B] || [B=>A]
    - transaction ID of transferA 
    - transaction ID of transferB
    - handle transferA (send)
    - handle transferB (receive)
  server-side: 
    - polling transferA (ensure success)
    - polling transferB (ensure success)
    - write database (pending && success)
  transaction-construction: 
    - transferA (send)
    +++ on submit(token) [KEK(token) => KEK(coin)]
    Step 1) - Transfer USDt txFee From User To Vault
    Step 2) - Transfer KEK(token) From User To Vault
    Step 3) - Transfer KEK(coin) From Vault To User
      - transferA From user to contract 
        - on transferA (pending) (ensure success)
            + (pin pending transaction hash to DB) then ()=> checkTransferASuccess(txid)
            + poll infura (when (TX hash sent + confirmations) >= xY confirmations) then ()=> returnSuccessTransferA() 
            + returnSuccessTransferA() functionality == (pin confirmed transaction hash to DB, UPDATE transferA to confirmed)
    - transferB (receive)
    +++ on submit(coin) [KEK(coin) => KEK(token)]
    Step 1) - Transfer USDt txFee From User To Vault
    Step 2) - Transfer KEK(coin) From User To Vault
    Step 3) - Transfer KEK(token) From Vault To User
      - transferB From contract to user 
        - on transferA (success) (trigger TransferB, ensure success)
            + (pin pending transaction hash to DB) then ()=> checkTransferBSuccess(txid)
            + poll infura (when (TX hash sent + confirmations) >= xY confirmations) then ()=> returnSuccessTransferB() 
            + returnSuccessTransferB() functionality == (pin confirmed transaction hash to DB, UPDATE transferB to confirmed)
Security: 
   - update Front-end from Back-end ONLY
   - client values routed Front-end through Back-end
   - Back-end values update database only on submit() post-transfer(s)
Vault:
+ Vault splits each withdrawal (team 80%/20% dev)
+ msg.sender pays gas for withdrawals 
+ ERC20 vault keys sent to team 
+ No owner, ownerless 
+ Deployer can not withdraw 
+ Addresses for withdrawal preconfigured 
+ Addresses must hold Vault Keys (ERC20) to call Withdraw()
 
