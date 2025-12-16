# Changelog

All notable changes to this project will be documented in this file.

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
