#!/bin/bash

set -u

access_token=$GITHUB_ACCESS_TOKEN

echo ">> Getting the subject ID from GitHub (access_token=$access_token)"
search_query='{
    search(first: 1, type: ISSUE, query: "type:pr repo:xlayers/xlayers $COMMIT_SHA") {
        nodes {
        ... on PullRequest {
            id
            }
        }
    }
}'
subject_id=`curl \
    --url "https://api.github.com/graphql?access_token=$access_token" \
    --header 'content-type: application/json' \
    --data '{ "query": "$search_query" }' | \
    python -c 'import sys, json; print json.load(sys.stdin)["data"]["search"]["nodes"][0]["id"]'`

echo ">> Sending the Preview Link on issue $subject_id (access_token=$access_token)"
body='Preview: $PREVIEW_BUILD_URL'
mutation_query="{
    mutation AddCommentToIssue {
        addComment(input: {subjectId: \"$subject_id\", body: \"$body\"}) {
            clientMutationId
        }
    }
}"
curl \
    --url "https://api.github.com/graphql?access_token=$access_token" \
    --header 'content-type: application/json' \
    --data '{ "query": "$mutation_query" }'
