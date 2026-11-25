# Security

**Owner:** be-niy — Summative Part 4: documentation and observability.

This document explains the project's security checks, reported findings,
remediation and infrastructure controls.

Historical results describe the revisions scanned at that time. Current
deployment and scan evidence must be checked before final submission.

## Reporting a Problem

Contact a repository maintainer privately about vulnerabilities.

If private vulnerability reporting is enabled, use the repository's
Security tab and select “Report a vulnerability.” Avoid publishing
credentials or exploit details in a public issue.

## What Is Scanned, and When

Dependency, image and secret checks run through the security workflow on
pull requests, pushes to main, a weekly schedule and manual requests.

The colleague-provided plan also includes Checkov in `iac-scan.yml`.
Confirm that workflow's integration and triggers against the final repository.

| Scan | Tool | Scope | Failure policy |
| --- | --- | --- | --- |
| Python dependencies | pip-audit | backend/requirements.txt | Known vulnerabilities |
| Production JavaScript dependencies | npm audit | Frontend dependencies | High or critical findings |
| Full JavaScript dependency audit | npm audit | Includes development tools | Informational |
| Container images | Trivy | Backend and frontend images | Critical findings with available fixes |
| Secrets | Gitleaks | Repository history available to the scan | Detected leaks |
| Infrastructure | Checkov | Terraform, Ansible, Dockerfiles and workflows | Planned gate: failed checks except documented suppressions |

Trivy currently uses `--ignore-unfixed`. Unfixed vulnerabilities are excluded
from the report and failure gate. Review this policy against the assignment's
critical-vulnerability requirement.

## Findings and Decisions

### 1. Python Dependencies

The earlier project record reports 12 entries across three packages,
representing six unique advisory IDs.

| Package | Previous version | Reported advisories | Updated version |
| --- | --- | --- | --- |
| Flask | 3.0.3 | PYSEC-2026-2151 | 3.1.3 |
| Flask-CORS | 4.0.1 | PYSEC-2024-71, PYSEC-2026-1383, PYSEC-2026-1384, PYSEC-2026-1385 | 6.0.5 |
| pytest | 8.3.3 | PYSEC-2026-1845 | 9.2.0 |

The colleague-reported result after upgrading was no known vulnerabilities,
six passing backend tests on Python 3.11, and clean Flake8 output.

