# JSON Versions for AI Consumption



## Metadata


---


## Purpose


- These JSON files are automatically generated and kept in sync with their Markdown counterparts

- AI assistants are configured to read from these files instead of the Markdown versions

- The structure is optimized for efficient parsing and reduced token consumption


## File Structure


Each JSON file follows this general structure:

```json

{

"id": "filename",

"title": "Document Title",

"url": "Associated URL (if applicable)",

"metadata": {

"lastUpdated": "MM-DD-YYYY",

"purpose": "Document purpose",

"targetAudience": "Intended audience"

},

"sections": [

{

"title": "Section Title",

"content": [

"Content items or paragraphs",

{

"subtitle": "Subsection title",

"items": [

"Bullet point 1",

"Bullet point 2"

]

}

]

}

]

}

```


## Usage Notes


- **Do not edit these files directly** - they are automatically generated

- To make changes, edit the corresponding Markdown file in the parent directory

- The MD-to-JSON synchronization system will automatically update these files


## Learn More


For more information on the MD-to-JSON synchronization system, see:

- `/docs/json-sync-system.md` - Full documentation on the system

- `/md-to-json.js` - The conversion script

- `/.cursor/rules/.cursorrules` - AI configuration for using these files

---

Last updated: 05-10-2025


---

Last updated: 03-11-2025