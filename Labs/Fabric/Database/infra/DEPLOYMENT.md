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

### Step 3: Install SSMS on VM

1. **Inside the VM**, download SQL Server Management Studio:
   - Open Edge browser and navigate to: [SSMS Download](https://learn.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms)
   - Click "Download SSMS" and run the installer

2. **Install SSMS**:
   - Accept default options
   - Complete the installation (~5 minutes)

3. **Launch SSMS**:
   - When prompted, connect using your Entra ID user
   - Select "Work or School account" when asked

4. **Verify connection to SQL Server**:
   - Server name: `sql-k12-fabric-lab-<unique-suffix>.database.windows.net`
   - Authentication: **Entra ID - Universal with MFA**
   - Database: `sqldb-k12-fabric-lab-<unique-suffix>`
   - **NOTE:** Use your Entra ID account (no SQL password needed)

---

### Step 4: Import K12_Schema.sql into SQL Database

1. **In SSMS**, connect to your database (if not already connected)

2. **Open `K12_Schema.sql`**:
   - File → Open → Recent Files
   - Or navigate to your local `K12_Schema.sql` file
   - Copy the SQL script content

3. **Execute the schema creation**:
   - Paste the SQL into SSMS query window
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

1. **Copy sample data to VM**:
   - From your local machine, copy the `sample_data/` folder (contains 48 CSV files: 8 base tables + 20 Attendance_School_*.csv + 20 GradeAssessments_School_*.csv)
   - Paste to VM at a known location (e.g., `C:\Data\sample_data\`)

2. **Open `K12_BulkInsert.sql`** in SSMS:
   - File → Open → Recent Files
   - Or navigate to your local `K12_BulkInsert.sql` file
   - Copy the SQL script content

3. **Edit the file path** (if needed):
   - Replace `C:\Data\sample_data\` with your actual CSV folder path on the VM
   - **NOTE:** The script uses dynamic SQL loops to automatically load all 20 Attendance_School_*.csv and GradeAssessments_School_*.csv files. Ensure all split files are in the same folder.
   - Skip this step if you used `C:\Data\sample_data\` exactly

4. **Execute the bulk insert**:
   - Paste the SQL into SSMS query window
   - Click "Execute" (or press F5)
   - Monitor the status messages (expect 5+ million records for Attendance alone)
   - The script includes a verification query that runs automatically

5. **Verify data load** (output from verification query):
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
