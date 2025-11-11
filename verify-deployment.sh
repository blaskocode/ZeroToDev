#!/bin/bash
# Verify that the API service has restarted and connected to the database

set -e

ALB_URL="zero-to-dev-dev-alb-1503390502.us-east-1.elb.amazonaws.com"
CLUSTER="zero-to-dev-dev-cluster"
API_SERVICE="zero-to-dev-dev-api"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Verifying API Deployment${NC}"
echo "=================================="
echo ""

# 1. Check GitHub Actions status
echo -e "${BLUE}1. Checking GitHub Actions Status...${NC}"
if command -v gh >/dev/null 2>&1; then
    echo "   Latest workflow run:"
    gh run list --workflow=deploy.yml --limit 1 --json status,conclusion,createdAt --jq '.[] | "   Status: \(.status) | Conclusion: \(.conclusion) | Started: \(.createdAt)"' 2>/dev/null || echo "   ⚠️  GitHub CLI not authenticated or workflow not found"
else
    echo "   ⚠️  GitHub CLI not installed - check manually at:"
    echo "   https://github.com/YOUR_REPO/actions"
fi
echo ""

# 2. Check ECS Service Status
echo -e "${BLUE}2. Checking ECS Service Status...${NC}"
SERVICE_STATUS=$(aws ecs describe-services \
    --cluster "${CLUSTER}" \
    --services "${API_SERVICE}" \
    --query 'services[0].[status,runningCount,desiredCount,deployments[0].status]' \
    --output text 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$SERVICE_STATUS" ]; then
    read -r STATUS RUNNING DESIRED DEPLOY_STATUS <<< "$SERVICE_STATUS"
    echo "   Service Status: ${STATUS}"
    echo "   Running Tasks: ${RUNNING}/${DESIRED}"
    echo "   Deployment Status: ${DEPLOY_STATUS}"
    
    if [ "$RUNNING" -gt 0 ]; then
        echo -e "   ${GREEN}✓ API service is running${NC}"
    else
        echo -e "   ${RED}✗ API service has 0 running tasks${NC}"
    fi
    
    if [ "$DEPLOY_STATUS" = "PRIMARY" ]; then
        echo -e "   ${GREEN}✓ Deployment is active${NC}"
    else
        echo -e "   ${YELLOW}⚠ Deployment status: ${DEPLOY_STATUS}${NC}"
    fi
else
    echo -e "   ${RED}✗ Failed to get service status${NC}"
fi
echo ""

# 3. Check Recent API Logs
echo -e "${BLUE}3. Checking Recent API Logs (last 5 minutes)...${NC}"
LOG_ENTRIES=$(aws logs tail /ecs/zero-to-dev-dev-api --since 5m --format short 2>/dev/null | tail -20)

if [ -n "$LOG_ENTRIES" ]; then
    echo "   Recent log entries:"
    echo "$LOG_ENTRIES" | while IFS= read -r line; do
        if echo "$line" | grep -q "PostgreSQL connected\|Failed to start\|self-signed certificate"; then
            if echo "$line" | grep -q "PostgreSQL connected"; then
                echo -e "   ${GREEN}✓ $line${NC}"
            elif echo "$line" | grep -q "self-signed certificate"; then
                echo -e "   ${RED}✗ $line${NC}"
            else
                echo "   $line"
            fi
        fi
    done
    
    # Check for success indicators
    if echo "$LOG_ENTRIES" | grep -q "PostgreSQL connected"; then
        echo -e "   ${GREEN}✓ Database connection successful!${NC}"
    elif echo "$LOG_ENTRIES" | grep -q "self-signed certificate"; then
        echo -e "   ${RED}✗ Still seeing SSL certificate errors${NC}"
    fi
else
    echo "   ⚠️  No recent log entries (service may not have restarted yet)"
fi
echo ""

# 4. Test API Endpoints
echo -e "${BLUE}4. Testing API Endpoints...${NC}"

echo "   Testing /health endpoint:"
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://${ALB_URL}/health" 2>/dev/null || echo "000")
if [ "$HEALTH_STATUS" = "200" ]; then
    echo -e "   ${GREEN}✓ /health returns 200 OK${NC}"
    curl -s "http://${ALB_URL}/health" | head -c 100
    echo ""
else
    echo -e "   ${RED}✗ /health returns ${HEALTH_STATUS}${NC}"
fi

echo ""
echo "   Testing /health/all endpoint:"
ALL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://${ALB_URL}/health/all" 2>/dev/null || echo "000")
if [ "$ALL_STATUS" = "200" ]; then
    echo -e "   ${GREEN}✓ /health/all returns 200 OK${NC}"
    echo "   Response preview:"
    curl -s "http://${ALB_URL}/health/all" | python3 -m json.tool 2>/dev/null | head -15 || curl -s "http://${ALB_URL}/health/all" | head -c 200
    echo ""
else
    echo -e "   ${RED}✗ /health/all returns ${ALL_STATUS}${NC}"
    if [ "$ALL_STATUS" = "503" ]; then
        echo "   (503 = Service Unavailable - API not healthy or not running)"
    elif [ "$ALL_STATUS" = "504" ]; then
        echo "   (504 = Gateway Timeout - API not responding)"
    fi
fi
echo ""

# 5. Check Target Group Health
echo -e "${BLUE}5. Checking Target Group Health...${NC}"
TG_ARN=$(aws elbv2 describe-target-groups \
    --names "zero-to-dev-dev-api-tg" \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text 2>/dev/null)

if [ -n "$TG_ARN" ] && [ "$TG_ARN" != "None" ]; then
    TG_HEALTH=$(aws elbv2 describe-target-health \
        --target-group-arn "$TG_ARN" \
        --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State,TargetHealth.Reason]' \
        --output text 2>/dev/null)
    
    if [ -n "$TG_HEALTH" ]; then
        echo "$TG_HEALTH" | while IFS=$'\t' read -r target_id state reason; do
            if [ "$state" = "healthy" ]; then
                echo -e "   ${GREEN}✓ Target ${target_id}: ${state}${NC}"
            else
                echo -e "   ${RED}✗ Target ${target_id}: ${state}${NC}"
                if [ -n "$reason" ]; then
                    echo "     Reason: ${reason}"
                fi
            fi
        done
    else
        echo "   ⚠️  No targets registered in target group"
    fi
else
    echo "   ⚠️  Could not find target group"
fi
echo ""

# Summary
echo "=================================="
echo -e "${BLUE}Summary:${NC}"
echo ""

if [ "$HEALTH_STATUS" = "200" ] && [ "$ALL_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ SUCCESS: API is running and healthy!${NC}"
    echo ""
    echo "Your frontend should now work at:"
    echo "  http://${ALB_URL}"
    echo ""
    echo "Test it:"
    echo "  curl http://${ALB_URL}/health/all"
elif [ "$RUNNING" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  API service is running but endpoints are not responding${NC}"
    echo "   Check logs for errors:"
    echo "   aws logs tail /ecs/zero-to-dev-dev-api --follow"
else
    echo -e "${RED}❌ API service is not running or not healthy${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check GitHub Actions workflow completed successfully"
    echo "  2. Check ECS service events:"
    echo "     aws ecs describe-services --cluster ${CLUSTER} --services ${API_SERVICE}"
    echo "  3. Check recent logs:"
    echo "     aws logs tail /ecs/zero-to-dev-dev-api --since 10m"
fi
echo ""

