#!/bin/bash
set -euo pipefail

# Responder rápido a Functions
cat <<EOF
{
  "Outputs": {
    "res": {
      "statusCode": 202,
      "body": "Snapshot triggered"
    }
  },
  "Logs": ["Request received, starting snapshot"]
}
EOF