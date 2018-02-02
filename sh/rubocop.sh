#!/usr/bin/env bash

set -v

# Skip if master branch
echo "* check if master branch *"
if [ "${CIRCLE_BRANCH}" == "master" ]; then
  exit 0;
fi

# Install gems
echo "* install gems *"
gem install --no-document checkstyle_filter-git saddler saddler-reporter-github

# Set reporter
echo "* set reporter *"
if [ -z "${CI_PULL_REQUEST}" ]; then
REPORTER=Saddler::Reporter::Github::CommitReviewComment
else
REPORTER=Saddler::Reporter::Github::PullRequestReviewComment
fi

# Reports
echo "* reports *"
git diff --name-only origin/master \
| grep '\.js\?$\|\.jsx\?$' \
| xargs node_modules/eslint/bin/eslint.js -f checkstyle \
| checkstyle_filter-git diff origin/master \
| saddler report --require saddler/reporter/github --reporter $REPORTER
