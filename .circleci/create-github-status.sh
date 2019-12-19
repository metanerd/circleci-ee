EXTERNAL_SHA=$1
GITHUB_STATUS=$2
GITHUB_DESCRIPTION=$3
GITHUB_CONTEXT=$4
curl \
  --request POST \
  --url https://api.github.com/repos/metanerd/circleci-test/statuses/"$EXTERNAL_SHA" \
  --user "$GITHUB_USER":"$GITHUB_USER_TOKEN" \
  --header 'content-type: application/json' \
  --data "{\"state\": \"$GITHUB_STATUS\", \"description\": \"$GITHUB_DESCRIPTION\", \"context\": \"$GITHUB_CONTEXT\"}"
