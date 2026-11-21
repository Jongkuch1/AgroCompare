<!-- Owner: be-niy (Summative Part 4: README, architecture diagram, CHANGELOG, observability) -->

# Individual Summative Demo Checklist

Each person records their own demonstration.

## Recording Requirements

- Target 10–15 minutes; assessors stop after 18 minutes.
- Minimum 720p.
- Keep your face visible in a webcam overlay.
- Use readable terminal, browser and editor fonts.
- Narrate naturally without reading a script.
- Show actual commands and outputs.
- Record one continuous take; minor technical cuts are acceptable.
- Announce each prompt number.
- Keep passwords, tokens and private keys off screen.

## Upload Requirements

Upload to YouTube as **unlisted**, at least 24 hours before the deadline.

Title:

`[Your Name] - Amani Market Systems - Summative Demo`

For Beni:

`Beni Niyogisubizo - Amani Market Systems - Summative Demo`

Use AgroCompare as the application name elsewhere.

Wait for processing and test the link in an incognito window without signing in.

## The 10 Prompts

Spend approximately 1–1.5 minutes on each.

| # | Prompt | Demonstrate |
| --- | --- | --- |
| 1 | Project Foundation | Project board, branch protection, reviews and required checks |
| 2 | Application Baseline | Running application, features and README setup instructions |
| 3 | Containerization | Dockerfiles, Compose build/start and application on localhost:8080 |
| 4 | CI Pipeline | Passing run and genuine failing run; explain the relevant logs |
| 5 | Infrastructure as Code | Terraform structure and a plan or recent pipeline plan output; identify network, bastion, private VM, registry, database and load balancer |
| 6 | Configuration Management | Playbook and inventory; execution or recent terminal output; explain the important configuration task |
| 7 | Security Scanning | Actual scan results and one finding with its remediation or justified decision |
| 8 | Full Pipeline and Deployment | Merge an approved PR into main; show CD stages, successful deployment and usable live application |
| 9 | Observability | Live health endpoint, container status or logs; explain the signal and its limitations |
| 10 | Reflection and Ownership | Commit history, most important decision, weakest pipeline area and first improvement before production |

## Before Recording

- [ ] Final infrastructure and deployment integrations are complete.
- [ ] Required checks run and are enforced before merging.
- [ ] Images are published to ACR and deployed through Ansible.
- [ ] Private VM access works through the bastion.
- [ ] IaC and image scans have actual results available.
- [ ] Live application URL works.
- [ ] Filters and comparison work without an API fallback notice.
- [ ] README contains the verified live URL.
- [ ] Security findings match scan evidence.
- [ ] Passing and genuinely failing CI runs are ready.
- [ ] Recent Terraform plan and Ansible output are ready.
- [ ] Deployment demo is coordinated with teammates.
- [ ] Webcam, microphone and readability are tested.
- [ ] Notifications and unrelated windows are closed.
- [ ] No credentials or sensitive outputs will be displayed.

## Useful Commands

From the repository root:

```bash
docker compose up --build -d
docker compose ps
curl -fsS http://localhost:8080/api/health
docker compose logs --tail=100 backend frontend
git --no-pager log --graph --decorate --oneline -25
```

For the deployed application:

```bash
curl -fsS http://<load-balancer-ip>/api/health
```

Replace the placeholder with the verified address.

Expected response:

```json
{"status":"ok"}
```

Only the backend currently has a Compose health check. A successful health
response does not verify every feature or database connectivity.

## Reflection Preparation

Answer in your own words:

1. What was the single most important design decision you made?
2. What is the weakest part of the pipeline today?
3. What would you fix first if the system went live tomorrow?

Explain your contribution and distinguish it from teammates' work.

## After Recording

- [ ] All 10 prompts covered in order.
- [ ] Face visible and narration audible.
- [ ] Commands and output readable.
- [ ] No secrets exposed.
- [ ] Duration within the required limits.
- [ ] Correct title and unlisted visibility.
- [ ] YouTube processing complete.
- [ ] Link works in incognito without signing in.

## Canvas Submission

**URL field:** GitHub repository URL.

**Text entry box:**

- Live Application URL.
- YouTube Demo Video Link.
- Summative PR URL into main.

## Teardown

Coordinate with the team and assessment requirements. Keep the live application
available for the agreed review period.

When it is no longer required, review and run `terraform destroy` from
the Terraform directory. This removes managed infrastructure, including
the database.
