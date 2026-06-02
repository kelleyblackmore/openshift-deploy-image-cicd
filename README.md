# Container Template

A repository template for building and pushing container images to GitHub Container Registry (ghcr.io).

## Features

- GitHub Actions workflow for automated container builds
- Multi-architecture support via Docker Buildx
- Automatic tagging based on git refs (branches, tags, PRs)
- GitHub Container Registry (ghcr.io) integration
- Build caching for faster builds

## Quick Start

1. **Use this template**: Click "Use this template" to create a new repository based on this template.

2. **Customize the Dockerfile**: Modify the `Dockerfile` to build your application.

3. **Push to build**: Push to the `main` branch or create a tag to trigger a build and push to ghcr.io.

## Workflow Triggers

The workflow runs on:
- Push to `main` branch
- Tags matching `v*` pattern (e.g., `v1.0.0`)
- Pull requests to `main` branch (builds but does not push)
- Manual dispatch via GitHub Actions UI

## Image Tags

The workflow automatically generates the following tags:
- Branch name (e.g., `main`)
- Pull request number (e.g., `pr-123`)
- Semantic version from git tag (e.g., `1.0.0`, `1.0`)
- Git SHA (e.g., `sha-a1b2c3d`)

## Pulling Your Image

Once built, you can pull your image using:

```bash
docker pull ghcr.io/OWNER/REPO:TAG
```

Replace `OWNER` with your GitHub username or organization, `REPO` with your repository name, and `TAG` with the desired tag.

## Configuration

### Required Permissions

The workflow requires the following permissions (already configured):
- `contents: read` - To checkout the repository
- `packages: write` - To push to GitHub Container Registry

### Making Your Package Public

By default, container images are private. To make them public:
1. Go to your repository's "Packages" section
2. Select your container image
3. Go to "Package settings"
4. Change visibility to "Public"

## License

MIT