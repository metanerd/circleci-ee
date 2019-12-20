EXTERNAL_BRANCH="$1"

SERVER_REPO="mattermost-server"
UPSTREAM_USER="mattermost"

git clone git@github.com:$UPSTREAM_USER/$SERVER_REPO.git
cd $SERVER_REPO || exit

if [[ "${EXTERNAL_BRANCH}" == "" ]]
then
  echo "Triggered internally by enterprise master and branch. "
  git checkout "$CIRCLE_BRANCH" || git checkout master
elif [[ -n "$EXTERNAL_BRANCH" && $(echo "$EXTERNAL_BRANCH" | grep -c "^pull\/[0-9]*$") == 1 ]]
then
  echo "Triggered externally by a forked $SERVER_REPO PR. "
  PR_NUMBER=${EXTERNAL_BRANCH#pull/}
  git fetch origin pull/"$PR_NUMBER"/head:PR-"$PR_NUMBER"
  git checkout PR-"$PR_NUMBER"
elif [[ -n "$EXTERNAL_BRANCH" && $(echo "$EXTERNAL_BRANCH" | grep -c "^pull\/[0-9]*$") == 0 ]]
then
  echo "Triggered externally by an upstream $SERVER_REPO PR. "
  git checkout "$EXTERNAL_BRANCH"
else
  echo "Unknown edge case for checking out a git branch detected. "
fi
