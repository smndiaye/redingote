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

# Get diffed files
RUBY_DIFFS=$(git diff -z --name-only origin/master | xargs -0 rubocop-select)

echo "******************************"
echo "*          RuboCop           *"
echo "******************************"

echo "$RUBY_DIFFS" | xargs rubocop --require "$(gem which rubocop/formatter/checkstyle_formatter)" \
                                   --format RuboCop::Formatter::CheckstyleFormatter \
                                   --out rubocop.xml

cat rubocop.xml | \
    checkstyle_filter-git diff origin/master | \
    saddler report --require saddler/reporter/github --reporter $REPORTER

cp -v 'rubocop.xml' "$CIRCLE_ARTIFACTS/"

echo "******************************"
echo "*     Rails Best Pratices    *"
echo "******************************"

echo "$RUBY_DIFFS" | xargs rails_best_practices --format xml

cat rails_best_practices_output.xml | \
    checkstyle_filter-git diff origin/master | \
    saddler report --require saddler/reporter/github --reporter $REPORTER

cp -v 'rails_best_practices_output.xml' "$CIRCLE_ARTIFACTS/"

echo "******************************"
echo "*            Reek            *"
echo "******************************"

echo "$RUBY_DIFFS" | xargs reek app --format xml > reek.xml

cat reek.xml | \
    checkstyle_filter-git diff origin/master | \
    saddler report --require saddler/reporter/github --reporter $REPORTER

cp -v 'reek.xml' "$CIRCLE_ARTIFACTS/"
