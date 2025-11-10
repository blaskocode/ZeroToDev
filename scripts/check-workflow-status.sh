#!/bin/bash
# Script to check GitHub Actions workflow status and fetch logs

set -e

REPO_OWNER=$(git remote get-url origin | sed -E 's/.*github.com[:/]([^/]+)\/([^/]+)\.git.*/\1/')
REPO_NAME=$(git remote get-url origin | sed -E 's/.*github.com[:/]([^/]+)\/([^/]+)\.git.*/\2/' | sed 's/\.git$//')

echo "Repository: $REPO_OWNER/$REPO_NAME"
echo ""

if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed."
    echo "Install it with: brew install gh"
    echo "Then authenticate with: gh auth login"
    exit 1
fi

echo "Checking latest workflow run..."
LATEST_RUN=$(gh run list --workflow=deploy.yml --limit 1 --json databaseId,status,conclusion,headBranch,createdAt --jq '.[0]')

if [ -z "$LATEST_RUN" ] || [ "$LATEST_RUN" == "null" ]; then
    echo "No workflow runs found"
    exit 1
fi

RUN_ID=$(echo "$LATEST_RUN" | jq -r '.databaseId')
STATUS=$(echo "$LATEST_RUN" | jq -r '.status')
CONCLUSION=$(echo "$LATEST_RUN" | jq -r '.conclusion')
BRANCH=$(echo "$LATEST_RUN" | jq -r '.headBranch')
CREATED=$(echo "$LATEST_RUN" | jq -r '.createdAt')

echo "Latest run:"
echo "  ID: $RUN_ID"
echo "  Status: $STATUS"
echo "  Conclusion: ${CONCLUSION:-pending}"
echo "  Branch: $BRANCH"
echo "  Created: $CREATED"
echo ""

if [ "$STATUS" == "completed" ]; then
    if [ "$CONCLUSION" == "success" ]; then
        echo "✅ Workflow completed successfully!"
    else
        echo "❌ Workflow failed. Fetching logs..."
        echo ""
        gh run view $RUN_ID --log-failed
    fi
elif [ "$STATUS" == "in_progress" ]; then
    echo "⏳ Workflow is still running..."
    echo "View live logs: gh run watch $RUN_ID"
elif [ "$STATUS" == "queued" ]; then
    echo "⏸️  Workflow is queued..."
fi

echo ""
echo "View in browser:"
echo "  gh run view $RUN_ID --web"

