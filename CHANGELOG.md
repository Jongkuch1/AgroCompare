<!-- Owner: be-niy (Summative Part 4: README, architecture diagram, CHANGELOG, observability) -->
# Changelog

Notable changes to AgroCompare, grouped by assignment.
Configuration changes describe repository contents; successful cloud
deployment and runtime behavior require separate verification.

## [Unreleased] - Summative

### Added
- Terraform configuration for a bastion host, a private application VM,
  public and private subnets, and associated network security groups.
- Public Azure Load Balancer forwarding port 80 to the application port
  (8080 by default), with an HTTP probe at `/api/health`.
- Explicit outbound connectivity for the private application VM through
  the load balancer.
- Azure Container Registry using the Basic tier, with its shared admin
  account disabled. Registry access requires authentication; its network
  endpoint remains public.
- Managed PostgreSQL configuration with a delegated database subnet,
  private DNS, public database access disabled, and a generated password.
- Terraform outputs for the bastion, private application VM, load balancer,
  registry and database.
- Draft README production operations section covering architecture,
  setup and observability.
- Individual demo checklist covering all 10 assessment prompts.

### Changed
- Container scanning now runs through the official
  `aquasec/trivy:0.58.0` container image.
- Gitleaks scanning is retained alongside dependency and image scans.
- Security documentation distinguishes verified findings from limitations
  and evidence still awaiting verification.

### Pending integration and verification
- Continuous deployment workflow that runs checks, pushes images to ACR,
  and deploys through Ansible after a merge to `main`.
- Ansible inventory updated to use `app_private_ip` and
  `bastion_public_ip`, with SSH access through the bastion. The reviewed
  inventory still expects the previous `public_ip_address` output.
- Registry authentication and image pulls in the deployment role.
  The reviewed role currently clones `main` and builds with Compose
  on the application VM.
- Automated Infrastructure as Code scanning in GitHub Actions.
- Review of the Trivy failure policy: the current scans exclude unfixed
  vulnerabilities and fail only on critical findings with available fixes.
- Verification of required checks and review rules in GitHub.
- Live application URL, successful deployment evidence, and runtime
  health and logging verification.
- Verification of database use by the backend. The reviewed Compose
  configuration does not pass database connection settings.

## F3 - Infrastructure as Code and DevSecOps

### Added
- Initial Azure infrastructure configuration using Terraform.
- Ansible deployment and subsequent refactoring into `docker`, `deploy`,
  `firewall`, and `ssh_hardening` roles.
- Dynamic Ansible inventory reading Terraform outputs.
- Compose deployment that rebuilds when the repository checkout changes.
- GitHub Actions dependency scanning with pip-audit and npm audit.
- Backend and frontend container image scanning with Trivy.
- Gitleaks secret scanning with full repository history available.
- Security documentation recording findings, remediation and limitations.

### Changed
- Documented dependency upgrades to Flask 3.1.3, Flask-CORS 6.0.5,
  and pytest 9.2.0.
- Earlier Trivy action setup updated to use authenticated GitHub downloads.
- Frontend image build updated to upgrade Alpine packages in response
  to reported critical findings.
- Security workflow permissions restricted to `contents: read`.

## F2 - Containerization and Continuous Integration

### Added
- Backend and frontend Dockerfiles.
- Docker Compose configuration exposing the frontend on port 8080
  and the backend on port 5000.
- Backend health check, with frontend startup dependent on backend health.
- GitHub Actions checks for frontend lint, tests and production build.
- Backend lint and tests, plus Docker builds for both images.
- Container setup and CI instructions in the README.

## F1 - Project Planning and Application Baseline

### Added
- Shared repository, project planning and issue tracking.
- Pull-request collaboration and code ownership configuration.
- Flask API serving sample crop prices.
- React frontend with filtering and market comparison.
- Application tests and contributor setup documentation.
