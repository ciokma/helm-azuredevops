# Imagen base oficial de Azure CLI (trae bash y Python)
FROM mcr.microsoft.com/azure-cli:latest
ENV ENVIRONMENT=dev
ENV TARGET_RESOURCE_GROUP=rg-qdrant-snapshot-pv

# Instalar kubectl
RUN az aks install-cli

# Evitar telemetría
ENV AZURE_CLI_DISABLE_TELEMETRY=1

# Copiar scripts
WORKDIR /app
COPY handler.sh /app/handler.sh
COPY host.sh /app/host.sh
RUN chmod +x /app/handler.sh /app/host.sh

EXPOSE 80

ENTRYPOINT ["/app/host.sh"]
