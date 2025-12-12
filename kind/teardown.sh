#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CLUSTER_NAME="k8s-dev"

echo -e "${YELLOW}=== Kind Cluster Teardown ===${NC}"

# Check if cluster exists
if ! kind get clusters 2>&1 | grep -q "^${CLUSTER_NAME}$"; then
    echo -e "${RED}Cluster '${CLUSTER_NAME}' does not exist.${NC}"
    exit 1
fi

# Confirm deletion
read -p "Are you sure you want to delete cluster '${CLUSTER_NAME}'? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deletion cancelled.${NC}"
    exit 0
fi

# Delete cluster
echo -e "${YELLOW}Deleting cluster '${CLUSTER_NAME}'...${NC}"
kind delete cluster --name ${CLUSTER_NAME}

echo -e "${GREEN}Cluster deleted successfully!${NC}"

