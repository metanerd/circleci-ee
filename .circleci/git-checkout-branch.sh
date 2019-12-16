EXTERNAL_BRANCH="$1"

if [[ "${EXTERNAL_BRANCH}" == "" ]]
then
  echo "Triggered internally by enterprise master and branch. "
  git checkout "$CIRCLE_BRANCH" || git checkout master
elif [[ -n "$EXTERNAL_BRANCH" && $(echo "$EXTERNAL_BRANCH" | grep -c "^pull\/[0-9]*$") == 1 ]]
then
  echo "Triggered externally by a forked server PR. "
  PR_NUMBER=${EXTERNAL_BRANCH#pull/}
  git fetch origin pull/"$PR_NUMBER"/head:PR-"$PR_NUMBER"
  git checkout PR-"$PR_NUMBER"
elif [[ -n "$EXTERNAL_BRANCH" && $(echo "$EXTERNAL_BRANCH" | grep -c "^pull\/[0-9]*$") == 0 ]]
then
  echo "Triggered externally by an upstream server PR. "
  git checkout "$EXTERNAL_BRANCH"
else
  echo "Unknown edge case for checking out a git branch detected. "
fi
