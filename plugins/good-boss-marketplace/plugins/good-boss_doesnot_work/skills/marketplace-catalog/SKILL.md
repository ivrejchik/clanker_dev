---
name: Marketplace Skill Catalog
description: "Registry of all available marketplace skills, agents, and commands that the boss can delegate to when spawning specialist agents."
---

# Available Marketplace Skills

This catalog lists specialized skills, agents, and commands available from installed marketplaces. The boss consults this catalog when designing teams to find domain-specific expertise beyond the standard specialist roster.

## How to Use This Catalog

When analyzing a user's task, scan this catalog for entries whose "When to use" matches the task. Three injection patterns exist:

1. **Skill Invocation** — Spawn an agent that invokes the skill via the Skill tool (for skills like /add-dag, /solve)
2. **Agent Persona Injection** — Spawn an agent with marketplace agent expertise injected into their prompt (for agent collections like dev-experts, bug-hunters)
3. **Skill Reference** — Equip a specialist with a reference skill they can load via the Skill tool (for reference skills like polars-expertise, golang-pro)

---

## Local Skills (this marketplace)

### /add-dag
- **Type:** Skill (team-spawning)
- **Description:** Build a new Airflow DAG from a brief idea, .py file, or .md spec. Launches parallel research agents for thorough analysis before generating code.
- **When to use:** User asks to create, build, or add an Airflow DAG, or mentions Airflow pipelines.
- **Injection pattern:** Skill Invocation — spawn an agent and tell it: "Use the Skill tool to invoke /add-dag with arguments: '{user_request}'. Report results to team-lead."

### /solve
- **Type:** Skill (team-spawning)
- **Description:** Spawn a full parallel dev team with its own team lead to solve any complex problem. Includes discovery, research, planning, deployment, orchestration, and verification phases.
- **When to use:** User has a complex multi-domain problem that benefits from a dedicated sub-team with its own leader. Use when the task is too complex for a single specialist.
- **Injection pattern:** Skill Invocation — spawn an agent and tell it: "Use the Skill tool to invoke /solve with arguments: '{user_request}'. This will create its own sub-team. Report results to team-lead when complete."

---

## External Skills (agent-system marketplace)

> These skills are available when the DeevsDeevs/agent-system marketplace is installed.
> Install with: `/plugin marketplace add https://github.com/DeevsDeevs/agent-system.git`

### dev-experts
- **Type:** Agent collection (7 agents)
- **Available agents:** architect, devops, rust-dev, python-dev, cpp-dev, reviewer, tester
- **Description:** Language-specific development experts and code review specialists. Each agent has deep expertise in their domain with structured review and implementation workflows.
- **When to use:** User needs language-specific expertise (Rust, Python, C++), structured code review, or architecture guidance.
- **Injection pattern:** Agent Persona Injection — spawn an agent with the role: "You are a {language}-dev specialist from the dev-experts team. Apply deep {language} expertise including idiomatic patterns, performance optimization, and best practices."

### bug-hunters
- **Type:** Agent collection (4 agents)
- **Available agents:** orchestrator, logic-hunter, cpp-hunter, python-hunter
- **Description:** Specialized debugging team with language-specific bug hunters and a coordinating orchestrator.
- **When to use:** User reports a bug, especially in C++ or Python code. Also useful for logic errors and hard-to-find issues.
- **Injection pattern:** Agent Persona Injection — spawn a debugger agent with: "You are a {language}-hunter from the bug-hunters team. Apply systematic debugging methodology: reproduce → isolate → identify root cause → fix → verify."

### alpha-squad
- **Type:** Agent collection (5 agents)
- **Available agents:** fundamentalist, vulture, network-architect, book-physicist, causal-detective
- **Description:** Quantitative finance and trading specialists. Deep expertise in market microstructure, causal inference, and systematic trading.
- **When to use:** User works on trading systems, quantitative finance, market analysis, or financial data.
- **Injection pattern:** Agent Persona Injection — spawn with the relevant specialist persona from alpha-squad.

### polars-expertise
- **Type:** Skill (reference)
- **Description:** Polars DataFrame expert with comprehensive reference docs and examples covering lazy/eager APIs, expressions, joins, and performance patterns.
- **When to use:** User works with Polars DataFrames, data transformation, or mentions Polars specifically.
- **Injection pattern:** Skill Reference — tell the spawned agent: "You have access to the polars-expertise skill. Use the Skill tool to load it for reference when working with Polars DataFrames."

### golang-pro
- **Type:** Skill (reference)
- **Description:** Go programming expertise with reference material covering idioms, concurrency patterns, and best practices.
- **When to use:** User works on Go/Golang code, asks for Go-specific patterns, or mentions Go.
- **Injection pattern:** Skill Reference — tell the spawned agent: "You have access to the golang-pro skill. Use the Skill tool to load it for Go reference and best practices."

### arxiv-search
- **Type:** Skill (tool)
- **Description:** Search and retrieve academic papers from arXiv. Supports keyword search, paper retrieval, and summary generation.
- **When to use:** User needs academic references, research papers, or scientific literature.
- **Injection pattern:** Skill Invocation — tell the spawned researcher: "Use the Skill tool to invoke the arxiv-search skill to find relevant papers on '{topic}'."

### chain-system
- **Type:** Command collection
- **Commands:** /chain-link, /chain-load, /chain-list
- **Description:** Chain multiple skills together in a pipeline. Useful for multi-step workflows that combine several skills sequentially.
- **When to use:** User needs to chain multiple operations or build a multi-step pipeline.
- **Injection pattern:** Skill Invocation — tell the spawned agent about the chain commands and how to use them for the specific pipeline.
