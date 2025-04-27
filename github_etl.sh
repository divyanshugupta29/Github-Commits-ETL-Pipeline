#!/bin/bash

# --- Configurations ---
REPO_OWNER="apache"
REPO_NAME="spark"
GITHUB_API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/commits"
LAST_TIMESTAMP_FILE="last_timestamp.txt"
OUTPUT_FILE="commits.json"

# --- Read last timestamp ---
if [ -f "$LAST_TIMESTAMP_FILE" ]; then
  LAST_FETCH_TIME=$(cat "$LAST_TIMESTAMP_FILE")
else
  # If no timestamp file, default to a very old date
  LAST_FETCH_TIME="2000-01-01T00:00:00Z"
fi

echo "Last fetch time: $LAST_FETCH_TIME"

# --- Fetch new commits using curl ---
echo "Fetching commits from GitHub..."
curl -s "${GITHUB_API_URL}?since=${LAST_FETCH_TIME}" -o "$OUTPUT_FILE"

echo "Data fetched and saved to $OUTPUT_FILE"

