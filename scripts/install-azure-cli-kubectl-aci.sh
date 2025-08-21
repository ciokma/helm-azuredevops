
# Importar la clave de Microsoft
rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Agregar el repositorio de Azure CLI
tee /etc/yum.repos.d/azure-cli.repo <<EOF
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Instalar Azure CLI
tdnf install -y azure-cli


# Descargar la versión más reciente de kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Dar permisos de ejecución
chmod +x kubectl

# Moverlo a un directorio en PATH
mv kubectl /usr/local/bin/

# Verificar
kubectl version --client
