## Lab guide
In this lab, we will explore how to use Managed Identities in Azure with on-premise servers onboarded to Azure Arc to securely access resources without the need for credentials. This lab will guide you through the process of :
- onboarding the server
- creating a Key Vault
- assigning it permissions
- using it to access a secret from the on-prem server using its Managed Identity.

### Onboarding the server to Azure Arc
1. You will need an on-premise server or a VM either running on-prem or in the cloud (AWS, ...) that you can onboard to Azure Arc.  For this lab, we will be using a Windows Server 2025 VM.
2. Onboard the server to Azure Arc by following the instructions in this document : [Connect Windows Server machines to Azure through Azure Arc Setup](https://learn.microsoft.com/en-us/azure/azure-arc/servers/onboard-windows-server).

### Create an Azure Key Vault and assign permissions to the server's Managed Identity
1. In the Azure portal, create a new Key Vault in the same region as your Arc server. You can follow this guide to create a Key Vault : [Create an Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/quick-create-portal).
2. In the **Access configuration** section of the Key Vault creation, make sure **Azure role-based access control (recommended)** is selected. 
3. Once the Key Vault is created, navigate to the Key Vault resource and go to the **Access control (IAM)** section.
4. Click on **Add role assignment**.
5. Select the **Key Vault Secrets User** role and click next.
6. Select **Managed identity** as the type of principal, then click on the **Select members** blue link.
7. Select the subscription and resource group where your Arc server is located, and finally select the Arc server itself. Click on **Save** to assign the role to the server's Managed Identity. 
![AddRole](image.png)

