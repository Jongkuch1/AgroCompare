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

Both the backend and frontend Docker images built successfully on PR #33.
Both jobs then failed during installation of Trivy v0.69.3 with exit code 1.
Neither image was scanned, no vulnerability report was produced, and the
critical-findings check was skipped.

The workflow is configured to report high and critical findings with
available fixes and to fail on critical findings with available fixes.
Follow-up: investigate the installation failure, rerun both image scans,
and record the findings and any remediation here.
