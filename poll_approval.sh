#!/bin/bash
# poll_approval.sh: Watches the current PR for an approval label with a safety timeout

LEDGER_PATH=".ai/sprint_ledger.json"
BRANCH=$(git branch --show-current)
MAX_ATTEMPTS=120  # 2 hours if sleep is 60s
ATTEMPT=0

echo "🕵️ Polling for approval on branch: $BRANCH (Timeout: 2hrs)"

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  # 1. Check if we still need to poll
  STATUS=$(jq -r '.active_sprint.status' $LEDGER_PATH)
  
  if [ "$STATUS" != "HITL_PENDING" ]; then
    echo "✅ Ledger status is $STATUS. Poller exiting."
    exit 0
  fi

  # 2. Check GitHub for the label
  LABEL_FOUND=$(gh pr view "$BRANCH" --json labels -q '.labels[].name' | grep "approved-by-tpm")

  if [ "$LABEL_FOUND" == "approved-by-tpm" ]; then
    echo "🎯 Approval label found! Updating ledger..."
    jq '.active_sprint.status = "APPROVED"' $LEDGER_PATH > temp.json && mv temp.json $LEDGER_PATH
    exit 0
  fi

  ATTEMPT=$((ATTEMPT + 1))
  echo "⏳ Attempt $ATTEMPT/$MAX_ATTEMPTS. No label yet. Sleeping 60s..."
  sleep 60
done

# 3. Timeout Handling
echo "⚠️ POLLER TIMEOUT: No approval found after 2 hours."
echo "Setting status to TIMEOUT. Manual intervention required."
jq '.active_sprint.status = "TIMEOUT"' $LEDGER_PATH > temp.json && mv temp.json $LEDGER_PATH
exit 1