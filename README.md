# autotest-skills

Claude Code skills for test automation in Kotlin projects (JUnit5 + Allure).

Ready-to-use skill templates that can be adapted to any Kotlin test project.

## Skills

| # | Skill | Description |
|---|-------|-------------|
| 01 | [test-generation](skills/01-test-generation/SKILL.md) | Generate tests from source code or spec |
| 02 | [test-data](skills/02-test-data/SKILL.md) | Prepare test data: builders, fixtures, factories |
| 03 | [failure-analysis](skills/03-failure-analysis/SKILL.md) | Analyze failed tests, suggest fixes |
| 04 | [refactoring](skills/04-refactoring/SKILL.md) | Refactor tests: structure, readability, DRY |
| 05 | [event-streaming](skills/05-event-streaming/SKILL.md) | Write and verify async event tests (Kafka, RabbitMQ) |

## Requirements

- Claude Code CLI (`claude` command available)
- Kotlin project with JUnit5
- Allure (optional, for annotations)

## Installation

### Interactive installer (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/autotest-skills/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/YOUR_ORG/autotest-skills.git
cd autotest-skills
bash install.sh
```

### Manual installation

Copy the desired `SKILL.md` files into your project's `.claude/skills/` directory:

```bash
mkdir -p .claude/skills
cp skills/01-test-generation/SKILL.md .claude/skills/test-generation.md
```

## Customization

After installation, edit the `[НАСТРОИТЬ]` sections in each skill file to match your project's conventions.

See [docs/customization-guide.md](docs/customization-guide.md) for a step-by-step guide.

## Repository structure

```
autotest-skills/
├── README.md
├── install.sh
├── docs/
│   └── customization-guide.md
└── skills/
    ├── 01-test-generation/
    │   └── SKILL.md
    ├── 02-test-data/
    │   └── SKILL.md
    ├── 03-failure-analysis/
    │   └── SKILL.md
    ├── 04-refactoring/
    │   └── SKILL.md
    └── 05-event-streaming/
        └── SKILL.md
```

## Usage

After installation, invoke skills in Claude Code:

```
/test-generation
/test-data
/failure-analysis
/refactoring
/event-streaming
```

## License

MIT
