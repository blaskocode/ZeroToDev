#!/bin/bash
# Quick script to check EIP quota and request status

echo "=== Current EIP Usage ==="
CURRENT_COUNT=$(aws ec2 describe-addresses --query 'length(Addresses)' --output text)
echo "EIPs in use: $CURRENT_COUNT"

echo ""
echo "=== Current Quota ==="
QUOTA=$(aws service-quotas get-service-quota --service-code ec2 --quota-code L-0263D0A3 --query 'Quota.Value' --output text 2>/dev/null)
if [ -n "$QUOTA" ]; then
  echo "Quota limit: $QUOTA"
  echo "Available: $((QUOTA - CURRENT_COUNT))"
else
  echo "Could not fetch quota (default is usually 5)"
fi

echo ""
echo "=== Pending Quota Requests ==="
aws service-quotas list-requested-service-quota-change-history \
  --service-code ec2 \
  --query 'RequestedQuotas[?QuotaCode==`L-0263D0A3` && Status==`PENDING`] | sort_by(@, &Created)[-1].[Status,DesiredValue,Created]' \
  --output table 2>/dev/null || echo "No pending requests found"

echo ""
echo "=== Recent Quota Request History ==="
aws service-quotas list-requested-service-quota-change-history \
  --service-code ec2 \
  --query 'RequestedQuotas[?QuotaCode==`L-0263D0A3`] | sort_by(@, &Created)[-3:].[Status,DesiredValue,Created]' \
  --output table 2>/dev/null || echo "No request history found"

