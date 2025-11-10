#!/bin/bash
# Script to check VPC quota and request status

echo "=== Current VPC Quota ==="
CURRENT_QUOTA=$(aws service-quotas get-service-quota \
  --service-code vpc \
  --quota-code L-F678F1CE \
  --query 'Quota.Value' \
  --output text)

echo "Current limit: $CURRENT_QUOTA VPCs"
echo ""

echo "=== Current VPC Count ==="
VPC_COUNT=$(aws ec2 describe-vpcs --query 'length(Vpcs)' --output text)
echo "You have: $VPC_COUNT VPCs"
echo "Available: $(( $(echo $CURRENT_QUOTA | cut -d. -f1) - $VPC_COUNT )) VPCs"
echo ""

echo "=== Pending Quota Increase Requests ==="
aws service-quotas list-requested-service-quota-change-history \
  --service-code vpc \
  --query 'RequestedQuotas[?QuotaCode==`L-F678F1CE`] | sort_by(@, &Created)[-1].[Status,DesiredValue,Created]' \
  --output table

echo ""
echo "=== Request Status Meanings ==="
echo "PENDING   - Request submitted, waiting for AWS approval"
echo "APPROVED  - Request approved, quota has been increased"
echo "DENIED    - Request was denied (check email for reason)"
echo "CASE_OPEN - AWS support case opened for manual review"

