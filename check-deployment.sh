#!/bin/bash
# Quick script to check what's actually deployed

set -e

ALB_URL="zero-to-dev-dev-alb-1503390502.us-east-1.elb.amazonaws.com"
CLUSTER="zero-to-dev-dev-cluster"

echo "🔍 Checking Deployment Status"
echo "================================"
echo ""

echo "1. Testing ALB endpoints..."
echo "   Frontend (root):"
curl -s -o /dev/null -w "   Status: %{http_code}\n" "http://${ALB_URL}/" || echo "   ❌ Failed"
echo ""
echo "   API Health:"
curl -s -o /dev/null -w "   Status: %{http_code}\n" "http://${ALB_URL}/health" || echo "   ❌ Failed"
echo ""
echo "   API /health/all:"
curl -s -o /dev/null -w "   Status: %{http_code}\n" "http://${ALB_URL}/health/all" || echo "   ❌ Failed"
echo ""

echo "2. Checking ECS Services..."
if command -v aws >/dev/null 2>&1; then
    echo "   API Service:"
    aws ecs describe-services \
        --cluster "${CLUSTER}" \
        --services "zero-to-dev-dev-api" \
        --query 'services[0].[status,runningCount,desiredCount]' \
        --output text 2>/dev/null || echo "   ❌ AWS CLI not configured or service not found"
    echo ""
    echo "   Frontend Service:"
    aws ecs describe-services \
        --cluster "${CLUSTER}" \
        --services "zero-to-dev-dev-frontend" \
        --query 'services[0].[status,runningCount,desiredCount]' \
        --output text 2>/dev/null || echo "   ❌ AWS CLI not configured or service not found"
    echo ""
    echo "3. Checking Target Groups..."
    echo "   (Run: aws elbv2 describe-target-health --target-group-arn <arn>)"
else
    echo "   ⚠️  AWS CLI not installed - cannot check ECS services"
fi

echo ""
echo "================================"
echo "💡 If API returns 503, the API service is not healthy or not running"
echo "💡 Check ECS console: https://console.aws.amazon.com/ecs"

