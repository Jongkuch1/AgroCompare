<!-- Owner: be-niy (Summative Part 4: README, architecture diagram, CHANGELOG, observability) -->

# Changelog

Notable changes to AgroCompare, grouped by assignment.

The Summative section records the team's implementation work and intended
integration. A release is not considered verified until deployment and
runtime checks pass.

## [Unreleased] — Summative: Git-to-Production

### Added

- Terraform configuration for a virtual network with public, private
  application and delegated database subnets.
- Bastion host, private application VM and associated network security groups.
- Public load balancer with an HTTP health probe and explicit outbound
  connectivity for the application VM.
- Authenticated Azure Container Registry with shared admin access disabled.
- Managed PostgreSQL configuration with private DNS, public access disabled
  and a generated administrator password.
- Terraform outputs for application, bastion, registry and database settings.
- README operations section with architecture, setup, deployment design
  and observability instructions.
- Individual checklist covering the 10 demo prompts.
- Security documentation covering findings, remediation and accepted risks.

### Changed

- Trivy runs through its official container image.
- Infrastructure design separates public web access, administrative SSH
  access and the private application server.
- Documentation brings together the F1, F2, F3 and Summative work.

### Deployment Integration

The planned CD workflow runs checks after a merge to main, builds and scans
images, publishes them to ACR, deploys through Ansible and tests the live URL.

Final verification covers the private VM inventory, registry authentication,
image deployment, IaC scanning, required checks and public application health.

## F3 — Infrastructure as Code and DevSecOps

### Added

- Initial Terraform configuration for an Azure VM, network, security rules
  and outputs.
- Ansible configuration management and subsequent role refactoring.
- Current roles: docker, deploy, firewall and ssh_hardening.
- Dynamic inventory sourced from Terraform outputs.
- Dependency scanning with pip-audit and npm audit.
- Backend and frontend image scanning with Trivy.
- Secret scanning with Gitleaks.
- Reported Checkov review and documented decisions, described in SECURITY.md.
- Security findings and remediation documentation.

### Changed

- Documented upgrades to Flask 3.1.3, Flask-CORS 6.0.5 and pytest 9.2.0
  in response to dependency findings.
- Earlier Trivy action downloads authenticated with GITHUB_TOKEN.
- Alpine packages upgraded in the frontend image to address reported
  critical findings.
- Security workflow token permissions restricted to contents: read.
- Compose deployment rebuilds when the application checkout changes.

## F2 — Containerization and Continuous Integration

### Added

- Backend and frontend Dockerfiles.
- Docker Compose configuration exposing the frontend on port 8080 and
  the backend on port 5000.
- Backend container health check and frontend startup dependency.
- GitHub Actions frontend lint, tests and build.
- Backend lint and tests.
- Docker image build checks.
- Container setup, troubleshooting and CI documentation.

## F1 — Project Planning and Application Baseline

### Added

- Shared repository, project board and issue tracking.
- Pull-request collaboration, code ownership and branch protection work.
- Flask API serving sample crop price data.
- React frontend with filtering and market comparison.
- Application tests.
- README covering context, team, features and contributor setup.
