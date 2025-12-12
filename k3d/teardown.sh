#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CLUSTER_NAME="k8s-dev"
REGISTRY_NAME="registry.localhost"

echo -e "${YELLOW}=== k3d Cluster Teardown ===${NC}"

# Check if cluster exists
if ! k3d cluster list | grep -q "${CLUSTER_NAME}"; then
    echo -e "${RED}Cluster '${CLUSTER_NAME}' does not exist.${NC}"
else
    # Confirm deletion
    read -p "Are you sure you want to delete cluster '${CLUSTER_NAME}'? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deleting cluster '${CLUSTER_NAME}'...${NC}"
        k3d cluster delete ${CLUSTER_NAME}
        echo -e "${GREEN}Cluster deleted successfully!${NC}"
    else
        echo -e "${YELLOW}Cluster deletion cancelled.${NC}"
    fi
fi

# Check for registry
if k3d registry list | grep -q "k3d-${REGISTRY_NAME}"; then
    read -p "Do you want to delete the registry 'k3d-${REGISTRY_NAME}'? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deleting registry...${NC}"
        k3d registry delete k3d-${REGISTRY_NAME}
        echo -e "${GREEN}Registry deleted successfully!${NC}"
    fi
fi

echo -e "${GREEN}Cleanup complete!${NC}"

