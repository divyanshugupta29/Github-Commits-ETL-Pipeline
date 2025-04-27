#!/bin/bash

set -o allexport
source .env
set +o allexport

# --- Configurations ---
REPO_OWNER="apache"
REPO_NAME="spark"
GITHUB_API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/commits"
LAST_TIMESTAMP_FILE="last_timestamp.txt"
OUTPUT_FILE="commits.json"
LAST_FETCH_TIME="2000-01-01T00:00:00Z"  # Default to a very old date
# --- Read last timestamp if file exists and not empty---

if [ -s "$LAST_TIMESTAMP_FILE" ]; then
  LAST_FETCH_TIME=$(cat "$LAST_TIMESTAMP_FILE")
else
  LAST_FETCH_TIME="2000-01-01T00:00:00Z"  # Default to a very old date
fi

echo "Last fetch time: $LAST_FETCH_TIME"

# --- Fetch new commits ---
curl -s "${GITHUB_API_URL}?since=${LAST_FETCH_TIME}&sort=updated" -o "$OUTPUT_FILE"

if [ $? -ne 0 ] ;then
  echo "error in fetching data from api"
  exit 2
fi

echo "Data Successfully fathed into $OUTPUT_FILE"

# --- Parse commits and insert into DB (MySQL example) ---
LATEST_COMMIT_DATE=$(jq -r '.[0].commit.author.date' "$OUTPUT_FILE")


if [ ! -s "$OUTPUT_FILE" ]; then
  echo "⚠️ Warning: No new commits found."
  exit 0
fi


# Loop through commits and insert into MySQL
while IFS=',' read -r sha author date; do
  # If date is valid, use it, otherwise set to NULL
  # if [[ $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
  #   commit_date=$date
  # else
  #   commit_date=NULL
  # fi

  date=$(echo "$date" | sed -e 's/T/ /' -e 's/Z//')
  # echo $date

  # Insert into DB with the date (or NULL if invalid)
  # mysql -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -e \
  #   "INSERT INTO commits (commit_sha, author_name, commit_date) VALUES ('$sha', '$author', $date);"

  # Check if commit already exists
  exists=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -se "SELECT COUNT(*) FROM commits WHERE commit_sha='$sha';")

  if [ "$exists" -eq 0 ]; then
    # Only insert if not already present
    mysql -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -e \
      "INSERT INTO commits (commit_sha, author_name, commit_date) VALUES ('$sha', '$author', '$date');"|| {
  echo "❌ Error: Failed to insert commit $sha into database."
  exit 5
}
  else
    echo "Commit $sha already exists. Skipping insert."
  fi

done < <(jq -r '.[] | [.sha, .commit.author.name, .commit.author.date] | @csv' commits.json)

if [ $? -ne 0 ]; then
  echo "error in sql"
  exit 3
fi
# --- After successful insert, update last timestamp ---
echo "$LATEST_COMMIT_DATE" > "$LAST_TIMESTAMP_FILE"

echo "ETL process completed. Last timestamp updated."
echo "$(date '+%Y-%m-%d %H:%M:%S') - Successfully fetched and inserted new commits!" >> pipeline.log
rm -f "$OUTPUT_FILE"