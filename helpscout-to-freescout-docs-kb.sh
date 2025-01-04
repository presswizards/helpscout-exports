#!/bin/bash

# Help Scout Docs API key
API_KEY="your_helpscout_docs_api_key"

# FreeScout API credentials
FREESCOUT_API_TOKEN="your_freescout_api_token"
FREESCOUT_URL="https://your-freescout-domain/api/v1"

# Base URL for the Help Scout Docs API
BASE_URL="https://docsapi.helpscout.net/v1"

# Function to call the Help Scout Docs API and return the JSON response
fetch_data() {
  local endpoint=$1
  curl -s -u "$API_KEY:x" "$BASE_URL/$endpoint"
}

# Function to create a category in FreeScout
create_freescout_category() {
  local name=$1
  local description=$2
  curl -s -X POST "$FREESCOUT_URL/kb/categories" \
    -H "Authorization: Bearer $FREESCOUT_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$name\",\"description\":\"$description\"}"
}

# Function to create an article in FreeScout
create_freescout_article() {
  local category_id=$1
  local title=$2
  local content=$3
  curl -s -X POST "$FREESCOUT_URL/kb/articles" \
    -H "Authorization: Bearer $FREESCOUT_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"category_id\":\"$category_id\",\"title\":\"$title\",\"content\":\"$content\"}"
}

# Fetch collections
collections=$(fetch_data "collections")

# Check if collections have the correct structure
if echo $collections | jq -e '.collections.items' >/dev/null; then
  # Fetch categories and articles for each collection
  collection_ids=$(echo $collections | jq -r '.collections.items[].id')
  for collection_id in $collection_ids; do
    categories=$(fetch_data "collections/$collection_id/categories")
    articles=$(fetch_data "collections/$collection_id/articles")

    # Create categories and articles in FreeScout
    category_ids=$(echo $categories | jq -r '.categories.items[].id')
    for category_id in $category_ids; do
      category_name=$(echo $categories | jq -r ".categories.items[] | select(.id == \"$category_id\") | .name")
      category_description=$(echo $categories | jq -r ".categories.items[] | select(.id == \"$category_id\") | .description")
      create_freescout_category "$category_name" "$category_description"

      category_articles=$(fetch_data "categories/$category_id/articles")
      article_ids=$(echo $category_articles | jq -r '.articles.items[].id')
      for article_id in $article_ids; do
        article_title=$(echo $category_articles | jq -r ".articles.items[] | select(.id == \"$article_id\") | .name")
        article_content=$(echo $category_articles | jq -r ".articles.items[] | select(.id == \"$article_id\") | .text")
        create_freescout_article "$category_id" "$article_title" "$article_content"
      done
    done
  done
else
  echo "Error: Invalid structure in collections response"
fi

echo "Collections, categories, and articles have been created in FreeScout"
