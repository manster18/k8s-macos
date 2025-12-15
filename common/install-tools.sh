#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Kubernetes Tools Installation for macOS   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is not installed.${NC}"
    echo "Install Homebrew first: https://brew.sh/"
    exit 1
fi

echo -e "${GREEN}✓ Homebrew is installed${NC}"
echo

# Update Homebrew
echo -e "${YELLOW}Updating Homebrew...${NC}"
brew update

# Function to install or skip
install_tool() {
    local tool=$1
    local package=${2:-$tool}
    
    if command -v $tool &> /dev/null; then
        echo -e "${GREEN}✓ $tool is already installed${NC}"
        $tool version 2>/dev/null || $tool --version 2>/dev/null || echo "  (version info not available)"
    else
        echo -e "${YELLOW}Installing $tool...${NC}"
        brew install $package
        echo -e "${GREEN}✓ $tool installed${NC}"
    fi
}

# Core tools
echo -e "${BLUE}=== Core Tools ===${NC}"
install_tool kubectl
install_tool docker

echo
echo -e "${BLUE}=== Kubernetes Cluster Tools ===${NC}"

# Ask which cluster tools to install
echo "Which Kubernetes cluster tools would you like to install?"
echo

read -p "Install Kind? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_tool kind
fi

read -p "Install k3d? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_tool k3d
fi

read -p "Install Minikube? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_tool minikube
fi

# Optional useful tools
echo
echo -e "${BLUE}=== Optional Useful Tools ===${NC}"
echo

read -p "Install Helm (Kubernetes package manager)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_tool helm
fi

read -p "Install k9s (Terminal UI for K8s)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_tool k9s
fi

read -p "Install kubectx/kubens (context/namespace switcher)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_tool kubectx
    install_tool kubens kubectx
fi

read -p "Install stern (multi-pod log tailing)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_tool stern
fi

read -p "Install kustomize (K8s config management)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_tool kustomize
fi

echo
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Installation Complete!                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo

# Check Docker Desktop
echo -e "${YELLOW}Checking Docker Desktop...${NC}"
if docker ps &> /dev/null; then
    echo -e "${GREEN}✓ Docker Desktop is running${NC}"
else
    echo -e "${YELLOW}⚠ Docker Desktop is not running${NC}"
    echo "  Please start Docker Desktop from Applications"
fi

echo
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Ensure Docker Desktop is running"
echo "2. Choose a cluster solution:"
echo "   - For speed: cd k3d && ./setup.sh"
echo "   - For multi-node: cd kind && ./setup.sh"
echo "   - For features: cd minikube && ./setup.sh"
echo "3. Run: kubectl get nodes"
echo
echo "For more information, see: docs/GETTING_STARTED.md"

