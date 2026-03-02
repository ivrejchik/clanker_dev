# Claude Skills by ivrejchik

A collection of Claude Code plugins and skills.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| **solve** | Spawn a full parallel dev team to solve any problem. Acts as team lead — researches, plans, then deploys parallel agent team members. |
| **add-dag** | Build a new Airflow DAG from a brief idea, .py file, or .md spec. Launches 6 parallel research agents, then implements the DAG with tests. |

## Installation

Install plugins from this marketplace:

```
/plugin install solve@claude-skills-ivrejchik
```

Or browse available plugins:

```
/plugin > Discover
```

## Plugin Structure

```
plugins/
└── plugin-name/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── skills/
    │   └── skill-name/
    │       └── SKILL.md
    └── README.md
```

## Contributing

Feel free to open issues or submit PRs with new skills or improvements to existing ones.
