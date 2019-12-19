EXTERNAL_SHA=$1
FAIL_MESSAGE=$2

trap 'curl
  --request POST
  --url https://api.github.com/repos/mattermost/mattermost-server/statuses/$EXTERNAL_SHA
  --user ${GITHUB_USER}:${GITHUB_USER_TOKEN}
  --header "Content-Type: application/json"
  --data "{\"state\": \"failure\", \"description\": \"$FAIL_MESSAGE\", \"context\": \"circleci/enterprise-integration"}"
' ERR