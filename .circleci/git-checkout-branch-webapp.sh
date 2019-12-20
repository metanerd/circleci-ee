EXTERNAL_BRANCH="$1"

REPO_TRIGGER="mattermost-server"
REPO_COMPANION="mattermost-webapp"
USER_UPSTREAM="mattermost"

# test overwrites:
REPO_TRIGGER="circleci-test"
REPO_COMPANION="circleci-test"
USER_UPSTREAM="metanerd"
mkdir test && cd test || exit

if [[ "${EXTERNAL_BRANCH}" == "" ]]
then
  echo "Triggered internally by enterprise master and branch. "

  git clone git@github.com:$USER_UPSTREAM/$REPO_COMPANION.git
  cd $REPO_COMPANION || exit
  git checkout "$CIRCLE_BRANCH" || git checkout master
elif [[ -n "$EXTERNAL_BRANCH" && $(echo "$EXTERNAL_BRANCH" | grep -c "^pull\/[0-9]*$") == 1 ]]
then
  echo "EXTERNAL_BRANCH is actually a forked pull request in $REPO_TRIGGER. " \
    "Trying to find the appropriate companion branch for $REPO_COMPANION. "

  echo "Get PR author and branch name of $REPO_TRIGGER fork. "
  PR_NUMBER=${EXTERNAL_BRANCH#pull/}
  PR_AUTHOR_COLON_FORK_BRANCH=$(curl --request GET   --url https://api.github.com/repos/"$USER_UPSTREAM"/"$REPO_TRIGGER"/pulls/"$PR_NUMBER" | jq --raw-output '. | .head.label')
  echo "$PR_AUTHOR_COLON_FORK_BRANCH"

  FORK_BRANCH=${PR_AUTHOR_COLON_FORK_BRANCH##*:}
  PR_AUTHOR=${PR_AUTHOR_COLON_FORK_BRANCH%:$FORK_BRANCH}
  echo "$PR_AUTHOR_COLON_FORK_BRANCH is equal to $PR_AUTHOR:$FORK_BRANCH"

  echo "Check if branch exists in $PR_AUTHOR:$FORK_BRANCH. "
  HTTP_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://api.github.com/repos/"$PR_AUTHOR"/"$REPO_COMPANION"/git/refs/heads/"$FORK_BRANCH")
  if [[ $HTTP_STATUS_CODE == 200 ]]
  then
    echo "Found branch in fork $PR_AUTHOR/$REPO_COMPANION/git/refs/heads/$FORK_BRANCH. "

    git clone git@github.com:"$PR_AUTHOR"/"$REPO_COMPANION".git
    cd "$REPO_COMPANION" || exit
    git checkout "$FORK_BRANCH"
  elif [[ $HTTP_STATUS_CODE == 404 ]]
  then
    echo "Check if branch exists in upstream repo $REPO_COMPANION. "

    HTTP_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://api.github.com/repos/"$USER_UPSTREAM"/"$REPO_COMPANION"/git/refs/heads/"$FORK_BRANCH")
    if [[ $HTTP_STATUS_CODE == 200 ]]
    then
      echo "Found branch in upstream $USER_UPSTREAM/$REPO_COMPANION/git/refs/heads/$FORK_BRANCH. "

      git clone git@github.com:$USER_UPSTREAM/$REPO_COMPANION.git
      cd $REPO_COMPANION || exit
      git checkout "$FORK_BRANCH"
    else
      echo "No companion branch found in fork. Proceeding with upstream master. "

      git clone git@github.com:$USER_UPSTREAM/$REPO_COMPANION.git
      cd $REPO_COMPANION || exit
      git checkout master
    fi
  else
    echo "No companion branch found in fork. Proceeding with upstream master. "

    git clone git@github.com:$USER_UPSTREAM/$REPO_COMPANION.git
    cd $REPO_COMPANION || exit
    git checkout master
  fi
elif [[ -n "$EXTERNAL_BRANCH" && $(echo "$EXTERNAL_BRANCH" | grep -c "^pull\/[0-9]*$") == 0 ]]
then
  echo "Triggered externally by an upstream $REPO_TRIGGER PR. "

  git clone git@github.com:$USER_UPSTREAM/$REPO_COMPANION.git
  cd $REPO_COMPANION || exit
  git checkout "$EXTERNAL_BRANCH"
else
  echo "Unknown edge case for checking out a git branch detected. "
fi
