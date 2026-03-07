# Claude Code Skills & Plugins

Backup of Claude Code skills, agents, hooks, and plugin configurations.

## Directory Structure

```
agents/           GSD agent definitions (.md files)
hooks/            GSD hook scripts (.js files)
config/           Claude Code configuration
  settings.json           Main settings (plugins, hooks, statusLine, env vars)
  known_marketplaces.json Registered marketplace sources
  installed_plugins.json  Installed plugin metadata
plugins/
  good-boss-marketplace/  Local marketplace plugin (good-boss_doesnot_work + add-dag)
  cache/                  Cached marketplace plugins
    huggingface-skills/     HuggingFace skills (CLI, datasets, evaluation, model-trainer)
    claude-code-plugins/    Anthropic plugins (plugin-dev, frontend-design)
    good-boss-marketplace/  Cached copy of good-boss plugin
```

## Agents (GSD System)

11 specialized agents for the GSD (Get Stuff Done) workflow:
- codebase-mapper, debugger, executor, integration-checker
- phase-researcher, plan-checker, planner, project-researcher
- research-synthesizer, roadmapper, verifier

## Hooks

- `gsd-check-update.js` -- Runs on SessionStart to check for GSD updates
- `gsd-statusline.js` -- Custom status line display

## Installed Plugins

- **hugging-face-cli** (huggingface-skills)
- **hugging-face-datasets** (huggingface-skills)
- **hugging-face-evaluation** (huggingface-skills)
- **hugging-face-model-trainer** (huggingface-skills)
- **plugin-dev** (claude-code-plugins)
- **frontend-design** (claude-code-plugins)
- **good-boss_doesnot_work** (good-boss-marketplace)
