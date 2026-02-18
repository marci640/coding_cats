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

### 2. Executing a "Sprint"

Kick off the sprint by having Copilot read the charter and lead prompt:

```
Read /.ai/LEAD_PROMPT.md and CLAUDE.md. I am starting the 'coding_cats' sprint.
```

### 3. Running the Agent Phases

Each phase is triggered with a short command referencing the agent file:

| Phase | Prompt |
|-------|--------|
| **Architect** | `run #file:agents/01_architect.md` |
| **Transformer** | `run #file:agents/02_transformer.md` |
| **Auditor** | `audit via #file:agents/03_auditor.md` |
| **DevOps** | `execute #file:agents/04_devops.md` |

That's it — one line per phase. Copilot reads the agent file and executes the instructions autonomously.

### 4. Continuous Governance

1. **Review the Ghost Text:** Before hitting `Tab`, ensure the logic matches the **Definition of Done** in your Charter.
2. **Iterative Correction:** If Copilot makes a mistake, don't fix the code—**fix the agent file.** Update `agents/02_transformer.md` with the new rule and ask Copilot to "Try again based on the updated instructions."
