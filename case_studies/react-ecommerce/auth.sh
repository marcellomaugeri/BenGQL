#!/usr/bin/env bash

# 1. Register the user (ignore output)
curl -s -X POST "${CASE_STUDY_ENDPOINT}" \
  -H "Content-Type: application/json" \
  --data-raw '{
    "query":"mutation CreateUser($input: CreateUserDto!) { createUser(data: $input) { id email username } }",
    "variables": {
      "input": {
        "username": "alice",
        "name": "Alice Example",
        "email": "alice@example.com",
        "password": "s3cr3tPass!",
        "confirmPassword": "s3cr3tPass!"
      }
    }
  }' > /dev/null

# 2. Login and capture the token
response=$(curl -s -X POST "${CASE_STUDY_ENDPOINT}" \
  -H "Content-Type: application/json" \
  --data-raw '{
    "query":"mutation Login($credentials: AuthDto!) { login(data: $credentials) { token } }",
    "variables": {
      "credentials": {
        "email": "alice@example.com",
        "password": "s3cr3tPass!"
      }
    }
  }')

# Extract token from JSON
token=$(echo "$response" | sed -n 's/.*"token"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

# Echo only the header
echo "Authorization: Bearer $token"