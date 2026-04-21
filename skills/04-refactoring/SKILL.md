# Skill: Test Refactoring

Improve existing tests: readability, structure, DRY, maintainability — without changing test semantics.

---

## Invocation

```
/refactoring [path/to/TestClass.kt or directory]
```

If no path is provided, ask the user which tests to refactor.

---

## Project context

[НАСТРОИТЬ: замени на актуальные данные своего проекта]

```
Base package:   com.example.myapp
Test sources:   src/test/kotlin/
```

---

## Stack

- **Language**: Kotlin
- **Test framework**: JUnit5
- **Assertions**: [НАСТРОИТЬ: AssertJ / assertk / Kotest]
- **Mocking**: [НАСТРОИТЬ: MockK / Mockito-Kotlin]
- **Reporting**: Allure

---

## Refactoring checklist

Work through these checks in order. Stop after each and confirm with the user before proceeding to the next group if there are many changes.

### Group 1 — Structure and readability

- [ ] Test method names clearly describe the scenario in the form `should <result> when <condition>`.
- [ ] Each test follows Arrange / Act / Assert with a blank line between sections.
- [ ] No test method is longer than ~30 lines; extract helpers if needed.
- [ ] `@DisplayName` is used where the method name alone is insufficient.
- [ ] Test class has `@Epic`, `@Feature`, and required Allure annotations.

### Group 2 — DRY and test data

- [ ] Repeated object construction is extracted into a Builder or factory function.
- [ ] `@BeforeEach` handles common setup; teardown is in `@AfterEach`.
- [ ] Data-driven tests use `@ParameterizedTest` + `@MethodSource` instead of copy-pasted methods.
- [ ] No magic literals — replace with named constants or builder methods.

### Group 3 — Assertions

- [ ] Each test has one logical assertion (or `assertAll` for compound checks).
- [ ] Assertions use the project's standard library (see Stack above) — no mixing of assertion styles.
- [ ] Failure messages are descriptive: `assertThat(actual).describedAs("...").isEqualTo(expected)`.
- [ ] Exception assertions use `assertThrows` / `shouldThrow`, not try/catch blocks.

### Group 4 — Mocking

- [ ] Mocks are declared at the class level, not inside test methods.
- [ ] `every { ... }` / `whenever { ... }` stubs use the most specific matchers available.
- [ ] Verifications (`verify`) are only present when the side effect is the key behavior under test.
- [ ] No `@MockBean` in unit tests — use constructor injection with manual mocks.

### Group 5 — Test isolation

- [ ] Tests do not depend on execution order (no `@TestMethodOrder(OrderAnnotation)` for logic, only for DB lifecycle if truly needed).
- [ ] Database state is cleaned up in `@AfterEach` or wrapped in a rolled-back transaction.
- [ ] No shared mutable state at the class level (except mocks reset in `@BeforeEach`).
- [ ] No `Thread.sleep` — use Awaitility or coroutine test utilities.

### Group 6 — Allure annotations

[НАСТРОИТЬ: уточни обязательные аннотации]

- [ ] `@Epic` and `@Feature` are present on the class.
- [ ] `@Story` is present on each test method (or on the class if all methods share one story).
- [ ] `@Severity` is set appropriately — BLOCKER / CRITICAL / NORMAL / MINOR / TRIVIAL.
- [ ] `@Step` is used inside helpers to make Allure reports readable.
- [ ] `@TmsLink` / `@Issue` are set where applicable. [НАСТРОИТЬ: ваша система ссылок]

---

## Common refactoring patterns

### Extract builder

Before:
```kotlin
val user = User(id = 1L, name = "Alice", email = "alice@test.com", role = Role.ADMIN, active = true)
```

After:
```kotlin
val user = UserBuilder().withRole(Role.ADMIN).build()
```

---

### Replace copy-paste with `@ParameterizedTest`

Before:
```kotlin
@Test fun `returns error for empty name`() { validate(User(name = "")) }
@Test fun `returns error for blank name`() { validate(User(name = " ")) }
@Test fun `returns error for null name`() { validate(User(name = null)) }
```

After:
```kotlin
@ParameterizedTest
@MethodSource("invalidNames")
fun `should reject invalid name`(name: String?) { validate(User(name = name)) }

companion object {
    @JvmStatic
    fun invalidNames() = listOf("", " ", null)
}
```

---

### Replace try/catch with `assertThrows`

Before:
```kotlin
try {
    service.process(invalidInput)
    fail("Expected exception")
} catch (e: IllegalArgumentException) {
    assertEquals("Invalid input", e.message)
}
```

After:
```kotlin
val ex = assertThrows<IllegalArgumentException> { service.process(invalidInput) }
assertThat(ex.message).isEqualTo("Invalid input")
```

---

### Add `@Step` for Allure readability

Before:
```kotlin
fun createUserAndLogin(email: String): String {
    val user = userService.create(email)
    return authService.login(user.id)
}
```

After:
```kotlin
@Step("Create user {email} and obtain auth token")
fun createUserAndLogin(email: String): String {
    val user = userService.create(email)
    return authService.login(user.id)
}
```

---

## Rules

1. **Do not change test semantics.** Refactoring must not alter what is being verified.
2. Make one logical change at a time; show diffs for review.
3. If a test is fundamentally wrong (wrong assertion, wrong subject), flag it separately — do not silently fix it.
4. Preserve `@Disabled` tests with their original disable reason; do not re-enable them.
5. Do not add coverage while refactoring — that is the job of the `test-generation` skill.
6. [НАСТРОИТЬ: добавь специфичные для проекта правила]

---

## Output format

For each refactoring change:

```
## Change: <short title>

**Why**: <reason — readability / DRY / correctness / Allure annotation>

**Before**:
```kotlin
// original code
```

**After**:
```kotlin
// refactored code
```
```

---

## Steps

1. Read the test file(s) provided by the user.
2. Work through the checklist groups above, noting all issues found.
3. Present a prioritized list of changes to the user.
4. Apply changes group by group, showing diffs and waiting for confirmation.
5. After all changes, run through the checklist once more to confirm everything is addressed.
