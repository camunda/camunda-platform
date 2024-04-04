# Release process

There are 2 components to keep in mind when releasing a version in this repository:

1. The .env and docker-compose.yaml's in the root of this directory
2. The release notes published in the GitHub Releases page.

## How to handle an alpha release

1. If it's the first alpha release in the minor release cycle, create a `stable/8.x` branch
2. Update .env (make sure that the versions of each component are updated with the latest version or alpha, and that if the component is a third-party dependency, that it abides by [Supported Environments](https://docs.camunda.io/docs/reference/supported-environments/)
3. Create a release, and check on the github actions to ensure the release notes gets properly generated.


## How to handle a minor release

1. Update .env (make sure that the versions of each component are updated with the latest version or alpha, and that if the component is a third-party dependency, that it abides by [Supported Environments](https://docs.camunda.io/docs/reference/supported-environments/)
2. generate release notes like normal. If a `stable/8.x` branch for the minor release does not already exist, create it.
3. add entries into `.github/renovate.json5` to ensure that patch release gets upgraded.

## How to do patch release

1. Update .env (make sure that the versions of each component are updated, and that if the component is a third-party dependency, that it abides by [Supported Environments](https://docs.camunda.io/docs/reference/supported-environments/)
2. Merge renovate PRs if any are open (wait for CI to pass)
3. generate release notes like normal


## How to generate release notes

1. Navigate to the [Releases page](https://github.com/camunda/camunda-platform/releases)
2. Click "Draft a new release"
3. Create a tag named the version number
4. Target the branch of the stable/x.x version you're releasing (or main)
5. Add a release title
6. Publish Release
7. Ensure the CI workflow completes successfully: [Release workflow](https://github.com/camunda/camunda-platform/actions/workflows/release.yaml)
8. Make sure the release notes show up here with the necessary artifacts: [Releases](https://github.com/camunda/camunda-platform/releases)
