  az aks command invoke \
    --resource-group "rg-dev" \
    --name "aks-dev" \
    --command "kubectl get pv -n default -o json" \
    -o json # | jq -r '.logs'