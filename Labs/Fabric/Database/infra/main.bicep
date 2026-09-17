metadata description = 'K12 Education Fabric Lab Infrastructure - Secure deployment with no public endpoints'
metadata author = 'Lab Setup'
metadata version = '1.0.0'

targetScope = 'subscription'

// ============================================================================
// Parameters
// ============================================================================
@description('Workload name')
param workloadName string

@description('Azure region for resources and resource group')
param location string = deployment().location

@description('Unique suffix for resource names to ensure global uniqueness (e.g., devjq, jqtest)')
param uniqueSuffix string
  
@description('VNet configuration object with address prefix and subnet prefixes')
param vnetConfig object

@description('SQL database configuration object')
param sqlConfig object

@secure()
@description('VM administrator credentials')  
param vmCredentials object

@description('VM configuration object')
param vmConfig object

@description('Storage account configuration object')
param storageConfig object

// ============================================================================
// Variables
// ============================================================================
var resourceGroupName = 'rg-${workloadName}-${uniqueSuffix}'
var nsgName = 'nsg-${workloadName}-${uniqueSuffix}'
var vnetName = 'vnet-${workloadName}-${uniqueSuffix}'
var bastionName = 'bastion-${vnetName}'
var sqlServerName = 'sql-${workloadName}-${uniqueSuffix}'
var sqlDatabaseName = 'sqldb-${workloadName}-${uniqueSuffix}'
var sqlPrivateEndpointName = 'pep-${sqlServerName}'
var vmName = 'vm-${workloadName}-${uniqueSuffix}'
var vmNicName = 'nic-${vmName}'
var storageAccountName = replace('st-${workloadName}-${uniqueSuffix}', '-', '')
var storagePrivateEndpointName = 'pep-${storageAccountName}'

// ============================================================================
// Resource Group
// ============================================================================
resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

// ============================================================================
// Network Security Groups
// ============================================================================
module nsg 'br/public:avm/res/network/network-security-group:0.5.3' = {
  scope: rg
  name: 'deploy-${nsgName}'
  params: {
    name: nsgName
    location: location
  }
}

// ============================================================================
// Virtual Network with Subnets
// ============================================================================
module vnet 'br/public:avm/res/network/virtual-network:0.8.0' = {
  scope: rg
  name: 'deploy-${vnetName}'
  params: {
    name: vnetName
    location: location
    addressPrefixes: [
      vnetConfig.addressPrefix
    ]
    subnets: [
      {
        name: 'storage-subnet'
        addressPrefix: vnetConfig.storageSubnetPrefix
        networkSecurityGroupResourceId: nsg.outputs.resourceId
        serviceEndpoints: [
          'Microsoft.Sql'
        ]
      }
      {
        name: 'vm-subnet'
        addressPrefix: vnetConfig.vmSubnetPrefix
        networkSecurityGroupResourceId: nsg.outputs.resourceId
      }
    ]
  }
}

// ============================================================================
// Bastion Host
// ============================================================================
module bastion 'br/public:avm/res/network/bastion-host:0.8.2' = {
  scope: rg
  name: 'deploy-${bastionName}'
  params: {
    name: bastionName
    location: location
    virtualNetworkResourceId: vnet.outputs.resourceId
    skuName: 'Developer'
  }
}

// ============================================================================
// Private DNS Zone for SQL Server
// ============================================================================
module sqlPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.8.1' = {
  scope: rg
  name: 'deploy-dns-${sqlPrivateEndpointName}'
  params: {
    name: 'privatelink${environment().suffixes.sqlServerHostname}'
    virtualNetworkLinks: [
      {
        registrationEnabled: false
        virtualNetworkResourceId: vnet.outputs.resourceId
      }
    ]
  }
}

// ============================================================================
// Private DNS Zone for Storage Account
// ============================================================================
module storagePrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.8.1' = {
  scope: rg
  name: 'deploy-dns-${storagePrivateEndpointName}'
  params: {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    virtualNetworkLinks: [
      {
        registrationEnabled: false
        virtualNetworkResourceId: vnet.outputs.resourceId
      }
    ]
  }
}

// ========================================================================
// SQL Server and Database
// ========================================================================
module sqlServer 'br/public:avm/res/sql/server:0.21.1' = {
  scope: rg
  name: 'deploy-${sqlServerName}'
  params: {
    name: sqlServerName
    administrators: sqlConfig.administrator
    publicNetworkAccess: 'Disabled'
    databases: [
      {
        availabilityZone: sqlConfig.database.availabilityZone
        collation: sqlConfig.database.collation
        name: sqlDatabaseName
        sku: sqlConfig.database.sku
        autoPauseDelay: sqlConfig.database.autoPauseDelay
        minCapacity: sqlConfig.database.minCapacity
        zoneRedundant: sqlConfig.database.zoneRedundant
        requestedBackupStorageRedundancy: sqlConfig.database.requestedBackupStorageRedundancy
      }
    ]
    location: location
    managedIdentities:{
      systemAssigned:true
    }
    privateEndpoints: [
      {
        name: sqlPrivateEndpointName
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: sqlPrivateDnsZone.outputs.resourceId
            }
          ]
        }
      }
    ]
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

// ============================================================================
// Virtual Machine
// ============================================================================
module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.22.0' = {
  name: 'deploy-${vmName}'
  scope: rg
  params: {
    adminUsername: vmCredentials.adminUsername
    adminPassword: vmCredentials.adminPassword
    imageReference: vmConfig.imageReference
    name: vmName
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: vnet.outputs.subnetResourceIds[1]
          }
        ]
        name: vmNicName
      }
    ]
    osDisk: vmConfig.osDisk
    osType: vmConfig.osType
    vmSize: vmConfig.vmSize
    computerName: vmConfig.computeName
    encryptionAtHost: vmConfig.encryptionAtHost
    vTpmEnabled: vmConfig.vtpmEnabled
    secureBootEnabled: vmConfig.secureBootEnabled
    availabilityZone: vmConfig.availabilityZone
    managedIdentities: {
      systemAssigned: true
    }
    autoShutdownConfig: vmConfig.autoShutdownConfig
    extensionCustomScriptConfig: {
      name: 'CustomScriptExtension'
      typeHandlerVersion: '1.10'
      autoUpgradeMinorVersion: true
      settings: {
        fileUris: [
          'https://raw.githubusercontent.com/JoelQuimper/presentations-and-labs/main/Labs/Fabric/Database/infra/vm-config/initialize-vm.ps1'
        ]
        commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File initialize-vm.ps1 -StorageAccountName ${storageAccountName}'
      }
    }
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.32.0' = {
  scope: rg
  name: 'deploy-${storageAccountName}'
  params: {
    // Required parameters
    name: storageAccountName
    // Non-required parameters
    kind: storageConfig.kind
    skuName: storageConfig.skuName
    allowBlobPublicAccess: storageConfig.allowBlobPublicAccess
    privateEndpoints: [
      {
        name: storagePrivateEndpointName
        service: 'blob'
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: storagePrivateDnsZone.outputs.resourceId
            }
          ]
        }
      }
    ]
    roleAssignments: [
    {
      principalId: virtualMachine.outputs.?systemAssignedMIPrincipalId ?? ''
      principalType: 'ServicePrincipal'
      roleDefinitionIdOrName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    }
    {
      principalId: sqlServer.outputs.?systemAssignedMIPrincipalId ?? ''
      principalType: 'ServicePrincipal'
      roleDefinitionIdOrName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    }
  ]
  }
}
