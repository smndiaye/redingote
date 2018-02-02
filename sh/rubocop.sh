set -eu
echo 'check if pull request'

PERCENTAGE=`cat coverage/.last_run.json | jq '.result.covered_percent'`
SIMPLE_COV_URL="https://$CIRCLE_BUILD_NUM-91943388-gh.circle-artifacts.com/0/coverage/index.html"
COMMENT_BODY="[Code coverage is now at $PERCENTAGE%]($SIMPLE_COV_URL)"


if [ -z ${CI_PULL_REQUEST+x} ] || [ "$CI_PULL_REQUEST" == false ] ; then
  if [[ $CI_PULL_REQUEST =~ ([0-9]*)$ ]]; then
      echo 'get pull request number'
      PR_NUMBER=${BASH_REMATCH[1]}
      curl -XPOST -H "Authorization: token $GITHUB_ACCESS_TOKEN" -H "Content-Type: application/json" \
      -d "{\"body\": \"$COMMENT_BODY\"}" \
      https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/issues/$PR_NUMBER/comments
  fi
else
  echo 'get commit sha';
  curl -XPOST -H "Authorization: token $GITHUB_ACCESS_TOKEN" -H "Content-Type: application/json" \
  -d "{\"body\": \"$COMMENT_BODY\"}" \
  https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/commits/$CIRCLE_SHA1/comments
fi