Historical evidence:
[PR #33 checks](https://github.com/Jongkuch1/AgroCompare/pull/33/checks).

Retain the original logs to support the reported advisory identifiers,
package versions and results.

### 2. JavaScript Dependencies

The colleague-provided record identifies development-tool findings involving
esbuild and Vite, including `GHSA-67mh-4wv8-2f99`.

The reported production-only audit returned zero vulnerabilities.

**Decision:** Defer the breaking frontend toolchain upgrade for separate
testing. The production frontend serves built static files through Nginx.

Development tools also run during builds, so their findings remain relevant
even when they are absent from the final runtime image.

**Mitigation:** Do not expose the development server to untrusted networks.

**Review:** Reassess during the next frontend upgrade and scheduled audits.
Confirm the required target version against the current audit output.

### 3. Infrastructure Scanning with Checkov

The following findings and results were supplied by the colleague responsible
for this work. They describe the earlier infrastructure review.

| Check | Reported location | Decision | Reported rationale |
| --- | --- | --- | --- |
| CKV_AZURE_50 | terraform/main.tf | Fixed | Disable VM extension operations because configuration uses Ansible |
| CKV2_GHA_1 | .github/workflows/ci.yml | Fixed | Restrict workflow token permissions |
| CKV_AZURE_119 | terraform/main.tf | Accepted for the earlier design | Public application access constrained by network security rules |
| CKV_DOCKER_3 | frontend/Dockerfile | Accepted | Nginx master starts as root; consider an unprivileged image |
| CKV2_ANSIBLE_1 | Earlier ansible/roles/app | Accepted | HTTP checks target localhost |

The colleague reported:

- Terraform: 14 passed checks and one documented skip.
- Ansible: 10 passed checks.
- Dockerfiles: 88 passed checks.
- GitHub Actions: 164 passed checks.

**Evidence to attach:** Original Checkov output or workflow run URL and commit.

These counts must not be presented as results for the new architecture
without rescanning it. The current private application VM changes the context
of the earlier public-IP exception.

New registry and database resources include additional inline suppression
comments. Review their check identifiers and stated reasons with the
infrastructure owner and include the final scan results.

### 4. Container Images with Trivy

#### Earlier Findings

The earlier record states that images built successfully on PR #33, but
scanner installation failed before scans completed.

PR #37 addressed a reported GitHub API rate-limit issue by authenticating
the Trivy action download.

The frontend scan subsequently reported:

| Package | Installed | Fixed | Reported advisory |
| --- | --- | --- | --- |
| brotli-libs | 1.1.0-r2 | 1.1.1-r0 | CVE-2026-111497 |
| libcrypto3 | 3.3.3-r0 | 3.3.7-r0 | CVE-2026-31789 |
| libssl3 | 3.3.3-r0 | 3.3.7-r0 | CVE-2026-31789 |

**Reported action:** Upgrade Alpine packages in the frontend image build.

The historical record reports passing image scans afterward, with no critical
backend findings under that scan's policy.

Historical evidence:
[PR #37 checks](https://github.com/Jongkuch1/AgroCompare/pull/37/checks).

Retain the original logs supporting the table.

#### Current Scanner

PR #44 changed scanning to the official `aquasec/trivy:0.58.0` container.

Trivy runs twice per image:

1. Informational HIGH and CRITICAL report.
2. Failure gate for CRITICAL findings with available fixes.

Both steps exclude unfixed vulnerabilities.

#### Final Summative Results

| Evidence | Backend | Frontend |
| --- | --- | --- |
| Run URL | [Run 45398499542](https://github.com/Jongkuch1/AgroCompare/actions/runs/45398499542) | [Run 45398499542](https://github.com/Jongkuch1/AgroCompare/actions/runs/45398499542) |
| Source commit/image identifier | `e818c0d` | `e818c0d` |
| Scan date | 2026-11-24 | 2026-11-24 |
| HIGH findings | 2 (`jaraco.context` CVE-2026-23949, `wheel` CVE-2026-24049) | 0 |
| CRITICAL findings | 0 | 0 |
| Remediation or risk decision | Accepted: both are fixed-version findings in Python packaging tools (`jaraco.context`, `wheel`) pulled in transitively at build time, not runtime application code. Fixes exist (6.1.0 and 0.46.2) and will be picked up on the next `backend/requirements.txt` dependency bump. The CRITICAL gate (which blocks the build) reported zero findings, so this did not require a release block. | No findings reported; recorded with the scan policy and run link rather than inferred from a green workflow alone. |

## Secret Scanning

Gitleaks is included in the security workflow.

The previous record reports no detected secrets from a local full-history run:

```bash
gitleaks detect --source . --log-opts="--all"
```

This is a scanner result, not a guarantee that all possible secrets are absent.

Ignore rules help prevent accidental commits of variable and state files.
They do not remove files already tracked or credentials previously committed.

Protect:

- Cloud credentials and deployment tokens.
- SSH private keys.
- Registry credentials.
- Database passwords.
- Terraform state, backups and sensitive plans.

Terraform-generated passwords remain stored in state even when their
outputs are marked sensitive.

## Infrastructure Security Controls

The following combines the team's architecture and intended deployment
controls. Verify deployed behavior and the final workflow before submission.

| Control | Description |
| --- | --- |
| Private application VM | No public application VM IP; administrative access goes through the bastion |
| Bastion | Administrator SSH access constrained by the configured source range |
| Load balancer | Public web entry point with an HTTP health probe |
| Database | Public network access disabled; delegated subnet and private DNS |
| Registry | Authentication required and shared administrator account disabled |
| Server hardening | Ansible roles cover firewall and SSH hardening; verify individual settings against the final roles |
| Deployment access | Planned temporary runner SSH rule, removed after deployment |
| Deployment gates | Planned dependency, image and IaC checks before publication and deployment |
| Container privileges | Backend non-root execution and frontend privilege decisions documented by the team |
| Credentials | Intended use of protected secrets and scoped deployment identities |

### Important Scope Details

- ACR's endpoint is public even though registry contents require authentication.
- Database NSG default rules permit other VNet traffic; an explicit app-subnet
  allow rule does not establish exclusive app access.
- The reviewed web entry point uses HTTP; HTTPS has not been demonstrated.
- Registry pulls, temporary SSH rules and deployment gates must be confirmed
  against the completed CD implementation.
- Health responses do not prove database connectivity.

## Accepted Risks and Review Points

| Risk | Team rationale or context | Review point |
| --- | --- | --- |
| Development-tool advisories | Separate breaking upgrade requires testing | Next frontend upgrade |
| Public bastion and load balancer | Required administrative and web entry points | Periodic network review |
| Basic-tier ACR limitations | Course cost constraints | Before real production traffic |
| Public registry endpoint | Authenticated access supports runner connectivity | Before stronger network isolation is required |
| No geo-redundant database backup | Demo cost constraints | Before storing valuable data |
| Nginx master privileges | Official image behavior | Consider an unprivileged image |
| Local HTTP probes | Checks stay on the server | Reassess if the request path changes |
| Public HTTP | Current demonstration entry point | Before handling sensitive production traffic |
| Unfixed vulnerabilities excluded by Trivy | Current scan configuration | Before final security gate approval |

A suppression comment records a decision; it does not prove that a scanner
ran or that the underlying risk disappeared.

## Final Evidence Checklist

- [ ] Attach current dependency and image scan runs.
- [ ] Complete the backend/frontend Trivy results.
- [ ] Attach the colleague's historical Checkov evidence.
- [ ] Scan the final infrastructure and review suppressions.
- [ ] Verify the critical-vulnerability gate.
- [ ] Verify required security checks in branch protection.
- [ ] Verify registry permissions and deployment credentials.
- [ ] Verify bastion access and temporary rule cleanup.
- [ ] Record a successful CD run and deployed revision.
- [ ] Verify public health and application functionality.

## Related Documents

- [README.md](README.md)
- [CHANGELOG.md](CHANGELOG.md)
- [Demo checklist](docs/DEMO_CHECKLIST.md)
