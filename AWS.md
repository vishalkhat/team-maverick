# AWS (hack-apr-26)

This page covers access to the **hack-apr-26** AWS account and how it fits with your team repo.

## Access

If you have **registered for the hackathon**, you should receive **PowerUserAccess** in the **hack-apr-26** AWS account (subject to organizer provisioning).

### Sign in (browser)

1. Open the **Nurix AWS access portal**: [AWS access portal — Accounts](https://nurixlabs.awsapps.com/start/#/?tab=accounts)
2. Sign in with **Google** when prompted.
3. Choose the **hack-apr-26** account and the role you were granted (e.g. PowerUser).

### CLI and SSO

To use the AWS CLI with SSO (profiles, `aws sso login`, etc.), follow:

- [Developer guide: Using AWS SSO login](https://nurix.atlassian.net/wiki/spaces/DevOps/pages/153747745/Developer+Guide+Using+AWS+SSO+Login)

### SSM (EC2, databases, bastion-style access)

For connecting to resources over **Systems Manager Session Manager** (for example EC2-backed databases):

- [Developer guide: Connect to EC2 DB via SSM](https://nurix.atlassian.net/wiki/spaces/DevOps/pages/287440910/Developer+Guide+Connect+to+EC2+DB+via+SSM)

## Environment at a glance

| Item | Value |
|------|--------|
| **AWS account** | **hack-apr-26** (`632421564644`) |
| **Primary region** | **ap-south-1** (Asia Pacific — Mumbai) |

Use these when picking the account in the [AWS access portal](https://nurixlabs.awsapps.com/start/#/?tab=accounts) or configuring CLI profiles.

---

## Provisioned resources (platform)

The following exists in **hack-apr-26** for the hack environment. It is managed by **platform IaC** (Terragrunt in `core-infra`); treat it as shared infrastructure unless organizers say otherwise.

### Network

- **VPC** for the hack footprint (**`172.19.0.0/16`**) with **public**, **internal**, and **private** subnets across **ap-south-1** AZs. Workloads such as EKS nodes and managed data stores use **private** subnets.

### Amazon EKS (Kubernetes)

- **Cluster name:** **`in-hack-eks-01`**
- **Purpose:** Run services you deploy from your **team repo** (typically **Helm** via **GitHub Actions**).
- **Cluster platform add-ons** (shared — do not tear down without DevOps): **Prometheus Operator** (monitoring stack), **Promtail** (log shipping), **Linkerd** (service mesh).

Configure `kubectl` after SSO login, for example:

```bash
aws eks update-kubeconfig --region ap-south-1 --name in-hack-eks-01 --profile <your-sso-profile>
```

### Data stores

| Service | Identifier / name | Notes |
|--------|-------------------|--------|
| **Amazon RDS** (MySQL **8.0**) | **`in-hack-mysql`** | Single-AZ dev-style instance in **private** subnets (`db.t4g.medium` class in IaC). **Credentials and endpoints** are not published here — use Secrets Manager / SSM / organizer instructions. |
| **Amazon ElastiCache** (Valkey) | **`in-hack-cache-01`** | Valkey **8.1**, multi-AZ–capable cache in **private** subnets (platform-managed). |

### CI/CD (GitHub → AWS)

- **OIDC provider** for **GitHub Actions** and IAM role **`github-actions-role`** — allows eligible **`nurixlabs/*`** repositories to assume a role for **ECR**, **EKS** deploy, **AppConfig**, **Secrets Manager** read, etc., per attached policies.
- Your repo must be **registered** and **allowed by org policy** so pipelines are not blocked — see [GITHUB.md](./GITHUB.md).

### Remote state (for awareness)

Platform Terraform state for this account uses a dedicated **S3** bucket and **DynamoDB** table for locks in **ap-south-1** (operators only; you do not need this for normal app development).

---

## Deploying your service (developer checklist)

Do these in order so **CI can build and Helm can apply** the right image and configuration.

1. **Write your application code** under `src/` (and any supporting files your stack needs).

2. **Commit and push to `stage`**  
   Hackathon submissions and the default pipelines expect work on **`stage`** — see [GITHUB.md](./GITHUB.md).

3. **Configure CI in `.github/workflows/build.yml`**  
   In the workflow **`env`** block, set:
   - **`CI_SERVICE_NAME`** — must match your **ECR repository name** and the **Kubernetes / Helm service name** you deploy (same string the platform expects).
   - **`CI_BUILD_STACK`** — which stack runs: **`python`**, **`nextjs`**, **`java-mvn`**, or **`java-gradle`**.  
   Adjust Dockerfile paths, Java/Node/Python versions, and secrets (`GIT_TOKEN`, `ORG_YARNRC`, `PACKAGES_READ_TOKEN`, etc.) per your project.

4. **Publish `helm/values.yaml` to AWS App Config before (or when) you rely on deploy**  
   The shared **Helm deploy** path expects **hosted configuration** for your service (profile **`in-hack-helm-configs`**, environment **`hack`**, application name = your **`CI_SERVICE_NAME`**). If App Config does not yet contain your values, deploys can fail or apply wrong defaults.

   **Bootstrap (fast, no upload):** after SSO login, create the app, environment, hosted profile, and a custom **`AllAtOnce`** deployment strategy (if missing) — seconds only:

   ```bash
   export AWS_PROFILE=<your-hack-apr-26-profile>
   export AWS_REGION=ap-south-1
   ./scripts/bootstrap-appconfig-for-helm.sh "$CI_SERVICE_NAME"
   ```

   **Upload and deploy in the console:** open **Systems Manager → AppConfig** (same region), select your application → configuration **`in-hack-helm-configs`** → create a **hosted configuration version** and paste the contents of **`helm/values.yaml`** (replace **`<service-name>`** / **`<CHANGE_ME>`** with **`CI_SERVICE_NAME`** — see the top of **`helm/values.yaml`**). Then **start a deployment** to environment **`hack`**.

   **Deployment strategy:** choose the custom strategy named **`AllAtOnce`** (created by the bootstrap script if it did not exist). Do **not** use the read-only preset **`AppConfig.AllAtOnce`** — it always includes a **10** minute bake. The custom strategy uses **0** minutes **deployment duration** and **0** minutes **final bake** so rollout finishes as soon as AppConfig applies the version.

5. **Let Actions run**  
   Pushes to **`dev`** or **`stage`** trigger **build** and, on success, **auto-deploy** via `.github/workflows/build.yml`. For a **manual** deploy with a chosen image tag, use `.github/workflows/deploy-helm.yml` if your repo includes it.

Also keep **`devops.yml`** aligned with your Helm/runtime expectations where your team uses it for documentation or automation. Repo registration and org policy still apply — [GITHUB.md](./GITHUB.md).

---

_Questions about account access or permissions: ask hackathon organizers / DevOps._
