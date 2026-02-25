#!/bin/bash
# poll_approval.sh: Watches for GitHub approval to transition from HITL_PENDING

LEDGER_PATH=".ai/sprint_ledger.json"

while true; do
  STATUS=$(jq -r '.active_sprint.status' $LEDGER_PATH)

  # Only poll GitHub if we are actually stuck at the gate
  if [ "$STATUS" == "HITL_PENDING" ]; then
    echo "🐾 Status is HITL_PENDING. Checking GitHub for 'approved-by-tpm' label..."
    
    LABEL_FOUND=$(gh pr view --json labels -q '.labels[].name' | grep "approved-by-tpm")
    
    if [ "$LABEL_FOUND" == "approved-by-tpm" ]; then
      echo "✅ Approval detected! Updating status to APPROVED."
      jq '.active_sprint.status = "APPROVED"' $LEDGER_PATH > temp.json && mv temp.json $LEDGER_PATH
      exit 0
    fi
  else
    echo "⏹️ Ledger status is $STATUS. No human gate active."
    exit 0
  fi
  
  sleep 1800 # Check every 30 mins
done