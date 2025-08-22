#!/bin/bash
set -euo pipefail

echo "[$(date)] Snapshot triggered" >> snapshot.log

# Aquí va tu lógica real de snapshot
# Ejemplo: ./snapshot_command --env dev --target-rg rg-qdrant-snapshot-pv

echo "[$(date)] Snapshot completed" >> snapshot.log
