#!/usr/bin/env bash
set -eu
echo 'check if pull request'

if [ "$CI_PULL_REQUEST" == false ] || [ -z "$CI_PULL_REQUEST" ]; then
  echo 'not pull request.'
  exit 0
fi

echo 'get pull request number'

if [[ $CI_PULL_REQUEST =~ ([0-9]*)$ ]]; then
  PR_NUMBER=${BASH_REMATCH[1]}
else
  echo 'could not get PR number';
  exit 1;
fi

echo 'post code coverage as github PR comment'

PERCENTAGE=`cat coverage/.last_run.json | jq '.result.covered_percent'`
SIMPLE_COV_URL="https://$CIRCLE_BUILD_NUM-105956307-gh.circle-artifacts.com/0/coverage/index.html"
COMMENT_BODY="[Code coverage is now at $PERCENTAGE%]($SIMPLE_COV_URL)"
curl -XPOST -H "Authorization: token $GITHUB_ACCESS_TOKEN" -H "Content-Type: application/json" \
  -d "{\"body\": \"$COMMENT_BODY\"}" \
  https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/issues/$PR_NUMBER/comments