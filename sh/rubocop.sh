#!/usr/bin/env bash

set -eu

echo 'check if pull request'

if [ "$CI_PULL_REQUEST" == false ] || [ -z "$CI_PULL_REQUEST" ]; then
  echo 'not a pull request.'
  exit 0
fi

echo 'get pull request number'

if [[ $CI_PULL_REQUEST =~ ([0-9]*)$ ]]; then
  PR_NUMBER=${BASH_REMATCH[1]}
else
  echo 'could not get PR number'
  exit 1
fi

echo "pull request number is $PR_NUMBER"

echo 'add comment to github'

COV_URL="https://$CIRCLE_BUILD_NUM-105956307-gh.circle-artifacts.com/0/coverage/index.html"
PERCENTAGE=`cat coverage/.last_run.json | jq '.result.covered_percent'`
COMMENT_BODY="Code coverage is now at $PERCENTAGE%\\nCoverage URL\\n$COV_URL"
POST_BODY="{\"body\": \"$COMMENT_BODY\"}"
curl -XPOST \
  -H "Authorization: token $GITHUB_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$POST_BODY" \
  https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/issues/$PR_NUMBER/comments