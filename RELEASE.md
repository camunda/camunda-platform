# Release process

This repository is used for the release notes of Camunda <= 8.5, for Camunda >= 8.6 please check [camunda/camunda](https://github.com/camunda/camunda)

## How to generate release notes

1. Navigate to the [Releases page](https://github.com/camunda/camunda-platform/releases)
2. Click "Draft a new release"
3. Create a tag named the version number
4. Target the branch of the stable/x.x version you're releasing (or main)
5. Add a release title
6. Publish Release
7. Ensure the CI workflow completes successfully: [Release workflow](https://github.com/camunda/camunda-platform/actions/workflows/release.yaml)
8. Make sure the release notes show up here with the necessary artifacts: [Releases](https://github.com/camunda/camunda-platform/releases)
