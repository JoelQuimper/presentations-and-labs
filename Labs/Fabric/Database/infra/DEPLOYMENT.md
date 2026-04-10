# K12 Fabric Lab Infrastructure - Deployment Guide

## Overview

This infrastructure deploys a secure, isolated K12 education lab environment with:
- **Azure SQL Database** (no public endpoints)
- **Virtual Network** with private subnets
- **Windows VM** pre-configured for SSMS
- **Private Endpoints** for all connections
- All resources built with **Azure Verified Modules (AVM)**

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Virtual Network: 10.0.0.0/16                               │
│                                                             │
│  ┌────────────────────┐         ┌────────────────────┐      │
│  │  SQL Subnet        │         │  VM Subnet         │      │
│  │  10.0.1.0/24       │         │  10.0.2.0/24       │      │
│  │                    │         │                    │      │
│  │  SQL Server (PEP)  │         │  Windows VM (SSMS) │      │
│  │  (No Public IP)    │◄────────│  Private RDP       │      │
│  │                    │         │                    │      │
│  └────────────────────┘         └────────────────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓                 
                     Private DNS Zone                        
             privatelink.database.windows.net                
```

## Prerequisites

1. **Azure CLI** installed ([Download](https://aka.ms/azure-cli))
2. **Bicep CLI** installed (`az bicep install`)
3. **Azure subscription** with permissions to create resources, ideally with Owner role.
4. **Entra ID access** - The lab is based around your identity, get your user object ID:
   ```bash
   az ad signed-in-user show --query id
   ```
5. **No pre-created resource group needed** - it will be created automatically

## Deployment Workflow

### Step 1: Deploy the Infrastructure

#### 1.1 Update Parameters

Copy `main.template.bicepparam` to `main.bicepparam` and edit the latter with your configuration:
1. Update the `uniqueSuffix` to ensure globally unique resource names (e.g., `jq-013`)
2. Set strong passwords for VM administrator in `vmCredentials`
3. Fill in your Entra ID user details for SQL admin configuration:
   - `login`: Your Entra ID account (e.g., `user@tenant.onmicrosoft.com`)
   - `sid`: Your user object ID from the id you retrieved in the prerequisites step

**Key Settings:**
- **Entra ID Auth Only**: No SQL password authentication
- **Auto Shutdown**: VM shuts down daily at 5 PM EST to reduce costs
- **Windows Server 2025**: Latest Azure Edition with security features
- **ServerlessSQL**: Database auto-pauses after 30 minutes of inactivity (reduces costs)

#### 1.2 Deploy Infrastructure

Run the deployment script:

```powershell
.\deploy.ps1 -Location eastus
```

The script handles:
- Creating the subscription-level deployment
- Using your `main.bicepparam` configuration
- Displaying deployment outputs automatically
- Error handling and status reporting

**Expected deployment time:** 10-15 minutes

Alternatively, if you prefer using Azure CLI directly:

```bash
az deployment sub create \
  --name k12lab-deployment \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --location eastus
