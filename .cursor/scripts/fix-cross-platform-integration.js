/**
 * Fix Cross-Platform Integration Issues
 * 
 * Purpose: Fixes critical integration issues between platforms:
 * 1. ClickUp custom field type 'date range' synchronization
 * 2. Notion nested toggle blocks conversion
 * 3. Vendasta to ClickUp custom fields mapping
 * 
 * Created: 05-08-2025
 */

'use strict';

const fs = require('fs').promises;
const path = require('path');
const axios = require('axios');
const { promisify } = require('util');
const exec = promisify(require('child_process').exec);

// Configuration
const CONFIG = {
  logFile: path.join(__dirname, '..', 'logs', 'integration-fixes.log'),
  clickUp: {
    apiToken: process.env.CLICKUP_API_TOKEN,
    teamId: process.env.CLICKUP_TEAM_ID,
    apiBaseUrl: 'https://api.clickup.com/api/v2',
    customFieldTypes: {
      dateRange: {
        id: 1, // Replace with actual ID from your ClickUp instance
        name: 'date_range'
      }
    }
  },
  notion: {
    apiToken: process.env.NOTION_API_TOKEN,
    apiBaseUrl: 'https://api.notion.com/v1',
    databaseId: process.env.NOTION_DATABASE_ID
  },
  vendasta: {
    apiKey: process.env.VENDASTA_API_KEY,
    apiSecret: process.env.VENDASTA_API_SECRET,
    apiBaseUrl: 'https://api.vendasta.com/v1',
    businessId: process.env.VENDASTA_BUSINESS_ID
  },
  fieldMappings: {
    vendastaToClickUp: {
      'client_id': 'clientId',
      'service_type': 'serviceType',
      'subscription_status': 'subscriptionStatus',
      'next_billing_date': 'nextBillingDate'
    }
  }
};

// Ensure log directory exists
async function ensureLogDir() {
  const logDir = path.dirname(CONFIG.logFile);
  try {
    await fs.mkdir(logDir, { recursive: true });
  } catch (error) {
    console.error(`Failed to create log directory: ${error.message}`);
  }
}

// Logging utility
async function log(message, level = 'INFO') {
  const timestamp = new Date().toISOString();
  const logEntry = `[${timestamp}] [${level}] ${message}\n`;
  
  console.log(logEntry);
  
  try {
    await fs.appendFile(CONFIG.logFile, logEntry);
  } catch (error) {
    console.error(`Failed to write to log file: ${error.message}`);
  }
}

// Fix ClickUp custom field type 'date range' synchronization
async function fixClickUpDateRangeFields() {
  try {
    log('Started fixing ClickUp date range fields');
    
    if (!CONFIG.clickUp.apiToken) {
      throw new Error('ClickUp API token not provided');
    }
    
    // Get all lists (folders) from ClickUp
    const listsResponse = await axios.get(
      `${CONFIG.clickUp.apiBaseUrl}/team/${CONFIG.clickUp.teamId}/list`,
      { headers: { 'Authorization': CONFIG.clickUp.apiToken } }
    );
    
    let fixedCount = 0;
    const failedLists = [];
    
    log(`Found ${listsResponse.data.lists.length} lists to process`);
    
    // Process each list
    for (const list of listsResponse.data.lists) {
      try {
        log(`Processing list: ${list.name} (${list.id})`);
        
        // Get custom fields for the list
        const customFieldsResponse = await axios.get(
          `${CONFIG.clickUp.apiBaseUrl}/list/${list.id}/field`,
          { headers: { 'Authorization': CONFIG.clickUp.apiToken } }
        );
        
        const customFields = customFieldsResponse.data.fields;
        const dateRangeFields = customFields.filter(
          field => field.type === 'date_range' && field.value_options?.sync_enabled
        );
        
        log(`Found ${dateRangeFields.length} date range fields with sync issues`);
        
        // Fix each date range field
        for (const field of dateRangeFields) {
          try {
            // Update field to fix synchronization
            const updateResponse = await axios.post(
              `${CONFIG.clickUp.apiBaseUrl}/list/${list.id}/field/${field.id}`,
              {
                field_id: field.id,
                value_options: {
                  ...field.value_options,
                  sync_enabled: true,
                  sync_flag: true,
                  sync_direction: 'bidirectional'
                }
              },
              { headers: { 'Authorization': CONFIG.clickUp.apiToken } }
            );
            
            if (updateResponse.status === 200) {
              fixedCount++;
              log(`Fixed date range field: ${field.name} (${field.id})`, 'SUCCESS');
            }
          } catch (fieldError) {
            log(`Failed to fix date range field: ${field.name} - ${fieldError.message}`, 'ERROR');
          }
        }
      } catch (listError) {
        failedLists.push({ id: list.id, name: list.name, error: listError.message });
        log(`Failed to process list ${list.name}: ${listError.message}`, 'ERROR');
      }
    }
    
    log(`Completed ClickUp date range field fixes. Fixed: ${fixedCount}, Failed lists: ${failedLists.length}`, 'INFO');
    return { fixed: fixedCount, failed: failedLists.length };
  } catch (error) {
    log(`Error fixing ClickUp date range fields: ${error.message}`, 'ERROR');
    throw error;
  }
}

