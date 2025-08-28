import os
import logging

class Appsetings:
    def __init__(self):
        # Core environment settings
        self.environment = os.getenv("ENVIRONMENT", "dev").lower()
        self.resource_group = os.getenv("RESOURCE_GROUP_NAME", f"rg-{self.environment}")
        self.target_resource_group = os.getenv("TARGET_RESOURCE_GROUP", "")
        self.cluster_name = os.getenv("CLUSTER_NAME", f"aks-{self.environment}")
        self.subscription_id = os.getenv("AZURE_SUBSCRIPTION_ID")
        self.region = os.getenv("REGION", "eastus")  # Region for disks & snapshots
        self.aks_audience = os.getenv(
            "AKS_AUDIENCE", "6dae42f8-4368-4678-94ff-3960e28e3630/.default"
        )
        # Optional User Assigned Managed Identity
        self.user_assigned_identity_client_id = os.getenv("USER_ASSIGNED_IDENTITY_CLIENT_ID")

        # Qdrant-specific configuration
        self.qdrant_pv_pattern = os.getenv("QDRANT_PV_PATTERN", "qdrant")
        self.k8s_namespace = os.getenv("K8S_NAMESPACE", "default")

    def validate(self):
        """Validate required configuration values."""
        if not self.resource_group:
            raise ValueError("RESOURCE_GROUP must be provided")
        if not self.target_resource_group:
            raise ValueError("TARGET_RESOURCE_GROUP must be provided")
        if not self.subscription_id:
            raise ValueError("AZURE_SUBSCRIPTION_ID must be provided")
        if not self.k8s_namespace:
            raise ValueError("K8S_NAMESPACE must be provided")
        if not self.region:
            raise ValueError("REGION must be provided")
        if not self.aks_audience:
            raise ValueError("AKS_AUDIENCE must be provided")

        logging.info(
            f"Config validated: env={self.environment}, RG={self.resource_group}, TRG={self.target_resource_group}, "
            f"sub={self.subscription_id}, ns={self.k8s_namespace}, region={self.region}, "
            f"aks_audience={self.aks_audience}, user_identity_client_id={self.user_assigned_identity_client_id}"
        )
