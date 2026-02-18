# 🚀 Agentic Data Workforce: GitHub Copilot Edition

## 📌 Project Vision

This project demonstrates how a **Technical PM** orchestrates a complex data engineering lifecycle using **GitHub Copilot**. Instead of writing line-by-line code, the TPM manages a "Sprint" by providing specialized context to Copilot, ensuring it acts as a Data Architect, dbt Developer, or QA Engineer on demand.

---

## 🏗 The Structure

The project is designed to be **"Copilot-Native."** We use hidden and specialized folders to feed Copilot the exact context it needs for each phase.

* **`.ai/LEAD_PROMPT.md`**: The master instructions for the Copilot chat session.
* **`agents/`**: Role-specific instructions you "attach" to your Copilot Chat.
* **`CLAUDE.md`**: Copilot naturally reads this to understand your coding standards (Naming conventions, SQL style, etc.).

---

## 🛠 Usage Instructions (Copilot Workflow)

### 1. The "Project Charter" Initialization

Before starting, ensure `CLAUDE.md` is in the root. When you open Copilot Chat, it will automatically index this file.

> **TPM Tip:** If Copilot tries to use a different SQL dialect, remind it: *"Refer to CLAUDE.md for the source of truth."*

### 2. Starting a New Sprint

**Before opening Copilot Chat**, populate `.ai/SPRINT_REQUIREMENTS.md` with the sprint's business rules, transformation logic, and any new dependencies. The template includes a `Permanent Rules` section for anything that should survive into `CLAUDE.md`.

Then kick off the sprint with the new **Governor-aware** start command:

```
Read /.ai/LEAD_PROMPT.md and CLAUDE.md.
Initialize 'sprint_name' by syncing SPRINT_REQUIREMENTS.md into the ledger and verifying the environment.
```

This single command causes the Lead Agent to:
1. Extract `sprint_id`, `goals`, and `technical_dependencies` from `SPRINT_REQUIREMENTS.md`
2. Sync the new sprint into `active_sprint` in `sprint_ledger.json`
3. Check `env_verified` — if false or new dependencies are listed, DevOps runs automatically before any other phase

### 3. Running the Agent Phases

The Lead Agent can run all phases automatically in a single command:

```
Read #file:.ai/LEAD_PROMPT.md and CLAUDE.md. Run the full sprint.
```

This chains: DevOps (env check) → Architect → Transformer → Auditor → DevOps (DAG) with automatic quality gates between each phase.

Alternatively, run phases individually:

| Phase | Prompt |
|-------|--------|
| **Architect** | `run #file:agents/01_architect.md` |
| **Transformer** | `run #file:agents/02_transformer.md` |
| **Auditor** | `audit via #file:agents/03_auditor.md` |
| **DevOps** | `execute #file:agents/04_devops.md` |

### 4. Continuous Governance

1. **Review the Ghost Text:** Before hitting `Tab`, ensure the logic matches the **Definition of Done** in your Charter.
2. **Iterative Correction:** If Copilot makes a mistake, don't fix the code—**fix the agent file.** Update `agents/02_transformer.md` with the new rule and ask Copilot to "Try again based on the updated instructions."

### 5. Sprint Wrap-Up & Reset

Once all 4 agent phases pass, run the closing protocol **before merging the PR**. This archives the sprint summary into `docs/archive/`, promotes permanent rules to `CLAUDE.md`, updates the ledger, and resets for the next sprint:

```
Use #file:.ai/LEAD_PROMPT.md to execute the Sprint Wrap-Up.
```

The wrap-up produces a `docs/archive/sprint_[N]_summary.md` containing business rules applied, artifacts produced, test results, and auditor findings — all committed as part of the PR.

> **TPM Tip:** Any rule flagged as `Global` or `Permanent` in `SPRINT_REQUIREMENTS.md` is automatically promoted to `CLAUDE.md`
