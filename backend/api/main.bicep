// ============================================================================
// Cloud Resume Challenge - Backend Infrastructure (Python)
// Author: Fabian (guided by Copilot)
// Purpose: Deploy a Function App + Storage + Table + Monitoring using IaC
// ============================================================================

// ---------------------------
// Parameters
// ---------------------------
param location string = resourceGroup().location
param storageAccountName string
param functionAppName string
param tableName string = 'VisitorCounter'

// ---------------------------
// Storage Account
// ---------------------------
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

// ---------------------------
// Table Service (required parent)
// ---------------------------
resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

// ---------------------------
// Storage Table
// ---------------------------
resource visitorTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  name: tableName
  parent: tableService
}

// ---------------------------
// Application Insights
// ---------------------------
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${functionAppName}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// ---------------------------
// Hosting Plan (Consumption)
// ---------------------------
resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${functionAppName}-plan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

// ---------------------------
// Function App (Python)
// ---------------------------
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'Python|3.10'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.listKeys().keys[0].value
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'TABLE_STORAGE_ACCOUNT'
          value: storageAccount.name
        }
        {
          name: 'TABLE_NAME'
          value: tableName
        }
      ]
    }
    httpsOnly: true
  }
}

// ---------------------------
// RBAC: Allow Function to read/write Table Storage
// ---------------------------
resource tableRbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.id, 'table-data-contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' // Storage Table Data Contributor
    )
    principalId: functionApp.identity.principalId
  }
}
