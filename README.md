# helpscout-docs-export
This repository contains a script to export Help Scout Docs via their API. The script fetches collections, categories, and articles from the Help Scout Docs API and saves them as JSON files. The helpscout-docs-export.sh script uses the Help Scout Docs API key to retrieve data and organizes it into structured JSON files for easy access and analysis.

##Script Overview
Collections: Fetches all collections and saves them to collections.json.
Categories: Fetches categories for each collection and saves them to categories_{id}.json.
Articles: Fetches articles for each collection and category, saving them to articles_{id}.json.

##Usage
Set your Help Scout Docs API key in the script.
Run the script to export the data.
