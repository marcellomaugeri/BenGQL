#!/usr/bin/env bash
set -euo pipefail

USERNAME="root"
PASSWORD="3jAR8hK9c3cj"

# Perform the “login” call and extract the private_token
# Note: the /session endpoint returns JSON with .private_token :contentReference[oaicite:0]{index=0}
TOKEN=$(curl -s --request POST "${CASE_STUDY_ENDPOINT}/session" \
  --form "login=${USERNAME}" \
  --form "password=${PASSWORD}" \
  | jq -r .private_token)

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo "❌ Failed to log in or parse token." >&2
  exit 1
fi

echo "PRIVATE-TOKEN: $TOKEN"