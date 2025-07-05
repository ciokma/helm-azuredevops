# ✅ ¿Cómo usar para crear un cluster por separado?
# Inicializar
Desde la carpeta terraform/us/ o terraform/eu/:

## bash
terraform init

## bash
terraform apply -var-file="terraform.tfvars"

# Como usar para crear ambos cluster a la vez
terraform init
terraform apply -var-file="terraform.tfvars"

# Others
az login --use-device-code
az account set --subscription "id"

# 1. Inicia el entorno de Terraform
terraform init

# 2. Revisa lo que se va a crear
terraform plan

# 3. Aplica los cambios
terraform apply