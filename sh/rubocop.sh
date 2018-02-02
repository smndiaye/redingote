#!/usr/bin/env bash

# Skip conditions
if [ "${CIRCLE_BRANCH}" == 'master' ]; then
  exit 0
fi

# Install gems
gem i --quiet --no-document \
  checkstyle_filter-git \
  saddler \
  saddler-reporter-github \
  rubocop \
  rubocop-select \
  rubocop-checkstyle_formatter \
  rails_best_practices \
  reek

# Set reporter
if [ -z "${CI_PULL_REQUEST}" ]; then
  REPORTER=Saddler::Reporter::Github::CommitReviewComment
else
  REPORTER=Saddler::Reporter::Github::PullRequestReviewComment
fi

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | checkstyle_filter-git diff origin/master \
   | saddler report \
      --require saddler/reporter/github \
      --reporter $REPORTER