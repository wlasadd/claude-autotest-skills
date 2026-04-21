# Customization Guide

This guide explains how to adapt the autotest-skills templates to your specific Kotlin project.

## Overview

Each `SKILL.md` contains `[НАСТРОИТЬ]` markers that indicate sections you must fill in before the skill is useful. The markers follow a consistent format:

```
[НАСТРОИТЬ: <what to fill in>]
```

Some markers are required (the skill won't work without them); others are optional improvements.

---

## Step 1 — Locate your skill files

After running `install.sh`, skills are in your project at:

```
.claude/skills/
├── test-generation.md
├── test-data.md
├── failure-analysis.md
└── refactoring.md
```

---

## Step 2 — Fill in each skill

### 2.1 Package and module structure

Every skill has a section like:

```markdown
[НАСТРОИТЬ: укажи базовый пакет, например com.example.myapp]
```

Replace with your actual package root. Example:

```markdown
Base package: `com.example.payments`
Test sources: `src/test/kotlin/com/example/payments`
```

Find your base package:

```bash
find src/test/kotlin -name "*.kt" | head -5
```

---

### 2.2 Test base classes

Many projects have shared base test classes (Spring context, Testcontainers setup, etc.).

```markdown
[НАСТРОИТЬ: укажи базовый класс для тестов, если есть]
```

Example:

```markdown
Base class for integration tests: `BaseIntegrationTest` (loads Spring context, starts DB container)
Base class for unit tests: none (plain JUnit5)
```

---

### 2.3 Allure annotations

```markdown
[НАСТРОИТЬ: укажи обязательные Allure-аннотации для вашего проекта]
```

Example:

```markdown
Required:  @Epic, @Feature, @Story
Optional:  @Owner, @Severity, @TmsLink
Convention: @Epic matches Jira epic label, @TmsLink = test case ID in TestRail
```

---

### 2.4 Test data sources

```markdown
[НАСТРОИТЬ: укажи источники тестовых данных]
```

Examples depending on your project:

```markdown
- Testcontainers PostgreSQL — started via BaseIntegrationTest
- Test fixtures in src/test/resources/fixtures/*.json
- Builder classes: com.example.payments.testdata.*Builder
- WireMock stubs in src/test/resources/wiremock/
```

---

### 2.5 Naming conventions

```markdown
[НАСТРОИТЬ: соглашение об именовании тестовых классов и методов]
```

Common options:

```markdown
Classes: <TestedClass>Test, <TestedClass>IntegrationTest
Methods: should_<action>_when_<condition> (snake_case inside backticks)
  or:  `given X when Y then Z` (natural language in backticks)
```

---

### 2.6 Import presets

To avoid Claude adding wrong imports, list the libraries you actually use:

```markdown
[НАСТРОИТЬ: перечисли используемые библиотеки и их артефакты]
```

Example:

```markdown
- junit5: org.junit.jupiter:junit-jupiter
- assertk: com.willowtreeapps.assertk:assertk-jvm
- mockk: io.mockk:mockk
- allure: io.qameta.allure:allure-junit5
- testcontainers: org.testcontainers:postgresql
```

---

## Step 3 — Domain-specific examples

The most valuable customization is replacing generic examples with real ones from your codebase.

### Find good candidates

```bash
# Find existing tests to use as style examples
find src/test/kotlin -name "*Test.kt" | head -10

# Find builder / factory classes
grep -r "Builder\|Factory\|Fixture" src/test/kotlin --include="*.kt" -l
```

Paste 1–2 representative test methods into the `## Examples` section of the relevant skill. Claude will match their style when generating new tests.

---

## Step 4 — Verify

After customization, test each skill:

1. Open Claude Code in your project directory.
2. Run `/test-generation` and point it at a small service class.
3. Check that the generated test uses the correct package, base class, annotations, and assertion library.
4. Iterate on the skill prompt if anything looks off.

---

## Tips

- Keep `[НАСТРОИТЬ]` markers for sections you haven't decided on yet — they serve as reminders.
- Skills are plain Markdown; version-control them with your project.
- Share customized skills with your team via a shared branch or internal fork of this repo.
- If a skill generates code that repeatedly needs the same manual fix, add a rule to the skill's `## Rules` section.
