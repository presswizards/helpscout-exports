# helpscout-docs-export-api.sh
This file contains a script to export Help Scout Docs via their API. The script fetches collections, categories, and articles from the Help Scout Docs API and saves them as JSON files. The helpscout-docs-export.sh script uses the Help Scout Docs API key to retrieve data and organizes it into structured JSON files for easy access and analysis.

## Dependencies
You'll need to install https://jqlang.github.io/jq/

## Script Overview
* Collections: Fetches all collections and saves them to collections.json.
* Categories: Fetches categories for each collection and saves them to categories_{id}.json.
* Articles: Fetches articles for each collection and category, saving them to articles_{id}.json.

## Usage
* Set your Help Scout Docs API key in the script.
* Run the script to export the data.

# helpscout-inbox-saved-replies-export.sh
This file contains scripts to export Help Scout data via their API. The scripts fetch inboxes, and saved replies from the Help Scout APIs and save them as JSON files.

## Script Overview
* Inboxes: Fetches inboxes and saves them to inboxes.json.
* Saved Replies: Fetches saved replies for each inbox and saves them to saved_replies_{mailboxId}.json.

## Usage
* Set your Help Scout API credentials in the script. You can obtain these by creating a new app in `My Apps` (under `My Profile`) 
* Run the script to export the desired data.
