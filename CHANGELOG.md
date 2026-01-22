# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2026-01-22

### Added
- Ingress-based load balancing solution for Kind clusters on macOS
  - nginx-ingress controller installation prompt in kind/setup.sh
  - Automatic setup guidance based on Ingress installation status
  - Default route accessible via http://localhost
  - Custom domain support (demo.local)
- Comprehensive documentation for Kind network limitations on macOS
  - Explanation of Docker VM network isolation
  - LoadBalancer vs Ingress comparison
  - Step-by-step Ingress setup guide in kind/README.md
- Intelligent test script that detects Ingress availability
  - Auto-uses Ingress when available (true load balancing)
  - Falls back to port-forward with clear warnings
  - Waits for Ingress Controller readiness

### Improved
- demo-app Ingress manifest now supports both localhost and custom domain access
  - Default rule for http://localhost (no host header required)
  - Optional demo.local rule for custom domain testing
- Enhanced demo-app documentation with Kind-specific instructions
  - Two access methods clearly documented (Ingress vs port-forward)
  - Load balancing troubleshooting section
  - Ingress configuration explained
- Updated kind/setup.sh with better user guidance
  - Explains why Ingress is needed on macOS
  - Post-installation instructions adapt to Ingress availability
  - Clear distinction between load-balanced and single-pod access
- Improved test-loadbalancing.sh for Kind clusters
  - Detects nginx-ingress namespace and demo-app ingress
  - Uses localhost when Ingress is available
  - Provides setup instructions when Ingress is missing

### Fixed
- Kind load balancing now works properly via Ingress
  - Resolves issue where port-forward connected to single pod only
  - Users can now test true load balancing on macOS
- Ingress Controller now correctly runs on control-plane node
  - Fixed issue where Ingress ran on worker node without port mapping
  - Added toleration and automatic labeling to ensure correct placement
  - Ports 80/443 are mapped to control-plane in cluster-config.yaml
- Documentation clarity around Kind networking limitations
  - Explains why LoadBalancer services don't work on macOS
  - Provides working solution (Ingress) instead of non-functional approach

### Documentation
- Added "Accessing Services on macOS" section to kind/README.md
- Updated troubleshooting sections across all documentation
- Clarified that port-forward is single-pod only (not load-balanced)
- Added comparison: k3d (built-in ServiceLB) vs Kind (requires Ingress)

## [1.1.0] - 2025-12-16

### Added
- Complete demo application for cluster testing (`examples/demo-app/`)
  - Production-ready Kubernetes manifests (Deployment, Service, Ingress)
  - 3-replica deployment with health checks and resource limits
  - LoadBalancer service for easy external access
  - Optional Ingress configuration
- Comprehensive testing documentation
  - `QUICK_TEST.md` - 1-minute quick start guide
  - `README.md` - Full demo app documentation
  - `TESTING_GUIDE.md` - Complete testing manual
  - `LOAD_BALANCING_EXPLAINED.md` - Deep dive into L4 vs L7 load balancing
- Automated load balancing test script (`test-loadbalancing.sh`)
  - Visual distribution charts
  - Automatic cluster type detection
  - Compatible with bash 3.2+ (macOS default)
- Post-setup instructions (`POST_SETUP_INSTRUCTIONS.md`)
- Integration with all setup scripts (k3d, Kind, Minikube)

### Fixed
- k3d cluster configuration - removed conflicting network/subnet settings
- k3d registry port conflict with macOS AirPlay Receiver (port 5000)
  - Added interactive port selection with validation
  - Default port changed to 5050
  - Port availability check before creating registry
- Bash 3.2 compatibility in test scripts (removed associative arrays)
- HTML parsing in load balancing test script

### Improved
- k3d setup script with better port handling and user guidance
- All setup scripts now show clear next steps after completion
- Added testing section to k3d README
- Documentation for macOS-specific issues (AirPlay Receiver port conflict)

### Changed
- Removed emojis from `LOAD_BALANCING_EXPLAINED.md` for consistency

## [1.0.1] - 2025-12-15

### Fixed
- Removed unused CLUSTER_NAME variable from minikube/setup.sh
- Fixed shellcheck warning in setup scripts

### Improved
- Better ASCII diagram formatting in Architecture documentation
- Improved text alignment in install-tools.sh header
- Added repository badges to README.md

## [1.0.0] - 2025-12-12

### Added
- Initial release of Kubernetes on macOS setup repository
- Support for three Kubernetes solutions: Kind, k3d, and Minikube
- Automated setup and teardown scripts for each solution
- Comprehensive documentation including:
  - Quick Start Guide
  - Getting Started Guide
  - Detailed Comparison of Solutions
  - Architecture Documentation
  - GitHub Setup Instructions
- Example hello-world application
- Interactive installation script for all tools
- Multi-node cluster configurations
- MIT License

### Features
- **Kind**: Multi-node cluster support with 1 control-plane + 2 workers
- **k3d**: Fast lightweight clusters with built-in LoadBalancer
- **Minikube**: Full Kubernetes with rich addon ecosystem
- Professional documentation without emojis
- No local path references for public use
- Ready for GitHub publication

### Documentation
- 8 comprehensive markdown files
- 7 automated shell scripts
- 3 cluster configuration files
- Complete setup instructions
- Troubleshooting guides
- Learning resources

## Future Plans
- Add more example applications
- Add Helm charts examples
- Add CI/CD pipeline examples
- Add monitoring and logging setups
- Add security best practices guide
