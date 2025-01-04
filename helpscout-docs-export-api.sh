#!/bin/bash

# Help Scout Docs API key
API_KEY="helpscout-docs-api-key-here"

# Base URL for the Help Scout Docs API
BASE_URL="https://docsapi.helpscout.net/v1"

# Output files
COLLECTIONS_FILE="collections.json"
CATEGORIES_FILE="categories_{id}.json"
ARTICLES_FILE="articles_{id}.json"

# Function to call the Help Scout Docs API and save the JSON response to a file
fetch_data() {
  local endpoint=$1
  local output_file=$2
  curl -u "$API_KEY:x" "$BASE_URL/$endpoint" -o $output_file
  echo "Fetched data from $BASE_URL/$endpoint"
}

# Fetch collections
fetch_data "collections" $COLLECTIONS_FILE

# Check if collections.json has the correct structure
if jq -e '.collections.items' $COLLECTIONS_FILE >/dev/null; then
  # Fetch categories for each collection
  collection_ids=$(jq -r '.collections.items[].id' $COLLECTIONS_FILE)
  for collection_id in $collection_ids; do
    fetch_data "collections/$collection_id/categories" ${CATEGORIES_FILE//"{id}"/$collection_id}

    # Fetch articles for each collection
    fetch_data "collections/$collection_id/articles" ${ARTICLES_FILE//"{id}"/$collection_id}

    # Fetch articles for each category
    category_ids=$(jq -r '.categories.items[].id' ${CATEGORIES_FILE//"{id}"/$collection_id})
    for category_id in $category_ids; do
      fetch_data "categories/$category_id/articles" ${ARTICLES_FILE//"{id}"/$category_id}
    done
  done
else
  echo "Error: Invalid structure in $COLLECTIONS_FILE"
fi

echo "Collections saved to $COLLECTIONS_FILE"
echo "Categories saved to categories_{id}.json"
echo "Articles saved to articles_{id}.json"
