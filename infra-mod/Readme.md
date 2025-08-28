# debug
## install virtual env
python -m venv .venv
## activate
source .venv/bin/activate
## install dependency
pip install -r requirements.txt

# Flujo recomendado

Si no esta declarado un output necesario, hay que hacer primero output de el y luego el plan y apply de ese mismo folder.
ejemplo del folder 0 que crea los resource group

Bootstrap (opcional si solo defines provider/vars):

terraform plan   --var-file=/mnt/d/Terraform/helm-azuredevops/infra-mod/2-platform/envs/dev/eastus/terraform.tfvars

terraform apply --auto-approve   terraform plan --var-file=/mnt/d/Terraform/helm-azuredevops/infra-mod/2-platform/envs/dev/eastus/terraform.tfvars

cd 0-bootstrap/envs/dev/eastus
terraform init  \
  -backend-config="../../../../0-bootstrap/envs/dev/eastus/backend.tf"
terraform plan \
  --var-file=/mnt/d/Terraform/helm-azuredevops/infra-mod/2-platform/envs/dev/eastus/terraform.tfvars


Red (Network):

cd 1-network/envs/dev/eastus
terraform init
terraform plan  \
  --var-file=/mnt/d/Terraform/helm-azuredevops/infra-mod/2-platform/envs/dev/eastus/terraform.tfvars

terraform apply  \
  --var-file=/mnt/d/Terraform/helm-azuredevops/infra-mod/2-platform/envs/dev/eastus/terraform.tfvars



Esto creará la VNet + subnets.
Sus outputs.tf deberían exportar algo como:

output "subnet_ids" {
  value = {
    aks      = azurerm_subnet.subnet_aks.id
    function = azurerm_subnet.subnet_function.id
  }
}


Platform (AKS + Function):

cd 2-platform/envs/dev/eastus
terraform init
terraform plan \
  --var-file=/mnt/d/Terraform/helm-azuredevops/infra-mod/2-platform/envs/dev/eastus/terraform.tfvars

terraform apply  \
  --var-file=/mnt/d/Terraform/helm-azuredevops/infra-mod/2-platform/envs/dev/eastus/terraform.tfvars
