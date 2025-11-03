# Elements Project Tutorial - Docker Setup

This repository contains the Docker configuration to follow the [Elements Project Tutorial](https://elementsproject.org/elements-code-tutorial/working-environment).

## Structure

```
tutorial/
├── docker-compose.yml          # Container configuration
├── bitcoindir/
│   └── bitcoin.conf           # Bitcoin Core configuration
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

## Starting the Environment

```bash
docker compose up -d
```

## Using the Commands

There are two ways to use the tutorial commands:

### Option 1: Using the aliases script (recommended)

Load the aliases script in your terminal:

```bash
source elements-aliases.sh
```

Now you can use the same commands as the tutorial:

```bash
# Bitcoin
b-cli getblockcount
b-cli generate 101

# Elements Node 1
e1-cli getblockcount
e1-cli getnewaddress

# Elements Node 2
e2-cli getblockcount
e2-cli getpeerinfo
```

### Option 2: Direct Docker commands

If you prefer not to use aliases:

```bash
# Bitcoin
docker exec tutorial_bitcoind bitcoin-cli -regtest -rpcuser=user3 -rpcpassword=password3 getblockcount

# Elements Node 1
docker exec tutorial_elementsd1 elements-cli -chain=elementsregtest -rpcuser=user1 -rpcpassword=password1 getblockcount

# Elements Node 2
docker exec tutorial_elementsd2 elements-cli -chain=elementsregtest -rpcuser=user2 -rpcpassword=password2 getblockcount
```

## Available Commands

When you load `elements-aliases.sh` with `source`, you get access to these commands:

### Tutorial Commands (same interface as the original tutorial)
```bash
b-cli <command>     # Execute bitcoin-cli commands
e1-cli <command>    # Execute elements-cli commands on node 1
e2-cli <command>    # Execute elements-cli commands on node 2
```

### Container Management
```bash
# Start individual nodes (equivalent to tutorial's *-dae commands)
b-dae               # Start bitcoind
e1-dae              # Start elementsd1
e2-dae              # Start elementsd2

# Stop individual nodes
b-stop              # Stop bitcoind
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
b-logs              # View bitcoind logs
e1-logs             # View elementsd1 logs
e2-logs             # View elementsd2 logs

# All logs
elements-logs       # View all container logs
```

## Network Configuration

### Bitcoin Core (regtest)
- RPC: localhost:18888
- P2P: localhost:18889
- User: user3
- Password: password3

### Elements Node 1 (elementsregtest)
- RPC: localhost:18884
- P2P: localhost:18886
- User: user1
- Password: password1

### Elements Node 2 (elementsregtest)
- RPC: localhost:18885
- P2P: localhost:18887
- User: user2
- Password: password2

## Following the Tutorial

Now you can follow the official tutorial at:
https://elementsproject.org/elements-code-tutorial/working-environment

All tutorial commands will work the same way, just use the configured aliases!

## Stopping the Environment

```bash
docker compose down
```

To also remove volumes (persistent data):

```bash
docker compose down -v
```
