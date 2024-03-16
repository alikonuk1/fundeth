source .env

forge script script/DeployFactory.s.sol:DeployFactory --chain-id 8453 --rpc-url https://rpc.notadegen.com/base \
    --broadcast --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify -vvvv 