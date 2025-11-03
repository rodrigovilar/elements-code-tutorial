# Liquid Testnet - Docker Setup

This repository contains the Docker configuration to connect to the [Liquid Testnet](https://liquidtestnet.com/).

## What is Liquid Testnet?

Liquid Testnet is a public test network for the Liquid Network (a Bitcoin sidechain). It allows you to:
- Test Liquid features without using real funds
- Connect to a real federated network with actual block production
- Get test L-BTC from the faucet
- Test real-world scenarios and integrations

## Structure

```
tutorial/
├── docker-compose.yml          # Container configuration
├── elementsdir1/
│   └── elements.conf          # Elements Node 1 configuration
├── elementsdir2/
│   └── elements.conf          # Elements Node 2 configuration
├── elements-aliases.sh        # Script with functions/aliases
└── README.md                  # This file
```

## Requirements

- Docker
- Docker Compose
- Internet connection (to connect to Liquid Testnet)

## Starting the Environment

```bash
docker compose up -d
```

**Note**: Initial synchronization will take some time as the nodes download the blockchain from the network.

## Using the Commands

There are two ways to use the commands:

### Option 1: Using the aliases script (recommended)

Load the aliases script in your terminal:

```bash
source elements-aliases.sh
```

Now you can use these commands:

```bash
# Elements Node 1
e1-cli getblockchaininfo
e1-cli getnewaddress
e1-cli getbalance

# Elements Node 2
e2-cli getblockchaininfo
e2-cli getpeerinfo
```

### Option 2: Direct Docker commands

If you prefer not to use aliases:

```bash
# Elements Node 1
docker exec tutorial_elementsd1 elements-cli -chain=liquidtestnet -rpcuser=user1 -rpcpassword=password1 getblockchaininfo

# Elements Node 2
docker exec tutorial_elementsd2 elements-cli -chain=liquidtestnet -rpcuser=user2 -rpcpassword=password2 getblockchaininfo
```

## Available Commands

When you load `elements-aliases.sh` with `source`, you get access to these commands:

### Node Commands
```bash
e1-cli <command>    # Execute elements-cli commands on node 1
e2-cli <command>    # Execute elements-cli commands on node 2
```

### Container Management
```bash
# Start individual nodes
e1-dae              # Start elementsd1
e2-dae              # Start elementsd2

# Stop individual nodes
e1-stop             # Stop elementsd1
e2-stop             # Stop elementsd2

# General management
elements-up         # Start all containers
elements-down       # Stop and remove all containers
elements-status     # View container status
```

### View Logs
```bash
# Individual logs (follow mode)
e1-logs             # View elementsd1 logs
e2-logs             # View elementsd2 logs

# All logs
elements-logs       # View all container logs
```

## Getting Test Funds

To get test L-BTC for your wallet:

1. Get a new address:
   ```bash
   e1-cli getnewaddress
   ```

2. Visit the faucet: https://liquidtestnet.com/faucet

3. Enter your address and request test funds

4. Wait for the transaction to be confirmed (check with `e1-cli getbalance`)

## Network Configuration

### Elements Node 1 (liquidtestnet)
- RPC: localhost:18884
- P2P: localhost:18886
- User: user1
- Password: password1

### Elements Node 2 (liquidtestnet)
- RPC: localhost:18885
- P2P: localhost:18887
- User: user2
- Password: password2

Both nodes connect to public Liquid Testnet peers:
- liquid.network:18844
- liquid-testnet.blockstream.com:18891
- liquidtestnet.com:18891

## Monitoring

- **Block Explorer**: https://liquidtestnet.com/
- **Check sync status**: `e1-cli getblockchaininfo`
- **View connected peers**: `e1-cli getpeerinfo`
- **Check wallet balance**: `e1-cli getbalance`

## Stopping the Environment

```bash
docker compose down
```

To also remove volumes (blockchain data):

```bash
docker compose down -v
```

**Warning**: Removing volumes will delete the blockchain data and you'll need to re-sync from scratch.

## Useful Resources

- **Liquid Testnet Website**: https://liquidtestnet.com/
- **Liquid Network Documentation**: https://docs.liquid.net/
- **Elements Project**: https://elementsproject.org/
- **Block Explorer**: https://liquidtestnet.com/
- **Faucet**: https://liquidtestnet.com/faucet
