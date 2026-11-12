# Security scan findings — Formative 3

Evidence: [Security scans on PR #33](https://github.com/Jongkuch1/AgroCompare/pull/33/checks).

## Backend dependencies

The initial `pip-audit` reported 12 entries across three packages,
representing six unique advisory IDs. PR #33 updated the affected
versions in `backend/requirements.txt`:

| Package | Before | After | Advisory IDs |
| --- | --- | --- | --- |
| Flask | 3.0.3 | 3.1.3 | PYSEC-2026-2151 |
| Flask-CORS | 4.0.1 | 6.0.5 | PYSEC-2024-71, PYSEC-2026-1383, PYSEC-2026-1384, PYSEC-2026-1385 |
| pytest | 8.3.3 | 9.2.0 | PYSEC-2026-1845 |

After the updates, Agertu's local audit reported no known vulnerabilities
and all six backend tests passed. The Python dependency scan also passed
in the observed PR run.

## Frontend dependencies

The initial full `npm audit` reported two findings: one moderate and one
high. The output identified esbuild advisory GHSA-67mh-4wv8-2f99 in
Vite's dependency tree. npm proposed a breaking Vite upgrade.

Agertu's local production-only audit (`npm audit --omit=dev`) reported
zero vulnerabilities. The Node audit job passed in the observed PR run.
CI blocks high or critical findings in production dependencies. The full
audit, which includes development dependencies, is informational. The
production-only result does not establish that the development findings
were fixed; remediation has not been verified.

## Container images

Both the backend and frontend Docker images built successfully on PR #33,
but both jobs then failed during installation of Trivy v0.69.3 with exit
code 1. Neither image was scanned at that point.

The root cause (PR #37): `setup-trivy` downloads the Trivy binary via the
GitHub API, which caps unauthenticated requests at 60/hour. CI was hitting
that limit before the scan ever ran. The fix passes `GITHUB_TOKEN` to both
Trivy steps so the download uses the authenticated 5000/hour limit instead.

With the scan actually running, the frontend image came back with 3
CRITICAL findings, all with a fix available:

| Package | Installed | Fixed | Advisory |
| --- | --- | --- | --- |
| brotli-libs | 1.1.0-r2 | 1.1.1-r0 | CVE-2026-111497 |
| libcrypto3 | 3.3.3-r0 | 3.3.7-r0 | CVE-2026-31789 |
| libssl3 | 3.3.3-r0 | 3.3.7-r0 | CVE-2026-31789 |

These come from Alpine packages baked into the pinned `nginx:1.27-alpine`
base image. Fixed (also PR #37) by running `apk upgrade` in that build
stage, which pulls in Alpine's patched package versions without changing
the base image tag. The backend image had no CRITICAL findings. Both image
scans now pass — evidence:
[Security scans on PR #37](https://github.com/Jongkuch1/AgroCompare/pull/37/checks).

## Secrets

Gitleaks scans every commit on every pull request and push to `main`, plus
a weekly scheduled run. A local run against the full commit history (`gitleaks
detect --source . --log-opts="--all"`) came back clean: no leaked keys,
tokens, or credentials in any commit. `.gitignore` already keeps
`terraform.tfvars` and `*.tfstate` (where real secrets would otherwise end
up) out of version control, so this is a second, independent check on top
of that.
