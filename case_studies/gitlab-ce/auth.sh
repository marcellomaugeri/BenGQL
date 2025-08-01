
USERNAME="root"
PASSWORD="3jAR8hK9c3cj"

# Perform the “login” call and extract the private_token
# Note: the /session endpoint returns JSON with .private_token :contentReference[oaicite:0]{index=0}

# 1) Fetch both headers and body into PAGE_DATA
PAGE_DATA=$(curl -s -D - "${CASE_STUDY_ENDPOINT}/users/sign_in" -o -)

# 2) Extract the authenticity_token from the HTML body
#    (Skip headers up to the first blank line)
BODY=${PAGE_DATA#*$'\r\n\r\n'}
AUTHENTICITY_TOKEN=$(printf '%s' "$BODY" \
  | sed -n 's/.*name="authenticity_token" value="\([^"]*\)".*/\1/p')

# 3) Extract all cookies from the headers
#    (Take everything up to the blank line, grep Set-Cookie)
HEADERS=${PAGE_DATA%%$'\r\n\r\n'*}
SESSION_COOKIE=$(printf '%s\n' "$HEADERS" \
  | grep -i '^Set-Cookie:' \
  | sed -E 's/Set-Cookie:[[:space:]]*([^;]+).*/\1/' \
  | paste -sd'; ' -)

# 4) Perform the login POST with raw form data and the Cookie header
TOKEN_RESPONSE=$(curl -s -i --request POST "${CASE_STUDY_ENDPOINT}/users/sign_in" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Referer: ${CASE_STUDY_ENDPOINT}/users/sign_in" \
  -H "Cookie: ${SESSION_COOKIE}" \
  --data-raw "authenticity_token=${AUTHENTICITY_TOKEN}&user%5Blogin%5D=${USERNAME}&user%5Bpassword%5D=${PASSWORD}&user%5Bremember_me%5D=1"
)

# 5) Now extract the Set-Cookie headers from TOKEN_RESPONSE
FINAL_HEADERS=${TOKEN_RESPONSE%%$'\r\n\r\n'*}
FINAL_COOKIE=$(printf '%s\n' "$FINAL_HEADERS" \
  | grep -i '^Set-Cookie:' \
  | sed -E 's/Set-Cookie:[[:space:]]*([^;]+).*/\1/' \
  | paste -sd'; ' -)

# 6) Echo the combined Cookie header line for downstream scripts
echo "Cookie: $FINAL_COOKIE"

if [[ -z "$FINAL_COOKIE" || "$FINAL_COOKIE" == "null" ]]; then
  echo "❌ Failed to log in or parse token." >&2
  exit 1
fi