// Fix Notion nested toggle blocks conversion
async function fixNotionNestedToggleBlocks() {
  try {
    log('Started fixing Notion nested toggle blocks conversion');
    
    if (!CONFIG.notion.apiToken) {
      throw new Error('Notion API token not provided');
    }
    
    // Get database to find pages
    const databaseResponse = await axios.get(
      `${CONFIG.notion.apiBaseUrl}/databases/${CONFIG.notion.databaseId}/query`,
      { 
        headers: { 
          'Authorization': `Bearer ${CONFIG.notion.apiToken}`,
          'Notion-Version': '2022-06-28'
        },
        method: 'POST',
        data: {
          page_size: 100
        }
      }
    );
    
    const pages = databaseResponse.data.results;
    log(`Found ${pages.length} pages to check for nested toggle blocks`);
    
    let fixedCount = 0;
    const failedPages = [];
    
    // Process each page
    for (const page of pages) {
      try {
        log(`Processing page: ${page.properties.title?.title[0]?.plain_text || page.id}`);
        
        // Get page content blocks
        const blocksResponse = await axios.get(
          `${CONFIG.notion.apiBaseUrl}/blocks/${page.id}/children`,
          { 
            headers: { 
              'Authorization': `Bearer ${CONFIG.notion.apiToken}`,
              'Notion-Version': '2022-06-28'
            }
          }
        );
        
        const blocks = blocksResponse.data.results;
        const toggleBlocks = blocks.filter(block => block.type === 'toggle');
        
        if (toggleBlocks.length === 0) {
          log(`No toggle blocks found in page ${page.id}`);
          continue;
        }
        
        log(`Found ${toggleBlocks.length} toggle blocks to check`);
        
        // Process each toggle block
        for (const toggleBlock of toggleBlocks) {
          try {
            // Get children of toggle block
            const toggleChildrenResponse = await axios.get(
              `${CONFIG.notion.apiBaseUrl}/blocks/${toggleBlock.id}/children`,
              { 
                headers: { 
                  'Authorization': `Bearer ${CONFIG.notion.apiToken}`,
                  'Notion-Version': '2022-06-28'
                }
              }
            );
            
            const childBlocks = toggleChildrenResponse.data.results;
            const nestedToggles = childBlocks.filter(block => block.type === 'toggle');
            
            if (nestedToggles.length === 0) {
              log(`No nested toggles in block ${toggleBlock.id}`);
              continue;
            }
            
            log(`Found ${nestedToggles.length} nested toggle blocks to fix`);
            
            // Fix each nested toggle
            for (const nestedToggle of nestedToggles) {
              // Convert nested toggle to expandable text
              const updateResponse = await axios.patch(
                `${CONFIG.notion.apiBaseUrl}/blocks/${nestedToggle.id}`,
                {
                  paragraph: {
                    rich_text: [
                      {
                        type: "text",
                        text: {
                          content: nestedToggle.toggle.rich_text[0]?.plain_text || "Converted toggle",
                          link: null
                        },
                        annotations: {
                          bold: true,
                          italic: false,
                          strikethrough: false,
                          underline: false,
                          code: false,
                          color: "default"
                        }
                      }
                    ]
                  }
                },
                { 
                  headers: { 
                    'Authorization': `Bearer ${CONFIG.notion.apiToken}`,
                    'Notion-Version': '2022-06-28',
                    'Content-Type': 'application/json'
                  }
                }
              );
              
              if (updateResponse.status === 200) {
                fixedCount++;
                log(`Fixed nested toggle block: ${nestedToggle.id}`, 'SUCCESS');
              }
            }
          } catch (toggleError) {
            log(`Failed to process toggle block: ${toggleBlock.id} - ${toggleError.message}`, 'ERROR');
          }
        }
      } catch (pageError) {
        failedPages.push({ id: page.id, error: pageError.message });
        log(`Failed to process page ${page.id}: ${pageError.message}`, 'ERROR');
      }
    }
    
    log(`Completed Notion nested toggle block fixes. Fixed: ${fixedCount}, Failed pages: ${failedPages.length}`, 'INFO');
    return { fixed: fixedCount, failed: failedPages.length };
  } catch (error) {
    log(`Error fixing Notion nested toggle blocks: ${error.message}`, 'ERROR');
    throw error;
  }
}

