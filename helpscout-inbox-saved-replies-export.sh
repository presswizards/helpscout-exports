#!/bin/bash

# Help Scout API credentials
APPLICATION_ID="your_application_id"
APPLICATION_SECRET="your_application_secret"

# API URLs
AUTH_URL="https://api.helpscout.net/v2/oauth2/token"
BASE_URL="https://api.helpscout.net/v2"
INBOXES_URL="$BASE_URL/mailboxes"
SAVED_REPLIES_URL="$BASE_URL/mailboxes/{mailboxId}/saved-replies"
SAVED_REPLY_URL="$BASE_URL/mailboxes/{mailboxId}/saved-replies/{savedReplyId}"

# Output files
INBOXES_FILE="inboxes.json"
SAVED_REPLIES_FILE="saved_replies_{mailboxId}.json"
SAVED_REPLY_FILE="saved_reply_{mailboxId}_{savedReplyId}.json"

# Function to get the access token
get_access_token() {
  response=$(curl -s -X POST "$AUTH_URL" \
    -d "grant_type=client_credentials&client_id=$APPLICATION_ID&client_secret=$APPLICATION_SECRET")
  access_token=$(echo $response | jq -r '.access_token')
  echo $access_token
}

# Function to fetch data from the Help Scout API and save it to a file
fetch_data() {
  local endpoint=$1
  local output_file=$2
  curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "$endpoint" -o $output_file
  echo "Fetched data from $endpoint"
}

# Get access token
ACCESS_TOKEN=$(get_access_token)

# Fetch inboxes
fetch_data "$INBOXES_URL" $INBOXES_FILE

# Check if inboxes.json has the correct structure
if jq -e '._embedded.mailboxes' $INBOXES_FILE >/dev/null; then
  # Fetch saved replies for each mailbox
  mailbox_ids=$(jq -r '._embedded.mailboxes[].id' $INBOXES_FILE)
  for mailbox_id in $mailbox_ids; do
    fetch_data "${SAVED_REPLIES_URL//"{mailboxId}"/$mailbox_id}" ${SAVED_REPLIES_FILE//"{mailboxId}"/$mailbox_id}

    # Fetch each saved reply for the mailbox
    if jq -e '.savedReplies' ${SAVED_REPLIES_FILE//"{mailboxId}"/$mailbox_id} >/dev/null; then
      saved_reply_ids=$(jq -r '.savedReplies[].id' ${SAVED_REPLIES_FILE//"{mailboxId}"/$mailbox_id})
      for saved_reply_id in $saved_reply_ids; do
        fetch_data "${SAVED_REPLY_URL//"{mailboxId}"/$mailbox_id//"{savedReplyId}"/$saved_reply_id}" ${SAVED_REPLY_FILE//"{mailboxId}"/$mailbox_id//"{savedReplyId}"/$saved_reply_id}
      done
    else
      echo "Error: Invalid structure in ${SAVED_REPLIES_FILE//"{mailboxId}"/$mailbox_id}"
    fi
  done
else
  echo "Error: Invalid structure in $INBOXES_FILE"
fi

echo "Inboxes saved to $INBOXES_FILE"
echo "Saved replies saved to saved_replies_{mailboxId}.json"
echo "Individual saved replies saved to saved_reply_{mailboxId}_{savedReplyId}.json"
