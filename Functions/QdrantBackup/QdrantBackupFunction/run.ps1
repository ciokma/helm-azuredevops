<#
.SYNOPSIS
This script automates the process of creating an Azure Disk snapshot from a Kubernetes Persistent Volume.
It is designed to run as an Azure Function with a timer trigger.

.DESCRIPTION
The script performs the following actions:
1. Retrieves the environment and target resource group from a JSON configuration file.
2. Validates the provided environment and target resource group.
3. Logs into Azure using managed identity.
4. Retrieves credentials for the specified AKS cluster.
5. Finds the disk URI associated with the 'qdrant' persistent volume.
6. Creates a disk snapshot with a unique name and tags in the target resource group.
7. Measures and reports the total execution time.

.PARAMETER Timer
The timer object passed by the Azure Functions runtime.
#>

# Input bindings are passed in via param block.
param($Timer)

# A hashtable in PowerShell is the equivalent of a Bash associative array.
$SUBSCRIPTION = @{
    "dev"  = "f9703f5b-83a3-4d1e-9872-e4b59e50de6e"
    "stg"  = ""
    "uat"  = ""
    "prod" = ""
}

# --- Function Definitions ---

function Get-ByClaimRef {
    param (
        [string]$Search
    )

    # Use ConvertFrom-Json to parse the kubectl output.
    # The Where-Object cmdlet is used for filtering.
    $Result = kubectl get pv -n default -o json | ConvertFrom-Json

    $Result.items | Where-Object {
        $_.spec.claimRef.name -like "*$Search*" -and $_.spec.claimRef.namespace -eq "default"
    }
}

function Get-VolumeOrDisk {
    param (
        [string]$Search
    )
    
    $Result = Get-ByClaimRef -Search $Search

    # Use built-in object properties to check for keys instead of jq.
    if ($Result.spec.azureDisk) {
        Write-Output $Result.spec.azureDisk.diskURI
    } elseif ($Result.spec.csi) {
        Write-Output $Result.spec.csi.volumeHandle
    }
}

function Delete-KubeContexts {
    # Define an array.
    $CLUSTERS = @(
        "aks-dev"
    )

    # Loop through the array. | Out-Null suppresses command output.
    foreach ($Context in $CLUSTERS) {
        Write-Host "Deleting Kubernetes context: $Context"
        kubectl config delete-context $Context -ErrorAction SilentlyContinue | Out-Null
    }
}

function Get-SnapshotUri {
    param (
        [string]$Environment
    )
    
    $SubscriptionId = $SUBSCRIPTION[$Environment.ToLower()]
    if ([string]::IsNullOrEmpty($SubscriptionId)) {
        throw "Error: Subscription ID is empty for environment '$Environment'."
    }
    
    # Authenticate to the Azure account.
    Write-Host "Logging in to Azure..."
    az login --identity | Out-Null
    az account set --subscription $SubscriptionId | Out-Null
    
    # Get AKS credentials.
    Write-Host "Getting AKS credentials for aks-$Environment..."
    Delete-KubeContexts
    az aks get-credentials `
        --resource-group "rg-$Environment" `
        --name "aks-$Environment" `
        --admin `
        --overwrite-existing | Out-Null

    # Get the disk URI.
    Get-VolumeOrDisk -Search "qdrant"
}

function Validate-Parameters {
    param (
        [string]$Environment,
        [string]$TargetResourceGroup
    )
    
    # Check if the environment value is valid using a switch statement.
    $ValidEnvironments = "DEV", "STG", "UAT", "PROD"
    if ($ValidEnvironments -notcontains $Environment.ToUpper()) {
        throw "Error: Invalid environment specified. Please specify 'dev', 'stg', 'uat', or 'prod'."
    }

    # Check if the resource group exists.
    # The `az` command returns `True` or `False`.
    $GroupExists = az group exists --name $TargetResourceGroup
    if (-not $GroupExists) {
        throw "Error: The specified resource group '$TargetResourceGroup' does not exist."
    }
}

function New-Snapshot {
    param (
        [string]$DiskUri,
        [string]$Environment,
        [string]$TargetResourceGroup
    )
    
    # Use Get-Date to format the snapshot name.
    $DiskName = Split-Path -Path $DiskUri -Leaf
    $SnapshotName = "${DiskName}-snapshot-$(Get-Date -UFormat '%Y%m%d%H%M')"

    # Use Get-Date and New-TimeSpan to calculate execution time.
    $StartTime = Get-Date
    Write-Host "Start time: $StartTime"
    Write-Host "Creating snapshot with name: $SnapshotName"
    Write-Host "Source disk URI: $DiskUri"
    Write-Host "Target resource group: $TargetResourceGroup"

    # Define tags as a hashtable.
    $Tags = @{
        "createdBy" = "qdrant_volume_snapshot.ps1"
        "env"       = $Environment
        "timestamp" = (Get-Date -UFormat "%Y-%m-%dT%H:%M:%SZ")
    }

    # Use a try/catch block for error handling.
    try {
        az snapshot create `
            --resource-group $TargetResourceGroup `
            --name $SnapshotName `
            --source $DiskUri `
            --incremental false `
            --tags $Tags `
            | Out-Null

        $EndTime = Get-Date
        $Duration = (New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds

        Write-Host ""
        Write-Host "Snapshot created in $Environment: $SnapshotName"
        Write-Host "Total execution time in $Environment: $Duration seconds"
    } catch {
        Write-Error "Error creating snapshot from $DiskUri."
        throw $_
    }
}

# --- Main Script Execution ---

try {
    # Get parameters from a JSON file in the same directory as the function.
    $ConfigFile = "$PSScriptRoot\config.json"
    if (-not (Test-Path $ConfigFile)) {
        throw "Error: Configuration file not found at '$ConfigFile'."
    }

    $Config = Get-Content $ConfigFile | ConvertFrom-Json
    $Environment = $Config.Environment
    $TargetResourceGroup = $Config.TargetResourceGroup

    if ($Timer.IsPastDue) {
        Write-Host "PowerShell timer is running late!"
    }
    
    # Write an information log with the current time.
    $currentUTCtime = (Get-Date).ToUniversalTime()
    Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

    Validate-Parameters -Environment $Environment -TargetResourceGroup $TargetResourceGroup
    
    $DiskUri = Get-SnapshotUri -Environment $Environment
    
    if ([string]::IsNullOrEmpty($DiskUri)) {
        Write-Host "No disk URI found. Exiting."
    } else {
        New-Snapshot -DiskUri $DiskUri -Environment $Environment -TargetResourceGroup $TargetResourceGroup
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}