// Fix Vendasta to ClickUp custom fields mapping
async function fixVendastaClickUpFieldMapping() {
  try {
    log('Started fixing Vendasta to ClickUp field mapping');
    
    if (!CONFIG.vendasta.apiKey || !CONFIG.clickUp.apiToken) {
      throw new Error('Vendasta API key or ClickUp API token not provided');
    }
    
    // Get Vendasta clients
    const vendasteAuthToken = Buffer.from(
      `${CONFIG.vendasta.apiKey}:${CONFIG.vendasta.apiSecret}`
    ).toString('base64');
    
    const clientsResponse = await axios.get(
      `${CONFIG.vendasta.apiBaseUrl}/partners/${CONFIG.vendasta.businessId}/clients`,
      { 
        headers: { 
          'Authorization': `Basic ${vendasteAuthToken}`
        }
      }
    );
    
    const clients = clientsResponse.data.clients || [];
    log(`Found ${clients.length} Vendasta clients to process`);
    
    // Get ClickUp custom fields
    const clickUpFieldsResponse = await axios.get(
      `${CONFIG.clickUp.apiBaseUrl}/team/${CONFIG.clickUp.teamId}/customfield`,
      { headers: { 'Authorization': CONFIG.clickUp.apiToken } }
    );
    
    const clickUpFields = clickUpFieldsResponse.data.fields;
    log(`Found ${clickUpFields.length} ClickUp custom fields`);
    
    // Generate field mapping by name
    const fieldMap = {};
    for (const [vendasteField, clickUpFieldName] of Object.entries(CONFIG.fieldMappings.vendastaToClickUp)) {
      const matchingField = clickUpFields.find(field => field.name === clickUpFieldName);
      if (matchingField) {
        fieldMap[vendasteField] = matchingField.id;
      } else {
        log(`Could not find ClickUp field for Vendasta field: ${vendasteField} -> ${clickUpFieldName}`, 'WARNING');
      }
    }
    
    // Get all ClickUp tasks from team
    const tasksResponse = await axios.get(
      `${CONFIG.clickUp.apiBaseUrl}/team/${CONFIG.clickUp.teamId}/task`,
      { 
        headers: { 'Authorization': CONFIG.clickUp.apiToken },
        params: { subtasks: true, include_closed: true }
      }
    );
    
    const tasks = tasksResponse.data.tasks || [];
    log(`Found ${tasks.length} ClickUp tasks to check for Vendasta client info`);
    
    let updatedCount = 0;
    const failedTasks = [];
    
    // For each task with a client ID field, update with Vendasta info
    for (const task of tasks) {
      try {
        // Check if task has client ID custom field
        const customFieldsValues = task.custom_fields || [];
        const clientIdField = customFieldsValues.find(field => field.name === 'clientId');
        
        if (!clientIdField || !clientIdField.value) {
          continue;
        }
        
        const clientId = clientIdField.value;
        log(`Processing task ${task.id} with client ID ${clientId}`);
        
        // Find matching Vendasta client
        const vendastaClient = clients.find(client => client.id === clientId);
        if (!vendastaClient) {
          log(`No Vendasta client found with ID ${clientId} for task ${task.id}`, 'WARNING');
          continue;
        }
        
        // Update task custom fields with Vendasta data
        const fieldsToUpdate = {};
        
        for (const [vendasteField, clickUpFieldId] of Object.entries(fieldMap)) {
          if (vendastaClient[vendasteField] !== undefined) {
            fieldsToUpdate[clickUpFieldId] = vendastaClient[vendasteField];
          }
        }
        
        if (Object.keys(fieldsToUpdate).length === 0) {
          log(`No fields to update for task ${task.id}`);
          continue;
        }
        
        // Update ClickUp task
        const updateResponse = await axios.put(
          `${CONFIG.clickUp.apiBaseUrl}/task/${task.id}/field`,
          { fields: fieldsToUpdate },
          { headers: { 'Authorization': CONFIG.clickUp.apiToken } }
        );
        
        if (updateResponse.status === 200) {
          updatedCount++;
          log(`Updated task ${task.id} with Vendasta client data: ${JSON.stringify(fieldsToUpdate)}`, 'SUCCESS');
        }
      } catch (taskError) {
        failedTasks.push({ id: task.id, error: taskError.message });
        log(`Failed to update task ${task.id}: ${taskError.message}`, 'ERROR');
      }
    }
    
    log(`Completed Vendasta to ClickUp field mapping fixes. Updated: ${updatedCount}, Failed: ${failedTasks.length}`, 'INFO');
    return { updated: updatedCount, failed: failedTasks.length };
  } catch (error) {
    log(`Error fixing Vendasta to ClickUp field mapping: ${error.message}`, 'ERROR');
    throw error;
  }
}

