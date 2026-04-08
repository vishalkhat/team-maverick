# Hackathon Participant Guide

## Getting Started

> **Register your repo name (required):** After you create your team repository, add your **exact repo name**  to the **Hack Apr 26 repo registration Google Sheet** at:
>
> [Update Repo Name Here](https://docs.google.com/spreadsheets/d/1iUSKACpAtg0Rp_u7uSilyek5q3WhlktxCI-RI6qaWcE/edit?gid=562580937#gid=562580937)
>
> Organizers use that list so **organization-level policies** apply to your repo. **If your repo is not on the sheet, you are likely to hit org-level restrictions** (for example blocked GitHub Actions, failed deploy workflows, or other enforcement).

### 1. Create your team repo

- Template reference: [nurixlabs/hack-apr-26-template-repo](https://github.com/nurixlabs/hack-apr-26-template-repo)
- Open **[Create repository from this template](https://github.com/new?owner=nurixlabs&template_name=hack-apr-26-template-repo&template_owner=nurixlabs)** (owner **nurixlabs** and template are pre-filled)
- Name your repo: `team-[your-team-name]`
- Set visibility: Internal
- Click **Create repository**
- Then complete **repo registration** in the Google Sheet (see the callout above)

The stage branch is already set as default. Do not change this.

### 2. Clone your repo
git clone https://github.com/nurixlabs/team-[your-team-name].git
cd team-[your-team-name]

You are already on stage. Start working directly.

---

## Repo Structure

Do not rename or move the docs/ or src/ folders.
You are free to organise everything inside src/ however you like.

```text
your-repo/
├── docs/
│   ├── PRD.md
│   └── LLD.md
├── src/
├── helm/
├── infra/
├── .github/
└── README.md
```

- **docs/** — PRD and LLD (required paths; do not rename the folder)
- **src/** — all application code
- **helm/**, **infra/**, **.github/** — supporting layout from the template (customize as needed)
- **README.md** — short project description for reviewers

---

## Deadlines

| Artifact | File | Deadline |
|---|---|---|
| PRD | docs/PRD.md | 9 Apr, 5:00 PM IST |
| LLD | docs/LLD.md | 10 Apr, 12:00 AM IST |
| Code | src/ | 11 Apr, 12:00 AM IST |

- Each artifact has its own deadline
- You can keep pushing freely — only the timestamp of the last commit per artifact matters
- Commits after the deadline are automatically flagged and will incur a penalty
- You will see a red ✗ on your commit if it was late — green ✓ means you are on time

---

## How to Submit

No separate submission step. Every push to stage is automatically recorded.

### PRD
git add docs/PRD.md
git commit -m "docs: add PRD"
git push origin stage

Due: 9 Apr, 5:00 PM IST

### LLD
git add docs/LLD.md
git commit -m "docs: add LLD"
git push origin stage

Due: 10 Apr, 12:00 AM IST

### Code
git add src/
git commit -m "feat: final submission"
git push origin stage

Due: 11 Apr, 12:00 AM IST

---

## Checking Your Submission Status

After every push to stage:
GitHub → Your Repo → Commits → click the ✓ or ✗ icon next to your commit

It will show:
- hackathon/deadline → success = on time ✓
- hackathon/deadline → failure = late ✗ (artifact name will be listed)

---

## CI/CD pipelines

Your repo ships with GitHub Actions workflows under `.github/workflows/`. You may
adapt Dockerfiles, tests, and inputs to your stack. **Do not remove the deadline
workflow** — submission timing is enforced there and is separate from build/deploy.

### Where configuration lives

| What | Where |
|------|--------|
| **Stack and service name** | `.github/workflows/build.yml` → `env.CI_BUILD_STACK` and `env.CI_SERVICE_NAME` |
| **Helm / runtime hints for deploy** | `devops.yml` (values merged at deploy time per platform conventions) |
| **Manual Helm deploy inputs** | `.github/workflows/deploy-helm.yml` |

Set `CI_BUILD_STACK` to one of: `python`, `nextjs`, `java-mvn`, `java-gradle`.
Only the job whose `if:` matches that value runs; the others are skipped.
`CI_SERVICE_NAME` should match the ECR repository name and the service identifier
used in deploy (template default: `hackathon-service`).

### Application Build (`build.yml`)

**Workflow name:** Application Build  
**File:** `.github/workflows/build.yml`  
**Reusable workflows:** [nurixlabs/github-shared-workflows](https://github.com/nurixlabs/github-shared-workflows) at ref **`@stable`**.

**Triggers**

| Event | Branches / notes |
|--------|------------------|
| `push` | `dev`, `stage`, `main` |
| `pull_request` | `dev`, `stage`, `main` (opened, synchronize, reopened) |
| `workflow_dispatch` | Any; optional input **ignore test failures** (continues even if tests fail) |

**Permissions:** `id-token: write` (AWS OIDC), `contents: read`.

**Jobs (one stack runs per repo configuration)**

| Stack (`CI_BUILD_STACK`) | Shared workflow | Highlights |
|---------------------------|-----------------|------------|
| `python` | `gsw-python-poetry-build.yml` | Python **3.11**, `Dockerfile`, `tests/`, Poetry; optional `poetry_groups_exclude`, coverage threshold **15%**; Helm chart **`python-service`**; region **ap-south-1**. |
| `nextjs` | `gsw-nextjs-yarn-build.yml` | Node **22**, `nextjs-service.Dockerfile`, Yarn scripts `tests` / `build`; Helm **`nextjs-service`**. |
| `java-mvn` | `gsw-java-maven-build.yml` | Java **17**, `Dockerfile`, Maven options `-T 4C -B --no-transfer-progress`; Helm **`java-service`**; coverage optional (`enable_coverage: false` in template). |
| `java-gradle` | `gsw-java-gradle-build.yml` | Java **17**, `Dockerfile`, Gradle **`--no-daemon --build-cache`**; Helm **`java-service`**. |

**Secrets (by stack — set in repo or org settings)**

- **Python / Java (Gradle):** `GIT_TOKEN` — private Git dependencies (e.g. GitHub Packages / private repos).
- **Next.js:** `ORG_YARNRC` and `GITHUB_TOKEN` (as wired in the template).
- **Java (Maven):** `secrets: inherit` — use org/repo secrets expected by the shared Maven workflow (see shared-workflows docs if you add private repositories).

Successful builds push an image to **ECR** (`aws_region: ap-south-1`); the exact tagging scheme is defined in the shared workflow outputs.

### Auto-deploy to India (`build.yml` → `auto-deploy-in`)

After a **push** to **`dev`** or **`stage`**, if the build job for your stack
**succeeded**, a follow-up job runs **`gsw-deploy-helm.yml@stable`** with:

- **environment:** `dev` when pushing to `dev`, `stage` when pushing to `stage`
- **region:** `in`
- **image_repo / service_name:** `CI_SERVICE_NAME`
- **image_tag:** from the build job output (varies slightly by stack; Next.js exposes branch-specific outputs for dev/stage in India)
- **helm_chart_name:** `python-service`, `nextjs-service`, or `java-service` according to `CI_BUILD_STACK`

Pushes to **`main`** and **pull requests** run build (and tests) but **do not**
trigger this auto-deploy job in the template.

### Manual Helm deploy (`deploy-helm.yml`)

**Workflow name:** Deploy with Helm  
**File:** `.github/workflows/deploy-helm.yml`  
**Trigger:** `workflow_dispatch` only.

You provide **`image_tag`** (for example a tag printed by a previous Application
Build run). The template pins:

- **environment:** `hack` (do not change unless organizers say otherwise)
- **region:** `in`
- **helm_chart_name:** `nurix-service` (template default; differs from auto-deploy chart names above)
- **service_name / image_repo / namespace:** `hackathon-service` — change these together if you rename the service

Adjust **`service_name`**, **`image_repo`**, and **`namespace`** in this workflow
if you change `CI_SERVICE_NAME` in `build.yml`, and keep them consistent.

### `devops.yml`

`devops.yml` holds **service_name** and **helm_values** (commands, resources,
health checks, etc.) used when values are merged for deployment. Keep
**service_name** aligned with `CI_SERVICE_NAME` / Helm service naming expectations.

---

## Rules

- All work must be on the **stage** branch — do not use other long-lived branches for submissions
- Follow the structure and deadlines above unless an organizer announces an exception
