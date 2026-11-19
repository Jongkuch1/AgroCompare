<!-- Owner: be-niy (Summative Part 4: README, architecture diagram, CHANGELOG, observability) -->
# Demo video checklist (each person records their own)

Target 10 to 15 minutes (the assessor stops at 18). Screen recording with your face visible, 720p or better, big terminal font, narrate live, no script, no splicing of separate recordings.
Title: `[Your Name] - Amani Market Systems - Summative Demo`. Upload as **unlisted** on YouTube at least 24 hours before the deadline, and test the link in an incognito window.

Say the prompt number out loud before each part. About 1 to 1.5 minutes each.

| # | Prompt | What to show |
|---|---|---|
| 1 | Project foundation (F1) | GitHub project board; branch protection rules (Settings, Branches) |
| 2 | Application baseline (F1) | Run the app locally; open the README setup instructions |
| 3 | Containerization (F2) | The Dockerfile; `docker compose up --build`; app on localhost:8080 |
| 4 | CI pipeline (F2) | A passing run AND a failing run that caught a real problem (Actions tab) |
| 5 | Infrastructure as Code | `terraform/` file structure; `terraform plan` or a recent apply; point out network, bastion, private VM, load balancer, registry, database |
| 6 | Configuration management | `ansible/` playbook and inventory; run it (or recent output); show the task that gets the app ready to serve traffic |
| 7 | Security scanning | A scan run in Actions; open one real finding; say what you did (fixed, suppressed with a reason, or accepted risk) |
| 8 | Full pipeline and deployment | Merge an approved PR into main; show `cd.yml` running stage by stage; open the live URL and use the app |
| 9 | Observability | `curl <live-url>/api/health`; `docker compose ps` / logs on the VM; say what the signal tells an operator |
| 10 | Reflection | `git log` from F1 through F2 to the Summative; answer: most important design decision, weakest part of the pipeline today, what you would fix first if going live tomorrow |

## Before you record
- [ ] App is deployed and the live URL works (terraform apply done, pipeline green)
- [ ] You have a green run and a red run to show for Prompt 4
- [ ] Terminal font is large; no passwords, keys or subscription IDs visible on screen
- [ ] Webcam on; microphone tested

## After you record
- [ ] Uploaded to YouTube as unlisted, title as above
- [ ] Link works in an incognito window
- [ ] Canvas: repo URL in the URL field; text box has Live Application URL, YouTube link and PR URL
- [ ] `terraform destroy` once everyone has recorded, to stop the costs