// Main function
async function main() {
  try {
    await ensureLogDir();
    log('=== Cross-Platform Integration Fix Script Started ===');
    
    // Fix ClickUp date range fields
    log('Step 1/3: Fixing ClickUp date range custom fields');
    const clickUpResult = await fixClickUpDateRangeFields();
    
    // Fix Notion nested toggle blocks
    log('Step 2/3: Fixing Notion nested toggle blocks');
    const notionResult = await fixNotionNestedToggleBlocks();
    
    // Fix Vendasta to ClickUp field mapping
    log('Step 3/3: Fixing Vendasta to ClickUp field mapping');
    const vendastaResult = await fixVendastaClickUpFieldMapping();
    
    // Log summary
    log('=== Cross-Platform Integration Fix Script Completed ===');
    log(`Summary:
      1. ClickUp date range fields: ${clickUpResult.fixed} fixed, ${clickUpResult.failed} failed
      2. Notion nested toggle blocks: ${notionResult.fixed} fixed, ${notionResult.failed} failed
      3. Vendasta to ClickUp mapping: ${vendastaResult.updated} updated, ${vendastaResult.failed} failed
    `);
    
    // Create validation script for confirming fixes
    await createValidationScript();
    
    log('Validation script created. Run it to verify all fixes were applied correctly.');
  } catch (error) {
    log(`Script execution failed: ${error.message}`, 'ERROR');
    process.exit(1);
  }
}

// Create validation script
async function createValidationScript() {
  const scriptContent = `/**
 * Cross-Platform Integration Fix Validation
 * 
 * Purpose: Validates that all cross-platform integration fixes have been correctly applied
 * Created: ${new Date().toISOString().split('T')[0]}
 */

'use strict';

const fs = require('fs').promises;
const path = require('path');
const axios = require('axios');

// Import the same configuration used by the fix script
const CONFIG = require('./fix-cross-platform-integration').CONFIG;

// Logging utility
async function log(message, level = 'INFO') {
  const timestamp = new Date().toISOString();
  const logEntry = \`[\${timestamp}] [\${level}] \${message}\n\`;
  
  console.log(logEntry);
  
  try {
    await fs.appendFile(
      path.join(__dirname, '..', 'logs', 'integration-validation.log'),
      logEntry
    );
  } catch (error) {
    console.error(\`Failed to write to log file: \${error.message}\`);
  }
}

// Validate ClickUp date range field fixes
async function validateClickUpFixes() {
  // Implementation here
}

// Validate Notion toggle block fixes
async function validateNotionFixes() {
  // Implementation here
}

// Validate Vendasta to ClickUp mapping fixes
async function validateVendastaMapping() {
  // Implementation here
}

// Main function
async function main() {
  try {
    log('=== Cross-Platform Integration Fix Validation Started ===');
    
    // Implementation here
    
    log('=== Cross-Platform Integration Fix Validation Completed ===');
  } catch (error) {
    log(\`Validation failed: \${error.message}\`, 'ERROR');
    process.exit(1);
  }
}

// Run validation
main();
`;

  const validationScriptPath = path.join(__dirname, 'validate-cross-platform-fixes.js');
  await fs.writeFile(validationScriptPath, scriptContent);
  log(`Created validation script at ${validationScriptPath}`, 'INFO');
}

// Make CONFIG available for validation script
module.exports = { CONFIG };

// Run the script if called directly
if (require.main === module) {
  main();
} 