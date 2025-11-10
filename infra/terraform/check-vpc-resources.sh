#!/bin/bash
# Script to check VPC resources before deletion

VPC_ID="${1:-}"

if [ -z "$VPC_ID" ]; then
  echo "Usage: $0 <vpc-id>"
  echo "Example: $0 vpc-024b70e550cf81f27"
  exit 1
fi

echo "Checking resources in VPC: $VPC_ID"
echo "=================================="
echo ""

# Check subnets
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text)
if [ -n "$SUBNETS" ]; then
  echo "⚠️  Subnets found:"
  aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].[SubnetId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table
  echo ""
else
  echo "✅ No subnets"
  echo ""
fi

# Check Internet Gateways
IGWS=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[*].InternetGatewayId' --output text)
if [ -n "$IGWS" ]; then
  echo "⚠️  Internet Gateways found:"
  aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[*].[InternetGatewayId,Tags[?Key==`Name`].Value|[0]]' --output table
  echo ""
else
  echo "✅ No Internet Gateways"
  echo ""
fi

# Check NAT Gateways
NAT_GWS=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query 'NatGateways[?State==`available`].NatGatewayId' --output text)
if [ -n "$NAT_GWS" ]; then
  echo "⚠️  NAT Gateways found:"
  aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query 'NatGateways[*].[NatGatewayId,SubnetId,State]' --output table
  echo ""
else
  echo "✅ No NAT Gateways"
  echo ""
fi

# Check Security Groups (excluding default)
SG_COUNT=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=!default" --query 'length(SecurityGroups)' --output text)
if [ "$SG_COUNT" -gt 0 ]; then
  echo "⚠️  Security Groups found (excluding default): $SG_COUNT"
  aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=!default" --query 'SecurityGroups[*].[GroupId,GroupName,Description]' --output table | head -10
  echo ""
else
  echo "✅ No custom Security Groups"
  echo ""
fi

# Check Route Tables (excluding main)
RT_COUNT=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" "Name=association.main,Values=false" --query 'length(RouteTables)' --output text)
if [ "$RT_COUNT" -gt 0 ]; then
  echo "⚠️  Route Tables found (excluding main): $RT_COUNT"
  aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" "Name=association.main,Values=false" --query 'RouteTables[*].[RouteTableId,Tags[?Key==`Name`].Value|[0]]' --output table
  echo ""
else
  echo "✅ No custom Route Tables"
  echo ""
fi

# Check VPC Endpoints
ENDPOINTS=$(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID" --query 'VpcEndpoints[*].VpcEndpointId' --output text)
if [ -n "$ENDPOINTS" ]; then
  echo "⚠️  VPC Endpoints found:"
  aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID" --query 'VpcEndpoints[*].[VpcEndpointId,VpcEndpointType,ServiceName]' --output table
  echo ""
else
  echo "✅ No VPC Endpoints"
  echo ""
fi

# Check Network Interfaces
ENI_COUNT=$(aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$VPC_ID" --query 'length(NetworkInterfaces)' --output text)
if [ "$ENI_COUNT" -gt 0 ]; then
  echo "⚠️  Network Interfaces found: $ENI_COUNT"
  echo ""
else
  echo "✅ No Network Interfaces"
  echo ""
fi

echo "=================================="
echo "Summary:"
if [ -z "$SUBNETS" ] && [ -z "$IGWS" ] && [ -z "$NAT_GWS" ] && [ "$SG_COUNT" -eq 0 ] && [ "$RT_COUNT" -eq 0 ] && [ -z "$ENDPOINTS" ] && [ "$ENI_COUNT" -eq 0 ]; then
  echo "✅ VPC appears safe to delete (no resources found)"
else
  echo "⚠️  VPC has resources - deletion requires cleanup first"
fi

