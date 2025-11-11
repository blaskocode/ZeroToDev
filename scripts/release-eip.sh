#!/bin/bash
# Script to safely release an Elastic IP address

set -e

EIP_ALLOCATION_ID="${1}"

if [ -z "$EIP_ALLOCATION_ID" ]; then
  echo "Usage: $0 <EIP_ALLOCATION_ID>"
  echo ""
  echo "Example: $0 eipalloc-0a690a416920f71c1"
  echo ""
  echo "First, list your EIPs:"
  echo "  aws ec2 describe-addresses --query 'Addresses[*].[PublicIp,AllocationId,AssociationId,InstanceId,Tags[?Key==\`Name\`].Value|[0]]' --output table"
  exit 1
fi

echo "=== Checking EIP Status ==="
EIP_INFO=$(aws ec2 describe-addresses --allocation-ids "$EIP_ALLOCATION_ID" --query 'Addresses[0]' --output json)

PUBLIC_IP=$(echo "$EIP_INFO" | jq -r '.PublicIp')
ASSOCIATION_ID=$(echo "$EIP_INFO" | jq -r '.AssociationId // "None"')
INSTANCE_ID=$(echo "$EIP_INFO" | jq -r '.InstanceId // "None"')
NETWORK_INTERFACE_ID=$(echo "$EIP_INFO" | jq -r '.NetworkInterfaceId // "None"')
TAG_NAME=$(echo "$EIP_INFO" | jq -r '.Tags[]? | select(.Key=="Name") | .Value // "None"')

echo "Public IP: $PUBLIC_IP"
echo "Allocation ID: $EIP_ALLOCATION_ID"
echo "Association ID: $ASSOCIATION_ID"
echo "Instance ID: $INSTANCE_ID"
echo "Network Interface: $NETWORK_INTERFACE_ID"
echo "Tag Name: $TAG_NAME"
echo ""

if [ "$ASSOCIATION_ID" != "None" ] && [ "$ASSOCIATION_ID" != "null" ]; then
  echo "⚠️  WARNING: This EIP is currently associated with a resource!"
  echo ""
  echo "You must disassociate it first before releasing:"
  echo "  aws ec2 disassociate-address --association-id $ASSOCIATION_ID"
  echo ""
  echo "Or if it's associated with a NAT Gateway, delete the NAT Gateway first:"
  echo "  aws ec2 describe-nat-gateways --filter \"Name=state,Values=available,pending\""
  echo ""
  read -p "Do you want to disassociate this EIP? (yes/no): " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 1
  fi
  
  echo "Disassociating EIP..."
  aws ec2 disassociate-address --association-id "$ASSOCIATION_ID"
  echo "✓ Disassociated successfully"
  echo ""
  echo "Waiting 5 seconds for AWS to process..."
  sleep 5
fi

echo "=== Releasing EIP ==="
read -p "Are you sure you want to release EIP $PUBLIC_IP ($EIP_ALLOCATION_ID)? This cannot be undone! (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

echo "Releasing EIP..."
aws ec2 release-address --allocation-id "$EIP_ALLOCATION_ID"

echo ""
echo "✓ EIP $PUBLIC_IP ($EIP_ALLOCATION_ID) has been released successfully!"
echo ""
echo "You can verify with:"
echo "  aws ec2 describe-addresses --allocation-ids $EIP_ALLOCATION_ID"

