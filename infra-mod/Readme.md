# Qdrant Backup Function on Azure

This project provides an **Azure Function** that automates the backup of **Qdrant Persistent Volumes (PV)** running in an AKS cluster.  
The function is deployed with Terraform and integrates with Azure Monitor, Application Insights, and a user-assigned Managed Identity for secure access.

---

## 🚀 Key Features
- Automates **Qdrant PVC snapshots** on AKS.
- Runs on a **cron schedule** (configurable via environment variable).
- Secured with **Managed Identity** (no secrets in code).
- Deployed into an existing VNet (optional).
- Monitored with **Azure Application Insights**.

---

## 📂 Project Structure
- `infra/` → Terraform code for provisioning resources:
  - **Resource Groups**
  - **Networking (VNet + Subnets)**
  - **AKS Cluster**
  - **Azure Function App**
- `function/` → Python source code for the Azure Function.

---

## 🛠 Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Python 3.9+
- Access to an **Azure Subscription**

---

## ⚙️ Environment Variables
The Azure Function requires the following variables:

| Variable | Description |
|----------|-------------|
| `AzureWebJobsStorage` | Storage Account connection string for the Function runtime. |
| `AZURE_CLIENT_ID` | Client ID of the user-assigned Managed Identity. |
| `AZURE_TENANT_ID` | Azure AD Tenant ID. |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID. |
| `LOCATION` | Azure region (e.g., `eastus`). |
| `CLUSTER_NAME` | AKS cluster name. |
| `RESOURCE_GROUP_NAME` | Resource group for AKS cluster. |
| `TARGET_RESOURCE_GROUP` | Resource group for storing Qdrant snapshots. |
| `ENVIRONMENT` | Environment name (`dev`, `staging`, `prod`). |
| `QDRANT_PV_PATTERN` | PVC name pattern to match (e.g., `qdrant-pvc`). |
| `QDRANT_NAMESPACE` | Kubernetes namespace where Qdrant runs. |
| `CRON_SCHEDULE` | Cron expression for backup frequency. |
| `AKS_AUDIENCE` | Audience used to request AAD tokens for AKS API. |
| `APPINSIGHTS_INSTRUMENTATIONKEY` | Application Insights instrumentation key. |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Application Insights connection string. |

---

## 🧪 Local Development
You can run the Azure Function locally for debugging.

```bash
# 1. Create a virtual environment
python -m venv .venv
source .venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the function locally
func start


## 🧪 Example to run Terraform Code
### 1. Bootstrap (Resource Groups & Backend)
```bash
cd 0-bootstrap/envs/dev/eastus
terraform init -backend-config=backend.tf
terraform plan   --var-file=terraform.tfvars
terraform apply  --var-file=terraform.tfvars

### 2. Networking (VNet + Subnets)
```bash
cd 1-network/envs/dev/eastus
terraform init
terraform apply --var-file=terraform.tfvars

### 3. Platform (AKS + Azure Function)
```bash
cd 2-platform/envs/dev/eastus
terraform init
terraform apply --var-file=terraform.tfvars

## Important Note
This deploys:
- The AKS cluster
- The Function App
- App Insights monitoring

## 📌 Important Notes

- Ensure the Managed Identity has the required RBAC roles on the target AKS and Resource Group.
- The CRON_SCHEDULE must follow [Azure Function CRON syntax](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-timer?tabs=python-v2%2Cisolated-process%2Cnodejs-v4&utm_source=chatgpt.com&pivots=programming-language-csharp#ncrontab-expressions)
- If deploying inside a VNet, ensure correct subnet delegation.