```

**Note the resource names for the next steps:**
- SQL Server: `sql-k12-fabric-lab-<unique-suffix>.database.windows.net`
- VM: `vm-k12-fabric-lab-<unique-suffix>`
- Resource Group: `rg-k12-fabric-lab-<unique-suffix>`

---

### Step 2: Connect VM via Bastion RDP

1. **Navigate to your VM** in Azure Portal:
   - Resource Group: `rg-k12-fabric-lab-<unique-suffix>`
   - VM Name: `vm-k12-fabric-lab-<unique-suffix>`

2. **Click "Connect via Bastion"**:
   - Select "Open in new tab"
   - Username: (from `vmCredentials.adminUsername`)
   - Password: (from `vmCredentials.adminPassword`)
   - **NOTE:** Watch out for popup blockers when opening the Bastion session.

3. **Verify connectivity**:
   - You should see the Windows desktop
   - Bastion session will remain open for your entire configuration

---

### Step 3: Verify VM Initialization and SSMS Installation

The VM is automatically configured during deployment with two phases:
- **Phase 1**: Chocolatey, Git, and repository cloning (~1 minute)
- **Phase 2**: SSMS installation via scheduled task (~10 minutes)

#### 3.1 Check Setup Logs

1. **Open File Explorer** on the VM
2. **Navigate to**: `C:\Logs\`
3. **Review the following log files**:
   - `initialize-vm.log` - Phase 1 setup (Chocolatey, Git, repo clone)
   - `install-development-tools.log` - Phase 2 setup (SSMS installation)

4. **Verify successful completion**:
   - Look for entries like:
     - `"Git installation completed"`
     - `"Repository cloned to C:\repos\presentations-and-labs"`
     - `"SSMS installation completed successfully"`

#### 3.2 Verify SSMS is Installed

1. **Search for SSMS** in the Start menu
2. **Launch SQL Server Management Studio**
3. **Verify connection to SQL Server**:
   - Server name: `sql-k12-fabric-lab-<unique-suffix>.database.windows.net`
   - Authentication: **Entra ID - Universal with MFA**
   - Database: `sqldb-k12-fabric-lab-<unique-suffix>`
   - Click "Connect"
   - **NOTE:** Use your Entra ID account (no SQL password needed)

#### 3.3 Verify Repository is Cloned

1. **Open File Explorer**
2. **Navigate to**: `C:\repos\presentations-and-labs\`
3. **Confirm the following folders exist**:
   - `Labs/Fabric/Database/` - Contains schema and bulk load scripts
   - `Labs/Fabric/Database/SampleData/` - Contains CSV data files

---

### Step 4: Import K12_Schema.sql into SQL Database

1. **In SSMS**, connect to your database (if not already connected)

2. **Open `K12_Schema.sql`**:
   - File → Open → File
   - Navigate to: `C:\repos\presentations-and-labs\Labs\Fabric\Database\K12_Schema.sql`
   - The file will open in the query window

3. **Execute the schema creation**:
   - Click "Execute" (or press F5)
   - You should see 10 tables created:
     - Schools, GradeLevels, Teachers, Classes
     - Students, Enrollment, Attendance
     - GradeAssessments, StudentSuccessMetrics, StudentInterventions

4. **Verify table creation**:
   - Expand "Tables" in Object Explorer
   - Confirm all 10 tables are present

---

### Step 5: Bulk Insert Sample Data from CSVs

1. **Open `K12_BulkInsert.sql`** in SSMS:
   - File → Open → File
   - Navigate to: `C:\repos\presentations-and-labs\Labs\Fabric\Database\K12_BulkInsert.sql`
   - The file will open in the query window

2. **Update the file path in the script** (if needed):
   - Search for the variable `@dataPath` at the top of the script
   - The default path is: `C:\repos\presentations-and-labs\Labs\Fabric\Database\SampleData\`
   - **NOTE:** The script uses dynamic SQL loops to automatically load all 20 Attendance_School_*.csv and GradeAssessments_School_*.csv files. Ensure all CSV files are in this folder.
   - If the path is correct, proceed without changes

3. **Execute the bulk insert**:
   - Click "Execute" (or press F5)
   - Monitor the status messages (expect 5+ million records for Attendance alone)
   - The script includes a verification query that runs automatically

4. **Verify data load** (output from verification query):
   - Check the results window for record counts
   - Confirm they match expected results below

**Expected Results:**

| Table | Record Count |
|-------|---------------|
| Schools | 20 |
| Teachers | 406 |
| Students | 8,356 |
| Classes | 423 |
| Enrollment | 51,624 |
| Attendance | 5,040,035 |
| GradeAssessments | 1,031,326 |
| StudentSuccessMetrics | 103,248 |
| StudentInterventions | 2,518 |

---

---

## Cleanup

To delete all resources:

```bash
az group delete \
  --name rg-k12-fabric-lab-<your-unique-suffix> \
  --yes --no-wait
```

**Note:** Use the same resource group name pattern you specified in `main.bicepparam`

---

## References

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure SQL Private Endpoints](https://learn.microsoft.com/azure/azure-sql/database/private-endpoint-overview)
