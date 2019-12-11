BRANCH_EXTERNAL="$1"

if [[ "${BRANCH_EXTERNAL}" == "" ]]
then
  echo "Triggered internally by enterprise master and branch. "
  git checkout "$CIRCLE_BRANCH" || git checkout master
elif [[ -n "$BRANCH_EXTERNAL" && $(echo "$BRANCH_EXTERNAL" | grep -c "^pull\/[0-9]*$") == 1 ]]
then
  echo "Triggered externally by a forked server PR. "
  PR_NUMBER=${BRANCH_EXTERNAL#pull/}
  git fetch origin pull/"$PR_NUMBER"/head:PR-"$PR_NUMBER"
  git checkout PR-"$PR_NUMBER"
elif [[ -n "$BRANCH_EXTERNAL" && $(echo "$BRANCH_EXTERNAL" | grep -c "^pull\/[0-9]*$") == 0 ]]
then
  echo "Triggered externally by an upstream server PR. "
  git checkout "$BRANCH_EXTERNAL"
else
  echo "Unknown edge case for checking out a git branch detected. "
fi
