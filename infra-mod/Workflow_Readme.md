# Azure Function for Qdrant Backup on AKS

This guide explains how to deploy an **Azure Function in Python** that connects to an **AKS cluster inside a VNet** and accesses **Persistent Volumes (PVs)** to perform Qdrant backups.

---

## 🚀 Step-by-Step Flow

### 1. Networking
- Create a **new subnet** inside the AKS VNet (**do not reuse the AKS subnet**).
- The **Azure Function** will be deployed in this subnet.

### 2. Create the Azure Function
- Deploy an **Azure Function in Python**.
- Configure it to run in the **same VNet as the AKS cluster**, but in a **different subnet**.

### 3. Managed Identity
- Create a **User Managed Identity (UMI)**.
- Assign the UMI to the **Azure Function**.

### 4. Assign Required Roles
Grant the UMI the following roles to access the AKS cluster:

- `Azure Kubernetes Service Cluster User Role`
- `Azure Kubernetes Service Cluster Admin`

### 5. Contributor Permissions
The UMI also needs **Contributor** access on:
- The **Resource Group** that contains the AKS cluster.
- The **target Resource Group** where Qdrant backups will be stored.

### 6. Kubernetes RBAC
Manually create a **ClusterRole** and **ClusterRoleBinding** so the Azure Function can read nodes and Persistent Volumes inside the cluster.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: azure-function-node-pv-reader
rules:
- apiGroups: [""]
  resources: ["nodes", "persistentvolumes"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: azure-function-node-pv-reader-binding
subjects:
- kind: User
  # ⚠️ IMPORTANT: Replace with the Object ID of the Managed Identity
  name: ""
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: azure-function-node-pv-reader
  apiGroup: rbac.authorization.k8s.io
