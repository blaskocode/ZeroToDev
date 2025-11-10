#!/bin/bash
# Script to watch GitHub Actions workflow and automatically fetch logs on failure

set -e

REPO="blaskocode/ZeroToDev"
WORKFLOW="deploy.yml"

echo "Watching workflow: $WORKFLOW"
echo "Repository: $REPO"
echo ""

# Check if GitHub CLI is authenticated
if ! gh auth status &>/dev/null; then
    echo "❌ GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi

# Wait for the latest run to start
echo "Waiting for workflow to start..."
sleep 5

# Get the latest run
LATEST_RUN=$(gh run list --repo $REPO --workflow=$WORKFLOW --limit 1 --json databaseId,status,conclusion,headBranch,createdAt --jq '.[0]')

if [ -z "$LATEST_RUN" ] || [ "$LATEST_RUN" == "null" ]; then
    echo "No workflow runs found"
    exit 1
fi

RUN_ID=$(echo "$LATEST_RUN" | jq -r '.databaseId')
STATUS=$(echo "$LATEST_RUN" | jq -r '.status')

echo "Found run ID: $RUN_ID"
echo "Initial status: $STATUS"
echo ""

# Watch the workflow
echo "Watching workflow run..."
gh run watch $RUN_ID --repo $REPO --exit-status || EXIT_CODE=$?

# Get final status
FINAL_STATUS=$(gh run view $RUN_ID --repo $REPO --json status,conclusion --jq '.status')
CONCLUSION=$(gh run view $RUN_ID --repo $REPO --json conclusion --jq '.conclusion')

echo ""
echo "=== Workflow Completed ==="
echo "Status: $FINAL_STATUS"
echo "Conclusion: $CONCLUSION"
echo ""

if [ "$CONCLUSION" != "success" ]; then
    echo "❌ Workflow failed! Fetching error logs..."
    echo ""
    echo "=== Failed Steps ==="
    gh run view $RUN_ID --repo $REPO --log-failed
    echo ""
    echo "View full logs: gh run view $RUN_ID --repo $REPO --log"
    echo "View in browser: gh run view $RUN_ID --repo $REPO --web"
    exit 1
else
    echo "✅ Workflow completed successfully!"
    exit 0
fi

