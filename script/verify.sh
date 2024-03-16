source .env

forge verify-contract 0xa63b68da994883d51114f8c9d2d1c4c0762c9038 VaultFactory \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --chain-id 8453 \
    --watch \
    --retries=2 