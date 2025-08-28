infrastructure
├── 0-bootstrap
│   └── envs
│       └── dev/eastus
│           └── providers.tf
│
├── 1-network
│   └── envs
│       └── dev/eastus
│           └── main.tf         # Calls vnet module
│
├── 2-platform
│   └── envs
│       ├── dev/eastus
│       │   ├── aks.tf
│       │   ├── function_qdrant.tf
│       │   ├── terraform.tfvars
│       │   └── variables.tf
│       └── stg/eastus
│           ├── aks.tf
│           ├── function_qdrant.tf
│           ├── terraform.tfvars
│           └── variables.tf
│
└── modules
    ├── vnet/v1.0
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── aks/v1.0
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── function_qdrant_backup/v1.0
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
        
mkdir -p infrastructure/{0-bootstrap/envs/dev/eastus,1-network/envs/dev/eastus,2-platform/envs/{dev,stg}/eastus,modules/{vnet/v1.0,aks/v1.0,function_qdrant_backup/v1.0}}

# Archivos bootstrap
touch infrastructure/0-bootstrap/envs/dev/eastus/providers.tf

# Archivos network
touch infrastructure/1-network/envs/dev/eastus/main.tf

# Archivos platform dev
touch infrastructure/2-platform/envs/dev/eastus/{aks.tf,function_qdrant.tf,terraform.tfvars,variables.tf}

# Archivos platform stg
touch infrastructure/2-platform/envs/stg/eastus/{aks.tf,function_qdrant.tf,terraform.tfvars,variables.tf}

# Archivos módulos
touch infrastructure/modules/vnet/v1.0/{main.tf,variables.tf,outputs.tf}
touch infrastructure/modules/aks/v1.0/{main.tf,variables.tf,outputs.tf}
touch infrastructure/modules/function_qdrant_backup/v1.0/{main.tf,variables.tf,outputs.tf}
