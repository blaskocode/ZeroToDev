#!/bin/bash
# Quick script to check and release Terraform state locks

echo "Checking for Terraform state locks..."
echo ""

# Try to get lock info (this will fail if there's a lock)
cd "$(dirname "$0")"
terraform plan -lock=false -refresh=false -out=/dev/null 2>&1 | grep -i "lock" || echo "No active lock detected"

echo ""
echo "If you see a lock ID above, run:"
echo "  terraform force-unlock -force <LOCK_ID>"
echo ""
echo "To check for locks in DynamoDB directly:"
echo "  aws dynamodb scan --table-name zero-to-dev-terraform-locks"

