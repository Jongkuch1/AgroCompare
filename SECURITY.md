# Security Findings and Limitations

This document records reported security findings, remediation and the
configuration reviewed for the Summative.

Historical scan results apply to the commits scanned at that time.
They do not establish the security of the latest images or deployment.

## 1. Backend Dependencies

The previous security record reports that the initial pip-audit run
found 12 entries across three packages, representing six unique
advisory IDs.

PR #33 updated the affected dependencies:

| Package | Before | After | Reported advisory IDs |
| --- | --- | --- | --- |
| Flask | 3.0.3 | 3.1.3 | PYSEC-2026-2151 |
| Flask-CORS | 4.0.1 | 6.0.5 | PYSEC-2024-71, PYSEC-2026-1383, PYSEC-2026-1384, PYSEC-2026-1385 |
| pytest | 8.3.3 | 9.2.0 | PYSEC-2026-1845 |

The previous record states that Agertu's local audit reported no known
vulnerabilities after these changes, all six backend tests passed,
and the Python dependency scan passed in the observed PR run.

Historical evidence:
[PR #33 checks](https://github.com/Jongkuch1/AgroCompare/pull/33/checks).

These package versions and advisory identifiers are retained from the
earlier project record. Confirm them against the original scan logs
when preparing the final evidence.

## 2. Frontend Dependencies

The previous full npm audit reported two findings: one moderate and
one high. The recorded output identified esbuild advisory
`GHSA-67mh-4wv8-2f99` in Vite's dependency tree. npm proposed a breaking
Vite upgrade.

Agertu's reported production-only audit, using `npm audit --omit=dev`,
found zero vulnerabilities. The Node audit job passed in the observed
PR run.

The current workflow:

- Fails on high or critical findings in production dependencies.
- Runs a full dependency audit as an informational step.

The production-only result does not establish that development
dependency findings were fixed. Development dependencies execute
during development and builds, so their findings still require review.

## 3. Container Images

### Historical findings and remediation

The earlier project record states that both images built on PR #33,
but Trivy installation failed before either image was scanned.

PR #37 addressed a reported GitHub API rate-limit problem by supplying
`GITHUB_TOKEN` to the Trivy action.

Once scanning ran, the frontend image reportedly contained these
three critical package findings:

| Package | Installed | Fixed | Reported advisory |
| --- | --- | --- | --- |
| brotli-libs | 1.1.0-r2 | 1.1.1-r0 | CVE-2026-111497 |
| libcrypto3 | 3.3.3-r0 | 3.3.7-r0 | CVE-2026-31789 |
| libssl3 | 3.3.3-r0 | 3.3.7-r0 | CVE-2026-31789 |

The documented remediation upgraded Alpine packages in the frontend
image build. The earlier record states that the backend had no
critical findings and both image scans subsequently passed.

Historical evidence:
[PR #37 checks](https://github.com/Jongkuch1/AgroCompare/pull/37/checks).

The table preserves the earlier record. Verify package versions and
advisory identifiers against the original logs before final submission.

### Current scanner configuration

PR #44 changed scanning to the official
`aquasec/trivy:0.58.0` container image.

Historical change:
[PR #44](https://github.com/Jongkuch1/sokowatch/pull/44).

The reviewed workflow builds and scans both application images:

- An informational step reports HIGH and CRITICAL findings.
- A blocking step fails on CRITICAL findings.
- Both steps use `--ignore-unfixed`.

Consequently, the report and failure gate exclude unfixed
vulnerabilities. A passing result does not mean that no critical
vulnerabilities exist.

This policy needs review against the assignment requirement to fail
the build when critical vulnerabilities are detected.

### Evidence still required

For the final image scan record, capture:

- Workflow run URL and source commit.
- Backend and frontend image identifiers.
- Scanner version and scan date.
- Actual HIGH and CRITICAL findings.
- Remediation or a documented decision for each finding.
- Findings excluded by the current scan policy.

Latest scan results have not been verified in this documentation review.

## 4. Secret Scanning

The security workflow uses Gitleaks and checks out the full Git history.
It runs on pull requests, pushes to `main`, a weekly schedule and
manual requests.

The earlier project record reports that this local command found
no secrets:

```bash
gitleaks detect --source . --log-opts="--all"
```

That result means no secrets were detected by that run and its rules.
It does not guarantee that every possible credential was absent.

Ignore rules help prevent Terraform variable and state files from
being added accidentally. They do not remove files already tracked
or secrets previously committed.

Never commit:

- Private SSH keys.
- Cloud credentials or registry tokens.
- Database passwords.
- Terraform variable files containing credentials.
- Terraform state or saved plans containing sensitive data.

Terraform generates the database password and stores it in state.
Marking an output `sensitive` hides normal display; it does not remove
the secret from state. Protect state access and any backups.

## 5. Current Automated Scans

Configuration reviewed from `origin/main` at commit `c6cd746`.

| Scan | Tool | Current failure condition |
| --- | --- | --- |
| Python dependencies | pip-audit | Known vulnerabilities |
| Production JavaScript dependencies | npm audit | High or critical findings |
| Full JavaScript dependency audit | npm audit | Informational; step permits failure |
| Secrets | Gitleaks | Detected leaks according to its rules |
| Backend and frontend images | Trivy | Critical findings with an available fix |
| Infrastructure as Code | Not integrated in the reviewed workflows | No automated gate verified |

The security workflow has `contents: read` permissions.

Scan configuration establishes intended behavior. Workflow run results
must be checked separately.

## 6. Infrastructure Security

The following describes Terraform configuration, not verified deployed
cloud state.

### Network and application VM

- The application VM is configured without a public IP.
- A bastion host provides the intended SSH access path.
- A public load balancer forwards HTTP traffic to the application port.
- The load balancer probes `/api/health`.

The reviewed public entry point uses HTTP. HTTPS termination has not
been demonstrated in the reviewed configuration.

### Container registry

ACR is configured with:

- Basic service tier.
- Shared administrator account disabled.
- A public network endpoint.

Registry access requires authentication. The registry should not be
described as having a private network endpoint.

The reviewed Ansible role does not yet authenticate to ACR or pull
published images. Registry permissions and deployment identities remain
to be verified during integration.

### Managed PostgreSQL

PostgreSQL is configured with:

- A delegated database subnet.
- Private DNS.
- Public network access disabled.
- A generated administrator password.
- Seven-day backup retention.

The database NSG explicitly allows port 5432 from the application
subnet. Default rules also allow other virtual-network traffic, so
the configuration does not establish exclusive access from the app VM.

The reviewed Compose configuration does not pass database connection
settings to the backend. Application database use is not verified.

### Declared scanner suppressions

Terraform contains Checkov suppression comments for registry and
database resources.

Their stated reasons include Basic-tier cost constraints, unavailable
Premium features, public registry connectivity for the runner, and
using Trivy instead of paid image scanning.

These comments are declared exceptions, not evidence that Checkov ran
or that the exceptions were independently approved. Validate each check
identifier, its applicability and its justification when IaC scanning
is integrated.

## 7. Deployment Limitations

The reviewed repository does not contain a CD workflow.

The current Ansible deployment role clones `main` and builds the
application on the VM using Docker Compose.

The dynamic inventory still expects `public_ip_address`, while the
new Terraform configuration exposes `app_private_ip` and
`bastion_public_ip`. Private VM targeting and SSH through the bastion
require integration.

The following are not yet verified:

- Automated IaC scanning.
- Enforcement of required security checks before merging.
- Registry-based deployment through Ansible.
- Deployment credentials and their permissions.
- Successful cloud deployment.
- Runtime health and public application availability.
- The relationship between a deployed image and its source commit.

## 8. Final Verification Checklist

- [ ] Record current dependency and image scan run links and commits.
- [ ] Confirm historical advisory identifiers against original logs.
- [ ] Review excluded unfixed vulnerabilities.
- [ ] Verify the critical-vulnerability gate meets the assignment.
- [ ] Integrate IaC scanning and document actual results.
- [ ] Review Terraform suppressions with the infrastructure owner.
- [ ] Verify GitHub branch protection and required security checks.
- [ ] Verify registry authentication and deployment permissions.
- [ ] Confirm Ansible targets the private VM through the bastion.
- [ ] Verify the public health endpoint and application features.
- [ ] Update this document after integration without replacing
      historical evidence with unsupported claims.

## Related Documentation

- [README.md](README.md)
- [CHANGELOG.md](CHANGELOG.md)
- [Demo checklist](docs/DEMO_CHECKLIST.md)# Security Findings and Limitations

This document records reported security findings, remediation and the
configuration reviewed for the Summative.

Historical scan results apply to the commits scanned at that time.
They do not establish the security of the latest images or deployment.

## 1. Backend Dependencies

The previous security record reports that the initial pip-audit run
found 12 entries across three packages, representing six unique
advisory IDs.

PR #33 updated the affected dependencies:

| Package | Before | After | Reported advisory IDs |
| --- | --- | --- | --- |
| Flask | 3.0.3 | 3.1.3 | PYSEC-2026-2151 |
| Flask-CORS | 4.0.1 | 6.0.5 | PYSEC-2024-71, PYSEC-2026-1383, PYSEC-2026-1384, PYSEC-2026-1385 |
| pytest | 8.3.3 | 9.2.0 | PYSEC-2026-1845 |

The previous record states that Agertu's local audit reported no known
vulnerabilities after these changes, all six backend tests passed,
and the Python dependency scan passed in the observed PR run.

Historical evidence:
[PR #33 checks](https://github.com/Jongkuch1/AgroCompare/pull/33/checks).

These package versions and advisory identifiers are retained from the
earlier project record. Confirm them against the original scan logs
when preparing the final evidence.

## 2. Frontend Dependencies

The previous full npm audit reported two findings: one moderate and
one high. The recorded output identified esbuild advisory
`GHSA-67mh-4wv8-2f99` in Vite's dependency tree. npm proposed a breaking
Vite upgrade.

Agertu's reported production-only audit, using `npm audit --omit=dev`,
found zero vulnerabilities. The Node audit job passed in the observed
PR run.

The current workflow:

- Fails on high or critical findings in production dependencies.
- Runs a full dependency audit as an informational step.

The production-only result does not establish that development
dependency findings were fixed. Development dependencies execute
during development and builds, so their findings still require review.

## 3. Container Images

### Historical findings and remediation

The earlier project record states that both images built on PR #33,
but Trivy installation failed before either image was scanned.

PR #37 addressed a reported GitHub API rate-limit problem by supplying
`GITHUB_TOKEN` to the Trivy action.

Once scanning ran, the frontend image reportedly contained these
three critical package findings:

| Package | Installed | Fixed | Reported advisory |
| --- | --- | --- | --- |
| brotli-libs | 1.1.0-r2 | 1.1.1-r0 | CVE-2026-111497 |
| libcrypto3 | 3.3.3-r0 | 3.3.7-r0 | CVE-2026-31789 |
| libssl3 | 3.3.3-r0 | 3.3.7-r0 | CVE-2026-31789 |

The documented remediation upgraded Alpine packages in the frontend
image build. The earlier record states that the backend had no
critical findings and both image scans subsequently passed.

Historical evidence:
[PR #37 checks](https://github.com/Jongkuch1/AgroCompare/pull/37/checks).

The table preserves the earlier record. Verify package versions and
advisory identifiers against the original logs before final submission.

### Current scanner configuration

PR #44 changed scanning to the official
`aquasec/trivy:0.58.0` container image.

Historical change:
[PR #44](https://github.com/Jongkuch1/sokowatch/pull/44).

The reviewed workflow builds and scans both application images:

- An informational step reports HIGH and CRITICAL findings.
- A blocking step fails on CRITICAL findings.
- Both steps use `--ignore-unfixed`.

Consequently, the report and failure gate exclude unfixed
vulnerabilities. A passing result does not mean that no critical
vulnerabilities exist.

This policy needs review against the assignment requirement to fail
the build when critical vulnerabilities are detected.

### Evidence still required

For the final image scan record, capture:

- Workflow run URL and source commit.
- Backend and frontend image identifiers.
- Scanner version and scan date.
- Actual HIGH and CRITICAL findings.
- Remediation or a documented decision for each finding.
- Findings excluded by the current scan policy.

Latest scan results have not been verified in this documentation review.

## 4. Secret Scanning

The security workflow uses Gitleaks and checks out the full Git history.
It runs on pull requests, pushes to `main`, a weekly schedule and
manual requests.

The earlier project record reports that this local command found
no secrets:

```bash
gitleaks detect --source . --log-opts="--all"
```

That result means no secrets were detected by that run and its rules.
It does not guarantee that every possible credential was absent.

Ignore rules help prevent Terraform variable and state files from
being added accidentally. They do not remove files already tracked
or secrets previously committed.

Never commit:

- Private SSH keys.
- Cloud credentials or registry tokens.
- Database passwords.
- Terraform variable files containing credentials.
- Terraform state or saved plans containing sensitive data.

Terraform generates the database password and stores it in state.
Marking an output `sensitive` hides normal display; it does not remove
the secret from state. Protect state access and any backups.

## 5. Current Automated Scans

Configuration reviewed from `origin/main` at commit `c6cd746`.

| Scan | Tool | Current failure condition |
| --- | --- | --- |
| Python dependencies | pip-audit | Known vulnerabilities |
| Production JavaScript dependencies | npm audit | High or critical findings |
| Full JavaScript dependency audit | npm audit | Informational; step permits failure |
| Secrets | Gitleaks | Detected leaks according to its rules |
| Backend and frontend images | Trivy | Critical findings with an available fix |
| Infrastructure as Code | Not integrated in the reviewed workflows | No automated gate verified |

The security workflow has `contents: read` permissions.

Scan configuration establishes intended behavior. Workflow run results
must be checked separately.

## 6. Infrastructure Security

The following describes Terraform configuration, not verified deployed
cloud state.

### Network and application VM

- The application VM is configured without a public IP.
- A bastion host provides the intended SSH access path.
- A public load balancer forwards HTTP traffic to the application port.
- The load balancer probes `/api/health`.

The reviewed public entry point uses HTTP. HTTPS termination has not
been demonstrated in the reviewed configuration.

### Container registry

ACR is configured with:

- Basic service tier.
- Shared administrator account disabled.
- A public network endpoint.

Registry access requires authentication. The registry should not be
described as having a private network endpoint.

The reviewed Ansible role does not yet authenticate to ACR or pull
published images. Registry permissions and deployment identities remain
to be verified during integration.

### Managed PostgreSQL

PostgreSQL is configured with:

- A delegated database subnet.
- Private DNS.
- Public network access disabled.
- A generated administrator password.
- Seven-day backup retention.

The database NSG explicitly allows port 5432 from the application
subnet. Default rules also allow other virtual-network traffic, so
the configuration does not establish exclusive access from the app VM.

The reviewed Compose configuration does not pass database connection
settings to the backend. Application database use is not verified.

### Declared scanner suppressions

Terraform contains Checkov suppression comments for registry and
database resources.

Their stated reasons include Basic-tier cost constraints, unavailable
Premium features, public registry connectivity for the runner, and
using Trivy instead of paid image scanning.

These comments are declared exceptions, not evidence that Checkov ran
or that the exceptions were independently approved. Validate each check
identifier, its applicability and its justification when IaC scanning
is integrated.

## 7. Deployment Limitations

The reviewed repository does not contain a CD workflow.

The current Ansible deployment role clones `main` and builds the
application on the VM using Docker Compose.

The dynamic inventory still expects `public_ip_address`, while the
new Terraform configuration exposes `app_private_ip` and
`bastion_public_ip`. Private VM targeting and SSH through the bastion
require integration.

The following are not yet verified:

- Automated IaC scanning.
- Enforcement of required security checks before merging.
- Registry-based deployment through Ansible.
- Deployment credentials and their permissions.
- Successful cloud deployment.
- Runtime health and public application availability.
- The relationship between a deployed image and its source commit.

## 8. Final Verification Checklist

- [ ] Record current dependency and image scan run links and commits.
- [ ] Confirm historical advisory identifiers against original logs.
- [ ] Review excluded unfixed vulnerabilities.
- [ ] Verify the critical-vulnerability gate meets the assignment.
- [ ] Integrate IaC scanning and document actual results.
- [ ] Review Terraform suppressions with the infrastructure owner.
- [ ] Verify GitHub branch protection and required security checks.
- [ ] Verify registry authentication and deployment permissions.
- [ ] Confirm Ansible targets the private VM through the bastion.
- [ ] Verify the public health endpoint and application features.
- [ ] Update this document after integration without replacing
      historical evidence with unsupported claims.

## Related Documentation

- [README.md](README.md)
- [CHANGELOG.md](CHANGELOG.md)
- [Demo checklist](docs/DEMO_CHECKLIST.md)
