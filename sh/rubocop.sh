#!/usr/bin/env bash

set -eu

echo 'check pull request'

if [ "$CI_PULL_REQUEST" == false ] || [ -z "$CI_PULL_REQUEST" ]; then
  echo 'not pull request.'
  exit 0
fi

echo 'get pull request number'

if [[ $CI_PULL_REQUEST =~ ([0-9]*)$ ]]; then
  PR_NUMBER=${BASH_REMATCH[1]}
else
  echo 'cannot get pull request number. maybe bug.'
  exit 1
fi

echo "pull request number is $PR_NUMBER"

echo 'add comment'

COV_URL="https://circle-artifacts.com/gh/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/$CIRCLE_BUILD_NUM/artifacts/0$CIRCLE_ARTIFACTS/coverage/index.html"
PERCENTAGE=`cat $CIRCLE_ARTIFACTS/coverage/.last_run.json | jq '.result.covered_percent'`
COMMENT_BODY="Coverage report\\n$COV_URL\\n$PERCENTAGE%"
POST_BODY="{\"body\": \"$COMMENT_BODY\"}"
curl -XPOST \
  -H "Authorization: token $GITHUB_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$POST_BODY" \
  https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/issues/$PR_NUMBER/comments