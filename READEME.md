## Rebate Oracle + STACK + gemDAO

Designed specially for usage alongside PoAwR-v2
PoAwR-v2 is here! Proof-of-Authority with Rebates v1 was a total success, and PoAwR-v2 brings the heat with a fully decentralized take on PoAwR. 

Where as in PoAwR-v1 block rebates are disposed to a centralized EOA... In PoAwR-v2 block rebates are distributed in a 100% decentralized manner.
This set of smart contracts governs the PoAwR-v2 consensus, now seen in go-electronero(https://github.com/go-electronero/go-electronero)

## How it works? 
Go-Electronero PoAwR employs instant validation, under PoA there are no reasons not to! 
In fact, 0 second blocks are possible. So why not? Let's go fast! 
Through a decentralized multi-user authorization protection layer rAuth.sol, governorship is awarded to a predetermined signor. 
Then, Rebate Oracle is deployed on a PoAwR enabled blockchain network. GemDao enables public voting, which could add additional governors or even alter the DAO implementation. In fact the gemDAO can trigger withdrawals of coins from Rebate Oracle into STACK and from within STACK the community may claim shards of the rebate pools. This is fun! Let's keep going! 
Block Rebates must be delivered to Rebate Oracle smart contract for distribution through DAO and STACK. So how do we do this is we deploy a smart contract on a testnet, find the address, and set this public address as the rebate receiver within PoAwR.
Now when we launch the genesis, all block rebates are disposed to the preconfigured public address. Then we deploy the Rebate Oracle, and voila! Like that we have achieved the results we are looking for. All rebates go directly to Rebate Oracle smart contract. 
Which itself on deployment automgically deploys STACK and gemDAO.

## Notes from our developers
InterchainED @shopglobal 
I achieved the results of deploying the rebate oracle post genesis and preserving the rebate fund address(pre-genesis) of the predetermined and pre-calculated smart contract address. 

Since the first smart contract that a public wallet deployed to any EVM network will always be the same. We identified this address and preconfigured the genesis block of go-electronero testnero to fund the Rebate Oracle before the smart contract itself was ever deployed. This way upon deployment, all the functionally necessary components would be enabled since there was some constructor logic and other functionality which could not be computed in the genesis block. 

How this works is after the genesis block was sealed the following blocks contained the actual deployment of the Rebate Rebate smart contract which automagically deployed the gemDAO and STACK v1 protocols smart contracts. This is remarkable! Now the future PoAwR-v2 rebates go directly into the Rebate Oracle smart contract. And from there could be drawn to STACK and GemDAO for 100% decentralized distribution!!!

Thanks to cryptography and the PoAwR-v2 now block rebates can be decentralized in ways where community’s interest groups will get funded and public votes are processed to maintain the DAO implementations, all this makes for a great foundation along with an all new stacking program to incentivize our future -go-electronero chain holders and long time supporters alike to help the network grow and maintain stability and circulations distribution brought by community participation in STACK which is a new protocol coming first to go-electronero!! 

STACK gathers rebates from Rebate oracle and distributes claims from stackers who place coins in to the smart contract for a variable duration of time which equates to a rightful share of the rebate pool. 

All this and more new exciting advancements are here now, and we’ll be sharing more with you as electronero core developments continue. 

Thanks for your time and consideration. Regards,M https://t.me/interchained

## More Details: 
Launched testnet “testnero” in preparation for the release of go-electronero. 

ChainID: 777
NetworkID: 777
RPC: https://testnero-rpc.interchained.org 

Faucet will come online shortly. And the explorer to follow. 

Some points of reference for testnero include;
+Instant blocks, no delay in transaction processing. If there’s a transfer in the mempool it will be validated instantly, if not there will not be a new block produced. 
+less energy waste, low energy consumption (green)
+lightning fast ⚡️ 
+total supplies of electronero coins have been consolidated in 1 chain to facilitate bridging 
+PoAwR-v2 has been born featuring decentralized Rebate distribution through STACK protocol and GemDAO

Some news regarding the PoAwR-V2 include;
We just deployed the genesis for testnero and have started the network with PoAwR-v2 consensus where block rebates go to a smart contract rather than to a user controlled wallet. 

The Rebate Oracle smart contract was deployed and I adjusted the code to auto deploy gemDao and STACK simultaneously. 

In conclusion;
Now, the last step is to test everything and then roll out main net. There may be a reboot on testnet during the process to ensure consistency with the new PoAwR-v2 system. 

Massive thank you goes out to our supporters and patient community!!!
I’m so excited to share this news and I look forward to releasing go-electronero v1.0 within the following hours. 

Hope you’re all having a good evening! The best is yet to come! 
Regards, M @interchainEd
