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

## Deploy Pipelines

Your repo comes with a default deploy pipeline. You are free to modify it to suit
your stack. Do not delete it entirely — the deadline enforcement runs separately
and cannot be removed.

---

## Rules

- All work must be on the **stage** branch — do not use other long-lived branches for submissions
- Follow the structure and deadlines above unless an organizer announces an exception