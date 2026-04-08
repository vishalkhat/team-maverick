# hack-apr-26-template-repo

Template for **Hack Apr 26** service repos. Full participant steps live in **[GITHUB.md](./GITHUB.md)**; AWS account and App Config details are in **[AWS.md](./AWS.md)**.

## In a nutshell

1. **Register your repo** on the organizer sheet (see GITHUB.md) so org policies and Actions work.
2. **Align names:** set **`CI_SERVICE_NAME`** in `.github/workflows/build.yml` to your canonical service name (same as ECR / Kubernetes / AppConfig application name). Set **`CI_BUILD_STACK`** to **`python`**, **`nextjs`**, **`java-mvn`**, or **`java-gradle`**.
3. **Helm:** edit **`helm/values.yaml`** (replace **`<service-name>`** / **`<CHANGE_ME>`**) and **`helm/config.yml`** as needed.
4. **AppConfig (after AWS SSO login):** run `./scripts/bootstrap-appconfig-for-helm.sh "$CI_SERVICE_NAME"`. It creates the **hack** environment, hosted profiles **`in-hack-helm-configs`** and **`in-hack-app-config`**, ensures a custom **`AllAtOnce`** deployment strategy (0m bake), and **uploads `helm/config.yml`** as a new version on **`in-hack-app-config`**. It does **not** start deployments.
5. **Push configs in the console:** In **Systems Manager → AppConfig** (region from AWS.md, usually `ap-south-1`), open your application → **deploy** the new **`in-hack-app-config`** version to **`hack`**, then create and **deploy** a hosted version from **`helm/values.yaml`** on **`in-hack-helm-configs`**. Use the custom **`AllAtOnce`** strategy, not the AWS preset **`AppConfig.AllAtOnce`** (10m bake).
6. **CI/CD:** pushes to **`dev`** / **`stage`** run build and deploy per the workflows; use **`deploy-helm.yml`** for manual Helm deploys when you need a chosen image tag.

For access, resource names, and troubleshooting, use **AWS.md** and **GITHUB.md**.