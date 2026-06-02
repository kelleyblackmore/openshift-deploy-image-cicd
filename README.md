# ubi9-openshift-cicd

A RHEL 9 UBI CI/CD container image for deploying to OpenShift projects with `oc`, `kubectl`, and `helm`.

## Features

- Based on `registry.access.redhat.com/ubi9/ubi-minimal:9.5`
- Includes `oc` (OpenShift CLI), `kubectl`, `helm`, `git`, `jq`, and `yq`
- Runs as non-root user (UID 1001) for OpenShift compatibility
- Multi-architecture support: `amd64` and `arm64`
- GitHub Actions workflow for automated builds and push to ghcr.io
- `Makefile` for local builds using `podman`

## Repository Layout

```text
.
├── Containerfile
├── Makefile
├── scripts/
│   └── deploy-helm.sh
└── README.md
```

## Local Build

Build the image locally using `podman`:

```bash
make build
```

Run a shell in the image:

```bash
make run
```

Verify the installed tools:

```bash
make test
```

Push to a registry:

```bash
make push REGISTRY=registry.example.com/devsecops IMAGE_TAG=latest
```

## Deploy Script

The `scripts/deploy-helm.sh` script logs in to OpenShift and deploys a Helm chart. Set the
following environment variables before running it:

| Variable | Required | Description |
|---|---|---|
| `OPENSHIFT_SERVER` | Yes | OpenShift API server URL |
| `OPENSHIFT_TOKEN` | Yes | Service account token |
| `OPENSHIFT_PROJECT` | Yes | Target OpenShift project/namespace |
| `HELM_RELEASE` | Yes | Helm release name |
| `HELM_CHART` | Yes | Path or chart reference |
| `HELM_NAMESPACE` | No | Override namespace (defaults to `OPENSHIFT_PROJECT`) |
| `HELM_VALUES_FILE` | No | Values file path (defaults to `values.yaml`) |
| `HELM_TIMEOUT` | No | Helm operation timeout (defaults to `10m`) |
| `OPENSHIFT_INSECURE_SKIP_TLS_VERIFY` | No | Skip TLS verification (defaults to `false`) |

## GitHub Actions Workflow

The workflow builds and pushes the image to GitHub Container Registry (`ghcr.io`) on:
- Push to `main` branch
- Tags matching `v*` (e.g., `v1.0.0`)
- Pull requests to `main` (builds only, no push)
- Manual dispatch via GitHub Actions UI

## GitLab CI Usage

```yaml
stages:
  - validate
  - deploy

variables:
  HELM_RELEASE: my-app
  HELM_CHART: ./charts/my-app
  HELM_VALUES_FILE: ./charts/my-app/values-dev.yaml
  OPENSHIFT_PROJECT: my-dev-project
  OPENSHIFT_INSECURE_SKIP_TLS_VERIFY: "false"

validate:
  stage: validate
  image: ghcr.io/OWNER/REPO:main
  script:
    - helm lint "$HELM_CHART"
    - helm template "$HELM_RELEASE" "$HELM_CHART" -f "$HELM_VALUES_FILE" > rendered.yaml
    - oc version --client
    - kubectl version --client=true

deploy:
  stage: deploy
  image: ghcr.io/OWNER/REPO:main
  script:
    - ./scripts/deploy-helm.sh
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

Set these as masked/protected GitLab CI/CD variables:

```text
OPENSHIFT_SERVER=https://api.cluster.example.com:6443
OPENSHIFT_TOKEN=<service-account-token>
OPENSHIFT_PROJECT=my-dev-project
```

## OpenShift Service Account Setup

Run this once from an admin workstation:

```bash
oc project my-dev-project

oc create serviceaccount gitlab-deployer

oc adm policy add-role-to-user edit \
  system:serviceaccount:my-dev-project:gitlab-deployer \
  -n my-dev-project
```

Get the token:

```bash
oc create token gitlab-deployer -n my-dev-project
```

Use that token as `OPENSHIFT_TOKEN` in your CI/CD variables.

## Pinning Versions

For reproducible builds in air-gapped or controlled environments, pin exact versions:

```dockerfile
ARG HELM_VERSION="3.20.2"
ARG OC_VERSION="4.17.0"
```

Mirror tarballs into Artifactory/Nexus and update the download URLs accordingly.

## License

MIT