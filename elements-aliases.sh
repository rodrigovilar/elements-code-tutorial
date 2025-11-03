#!/bin/bash

# Elements Tutorial - Docker Aliases for Liquid Testnet
# Source this file to use the same aliases as the tutorial
# Usage: source elements-aliases.sh

# Enable alias expansion
shopt -s expand_aliases

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Elements Node 1 aliases (Liquid Testnet)
alias e1-cli="docker exec tutorial_elementsd1 elements-cli -chain=liquidtestnet -rpcuser=user1 -rpcpassword=password1"
alias e1-dae="(cd $SCRIPT_DIR && docker compose up -d elementsd1)"
alias e1-logs="docker logs -f tutorial_elementsd1"
alias e1-stop="(cd $SCRIPT_DIR && docker compose stop elementsd1)"

# Elements Node 2 aliases (Liquid Testnet)
alias e2-cli="docker exec tutorial_elementsd2 elements-cli -chain=liquidtestnet -rpcuser=user2 -rpcpassword=password2"
alias e2-dae="(cd $SCRIPT_DIR && docker compose up -d elementsd2)"
alias e2-logs="docker logs -f tutorial_elementsd2"
alias e2-stop="(cd $SCRIPT_DIR && docker compose stop elementsd2)"

# General management aliases
alias elements-up="(cd $SCRIPT_DIR && docker compose up -d)"
alias elements-down="(cd $SCRIPT_DIR && docker compose down)"
alias elements-status="(cd $SCRIPT_DIR && docker compose ps)"
alias elements-logs="(cd $SCRIPT_DIR && docker compose logs -f)"

echo "Liquid Testnet aliases loaded!"
echo ""
echo "Elements Node 1 aliases:"
echo "  e1-cli <command> - Execute elements-cli commands on node 1 (Liquid Testnet)"
echo "  e1-dae          - Start elementsd1 container"
echo "  e1-logs         - View elementsd1 logs"
echo "  e1-stop         - Stop elementsd1 container"
echo ""
echo "Elements Node 2 aliases:"
echo "  e2-cli <command> - Execute elements-cli commands on node 2 (Liquid Testnet)"
echo "  e2-dae          - Start elementsd2 container"
echo "  e2-logs         - View elementsd2 logs"
echo "  e2-stop         - Stop elementsd2 container"
echo ""
echo "General aliases:"
echo "  elements-up     - Start all containers"
echo "  elements-down   - Stop and remove all containers"
echo "  elements-status - Show container status"
echo "  elements-logs   - View all container logs"
echo ""
echo "Get testnet funds at: https://liquidtestnet.com/faucet"
