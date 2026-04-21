# Skill: Failure Analysis

Analyze failed tests, identify root causes, and suggest actionable fixes.

---

## Invocation

```
/failure-analysis [paste error output or provide file path]
```

The user can provide:
- Paste of the test output / stack trace
- Path to a log file or Allure report directory
- A failing test method name (Claude will read the source)

---

## Project context

[НАСТРОИТЬ: замени на актуальные данные своего проекта]

```
Base package:         com.example.myapp
Test sources:         src/test/kotlin/
Log output:           build/reports/tests/   (Gradle)
Allure results:       build/allure-results/
CI system:            [НАСТРОИТЬ: GitHub Actions / GitLab CI / Jenkins / TeamCity]
```

---

## Stack

- **Test framework**: JUnit5
- **Reporting**: Allure
- **Persistence**: [НАСТРОИТЬ: PostgreSQL / H2 / Mongo / etc.]
- **Test containers**: [НАСТРОИТЬ: Testcontainers / embedded / mocks]
- **HTTP client / server**: [НАСТРОИТЬ: RestAssured / Ktor / MockMvc / WireMock]

---

## Failure taxonomy

Use this taxonomy to categorize the failure before suggesting a fix.

### 1. Assertion failure
Test logic reached the assertion but the value was wrong.

Signals: `AssertionError`, `AssertionFailedError`, `ComparisonFailure`

Common causes:
- Business logic regression in production code
- Test expectation is stale (requirement changed)
- Test data produces an unexpected value
- Off-by-one, timezone, or locale issue

### 2. Infrastructure failure
Test could not start or connect to a dependency.

Signals: `ContainerLaunchException`, `ConnectionRefusedException`, `BeanCreationException`, timeout on startup

Common causes:
- Testcontainers image not available / outdated
- Port conflict on CI
- Spring context misconfiguration
- Missing environment variable

### 3. Data / state pollution
Test fails because of leftover state from a previous test.

Signals: `DataIntegrityViolationException`, `UniqueConstraintViolation`, unexpected row counts, `EntityNotFoundException` for an ID that "should" exist

Common causes:
- Missing `@AfterEach` cleanup
- Shared mutable static state
- Test order dependency (`@TestMethodOrder`)
- Transaction not rolled back

### 4. Flaky test
Test passes sometimes and fails sometimes without code changes.

Signals: failure on CI but not locally, race conditions, `TimeoutException`, timing-dependent assertions

Common causes:
- `Thread.sleep` instead of proper await
- Async operation not awaited
- Non-deterministic ordering (HashMap, parallel execution)
- External service dependency (network, clock)

### 5. Compilation / configuration error
Test does not compile or the test runner cannot load it.

Signals: `ClassNotFoundException`, `NoSuchMethodError`, `NoSuchBeanDefinitionException`

Common causes:
- Missing dependency in `build.gradle.kts`
- Incompatible library versions
- Annotation processor not configured

---

## Analysis procedure

When the user provides a failure, follow these steps:

1. **Read the full stack trace** — identify the first non-framework line to find the source of failure.
2. **Categorize** — assign one of the five failure types above.
3. **Read the failing test** — understand what it is trying to verify.
4. **Read the production code** involved — confirm whether the bug is in test or in the code.
5. **Check test data** — verify that builders/fixtures produce the expected state.
6. **Propose a fix** — provide a minimal, targeted code change.
7. **Suggest a guard** — if relevant, suggest how to prevent this class of failure in the future.

---

## Output format

For each failure, produce:

```
## Failure: <short description>

**Category**: <taxonomy category>

**Root cause**:
<1–3 sentences explaining WHY it failed>

**Fix**:
<code snippet or diff>

**Prevention** (optional):
<rule or test improvement to avoid recurrence>
```

---

## Common fixes reference

[НАСТРОИТЬ: добавь типичные ошибки и их решения из своего проекта]

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `UniqueConstraintViolationException` on `email` | Missing cleanup between tests | Add `repository.deleteAll()` in `@AfterEach` |
| `BeanCreationException: No qualifying bean` | Missing `@MockkBean` / `@MockBean` | Add mock declaration to test class |
| `ContainerLaunchException` on CI | Docker not available | Check CI runner has Docker; add `assumeTrue(DockerClientFactory.instance().isDockerAvailable)` |
| Assertion on timestamp fails by a few ms | Comparison without tolerance | Use `isCloseTo()` or truncate to seconds |
| [НАСТРОИТЬ] | [НАСТРОИТЬ] | [НАСТРОИТЬ] |

---

## Flakiness detection heuristics

- Does the failure mention a thread name other than `main` or `test-thread`? → likely concurrency issue.
- Does the failure appear only in parallel test execution? → shared state or port conflict.
- Does the failure mention a timestamp or duration? → timing dependency.
- Does the failure appear only on CI? → environment difference (Docker, timezone, locale, file path separator).

[НАСТРОИТЬ: добавь специфичные паттерны из своего проекта]

---

## Rules

1. Always read both the failing test AND the production code before proposing a fix.
2. Prefer fixing the test data over hardcoding values in assertions.
3. Never suggest suppressing a failure — find the root cause.
4. If the failure points to a real production bug, say so clearly and propose a separate fix for the production code.
5. If the failure is a flaky test, suggest marking it with `@Disabled("Flaky: <reason>")` only as a temporary measure, and open a task to fix it properly.
6. [НАСТРОИТЬ: добавь специфичные для проекта правила]
