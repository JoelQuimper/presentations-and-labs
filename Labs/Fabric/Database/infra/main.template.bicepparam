using './main.bicep'

param uniqueSuffix = '<UNIQUE SUFFIX>'

// VNet Configuration
param vnetConfig = {
  addressPrefix: '10.0.0.0/16'
  sqlSubnetPrefix: '10.0.1.0/24'
  vmSubnetPrefix: '10.0.2.0/24'
}

// SQL Server Configuration 
param sqlConfig = {
  administrator: {
    azureADOnlyAuthentication: true
    login: '<YOUR ENTRA LOGIN>'
    principalType: 'User'
    sid: '<YOUR ENTRA USER SID>'
  }
  database: {
    availabilityZone: -1
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    sku: {
      capacity: 2
      name: 'GP_S_Gen5'
      tier: 'GeneralPurpose'
    }
    autoPauseDelay: 30
    minCapacity: '0.5'
    zoneRedundant: false
    requestedBackupStorageRedundancy: 'Local'
   }
}

// VM Configuration
param vmCredentials = {
  adminUsername: '<YOUR VM ADMIN USERNAME>'
  adminPassword: '<YOUR VM ADMIN PASSWORD>'
}

param vmConfig = {
  computeName: 'winvmssms1'
  imageReference: {
    offer: 'WindowsServer'
    publisher: 'MicrosoftWindowsServer'
    sku: '2025-datacenter-azure-edition'
    version: 'latest'
  }
  osDisk: {
    caching: 'ReadWrite'
    createOption: 'FromImage'
    diskSizeGB: 128
    deleteOption: 'Delete'
    managedDisk: {
      storageAccountType: 'StandardSSD_LRS'
    }
  }
  osType: 'Windows'
  vmSize: 'Standard_D2d_v5'
  encryptionAtHost: false
  secureBootEnabled: true
  vtpmEnabled: true
  availabilityZone: -1
  autoShutdownConfig: {
    dailyRecurrenceTime: '17:00'
    status: 'Enabled'
    timeZone: 'Eastern Standard Time'
  }
}
