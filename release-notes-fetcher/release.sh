#!/bin/bash
set -x -e
set +o pipefail

export GITHUB_REF_NAME=8.2.3
export REPO_TO_PUBLISH_TO=camunda/camunda-platform

go build

./release-notes-fetcher | tee release_notes.txt
gh release edit --notes-file release_notes.txt -R $REPO_TO_PUBLISH_TO $GITHUB_REF_NAME

mkdir -p tmp

cd tmp

gh release \
  download "$GITHUB_REF_NAME" \
  -R camunda/zeebe \
  -p "zbctl" \
  -p "zbctl.sha1sum" \
  -p "zbctl.exe" \
  -p "zbctl.exe.sha1sum" \
  -p "zbctl.darwin" \
  -p "zbctl.darwin.sha1sum" \
  -p "camunda-zeebe-$GITHUB_REF_NAME.tar.gz" \
  -p "camunda-zeebe-$GITHUB_REF_NAME.tar.gz.sha1sum" \
  -p "camunda-zeebe-$GITHUB_REF_NAME.zip" \
  -p "camunda-zeebe-$GITHUB_REF_NAME.zip.sha1sum" \
  -p "camunda-operate-$GITHUB_REF_NAME.zip" \
  -p "camunda-operate-$GITHUB_REF_NAME.zip.sha1sum" \
  -p "camunda-operate-$GITHUB_REF_NAME.tar.gz" \
  -p "camunda-operate-$GITHUB_REF_NAME.tar.gz.sha1sum" \
  -p "camunda-tasklist-$GITHUB_REF_NAME.zip" \
  -p "camunda-tasklist-$GITHUB_REF_NAME.zip.sha1sum" \
  -p "camunda-tasklist-$GITHUB_REF_NAME.tar.gz" \
  -p "camunda-tasklist-$GITHUB_REF_NAME.tar.gz.sha1sum"

gh release \
  download "$GITHUB_REF_NAME" \
  -R camunda-cloud/identity \
  -p "camunda-identity-$GITHUB_REF_NAME.tar.gz" \
  -p "camunda-identity-$GITHUB_REF_NAME.tar.gz.sha1sum" \
  -p "camunda-identity-$GITHUB_REF_NAME.zip" \
  -p "camunda-identity-$GITHUB_REF_NAME.zip.sha1sum"

gh release -R $REPO_TO_PUBLISH_TO upload "$GITHUB_REF_NAME" *

