<!-- Owner: be-niy (Summative Part 4: README, architecture diagram, CHANGELOG, observability) -->

# Individual Summative Demo Checklist

Each team member records their own demonstration of the application
and the complete DevOps workflow.

## Recording Requirements

- Target 10–15 minutes. Assessors stop watching after 18 minutes.
- Record at 720p or higher.
- Keep your face visible in a small webcam overlay.
- Increase terminal and editor font sizes.
- Narrate naturally while demonstrating real commands and outputs.
- Do not read from a script.
- Record in one continuous take. Minor cuts for technical issues
  are acceptable; do not combine separate recording sessions.
- Announce each prompt number before demonstrating it.
- Show the running system rather than slides or screenshots.
- Keep passwords, private keys and tokens off screen.

## Video Submission

Use this exact title format:

[Your Name] - Amani Market Systems - Summative Demo

For Beni:

Beni Niyogisubizo - Amani Market Systems - Summative Demo

Keep AgroCompare as the application name in the demonstration.

Upload to YouTube as **unlisted**, at least 24 hours before the deadline.
Allow time for processing, and test the link in an incognito window
without signing in.

## The 10 Demo Prompts

Spend approximately 1–1.5 minutes on each prompt.

| # | Prompt | What to demonstrate |
| --- | --- | --- |
| 1 | Project Foundation — F1 | Open the GitHub project board and current branch protection settings. Explain how issues, reviews and required checks support collaboration. |
| 2 | Application Baseline — F1 | Run the application and demonstrate its features. Show the README setup instructions. Check for fallback-data notices so the page does not conceal an unavailable API. |
| 3 | Containerization — F2 | Open the Dockerfiles, build and start the application with Docker Compose, and demonstrate it at localhost:8080. |
| 4 | CI Pipeline — F2 | Show a passing GitHub Actions run and a failing run that caught a real problem. Open the relevant steps and explain the failure. |
| 5 | Infrastructure as Code | Open the Terraform file structure. Run `terraform plan` or show recent pipeline plan output. Identify the network, bastion, private VM, load balancer, registry, database and security groups. |
| 6 | Configuration Management | Open the Ansible playbook, roles and inventory. Run the playbook against the target environment or show terminal output from a recent execution. Explain the task that prepares the application to serve traffic. |
| 7 | Security Scanning | Show a real scan and its results. Explain one finding and its remediation, justified suppression or documented risk decision. Explain the actual failure policy and any excluded findings. |
| 8 | Full Pipeline and Deployment | Merge an approved PR into main to trigger CD. Show the checks, image publication and Ansible deployment stages. Open the live application and demonstrate usable features. |
| 9 | Observability | Show the live health endpoint, container status or logs. Explain what the signal proves and its limits. |
| 10 | Reflection and Ownership | Show commit history across the Formatives and Summative. Explain your most important design decision, the weakest part of the pipeline, and what you would fix first before a real production launch. |

## Integration Readiness

The reviewed implementation still has pending integration work.
Recheck this list against the latest repository before recording.

- [ ] CD workflow exists and deploys after a merge to main.
- [ ] CD runs the required checks before deployment.
- [ ] Images are published to the private registry.
- [ ] Ansible authenticates to the registry and deploys those images.
- [ ] Inventory uses the current Terraform outputs and reaches the
      private VM through the bastion.
- [ ] Automated IaC scanning is integrated.
- [ ] Critical-vulnerability failure behavior meets the assignment.
- [ ] Required checks are enforced by GitHub branch protection.
- [ ] The application is publicly accessible and usable.
- [ ] README contains the verified live URL.
- [ ] Security findings and limitations match actual scan evidence.

An unfinished integration cannot be demonstrated as completed.
Documentation and a green build alone do not prove deployment.

## Before Recording

- [ ] Read all 10 prompts and prepare navigation bookmarks.
- [ ] Confirm the public application and API work.
- [ ] Confirm frontend filtering and market comparison work.
- [ ] Confirm the frontend is not silently using fallback data.
- [ ] Prepare a passing CI run and a genuine failing CI run.
- [ ] Prepare recent Terraform plan evidence.
- [ ] Prepare Ansible execution output.
- [ ] Prepare real security findings and remediation evidence.
- [ ] Coordinate the deployment demonstration with teammates.
- [ ] Use a meaningful change for the demonstration PR.
- [ ] Confirm cloud resources will stay available during recording.
- [ ] Test webcam, microphone and screen readability.
- [ ] Close unrelated windows and disable notifications.
- [ ] Avoid displaying credentials, state files or sensitive outputs.

## Useful Commands

Run these from the repository root unless noted otherwise.

### Local containers

docker compose up --build -d
docker compose ps
curl -fsS http://localhost:8080/api/health
docker compose logs --tail=100 backend frontend

### Commit history

git --no-pager log --graph --decorate --oneline -25

### Public health

curl -fsS http://<load-balancer-ip>/api/health

Replace the placeholder with the verified live address.

The expected health response is {"status":"ok"}.
This verifies the responding request path, not database connectivity
or every application feature.

Only the backend currently has a Compose health check.

## Reflection Preparation

Prepare your own answers rather than reading a prepared script:

1. What was the single most important design decision you made?
2. What is the weakest part of the pipeline today?
3. What would you fix first if the system were going live tomorrow?

Explain your individual contribution and distinguish it from
teammates' work.

## After Recording

- [ ] Confirm every prompt is covered in order.
- [ ] Confirm your face and narration are present.
- [ ] Confirm the video is readable and no secrets are exposed.
- [ ] Confirm the duration is within the required limits.
- [ ] Upload as unlisted with the required title.
- [ ] Wait for YouTube processing to finish.
- [ ] Test the link in an incognito window without signing in.

## Canvas Submission

URL field:

- GitHub repository URL.

Text entry box:

- Live Application URL.
- YouTube Demo Video Link.
- Summative PR URL into main.

## Infrastructure Teardown

Keep the live application available for the agreed assessment period.
Coordinate teardown with the team and instructor.

When the environment is no longer required, the infrastructure owner
can review and run `terraform destroy` from the Terraform directory.
This removes managed resources, including the database.
