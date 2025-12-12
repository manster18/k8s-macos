#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Minikube Cluster Teardown ===${NC}"

# Check if cluster exists
if ! minikube status &> /dev/null; then
    echo -e "${RED}No Minikube cluster found.${NC}"
    exit 1
fi

# Show current status
echo "Current cluster status:"
minikube status
echo

# Confirm deletion
read -p "Are you sure you want to delete the Minikube cluster? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deletion cancelled.${NC}"
    exit 0
fi

# Delete cluster
echo -e "${YELLOW}Deleting Minikube cluster...${NC}"
minikube delete

echo -e "${GREEN}Cluster deleted successfully!${NC}"

