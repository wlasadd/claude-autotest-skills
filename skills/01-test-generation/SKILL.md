# Skill: Test Generation

Generate JUnit5 tests for Kotlin classes following project conventions.

---

## Invocation

```
/test-generation [path/to/SourceClass.kt]
```

If no path is provided, ask the user which class to cover.

---

## Project context

[НАСТРОИТЬ: замени этот блок на актуальные данные своего проекта]

```
Base package:      com.example.myapp
Test sources:      src/test/kotlin/
Production sources: src/main/kotlin/
Build tool:        Gradle (build.gradle.kts)
```

---

## Stack

- **Language**: Kotlin
- **Test framework**: JUnit5 (`@Test`, `@ParameterizedTest`, `@BeforeEach`, `@AfterEach`)
- **Assertions**: [НАСТРОИТЬ: например AssertJ / assertk / Kotest assertions]
- **Mocking**: [НАСТРОИТЬ: например MockK / Mockito-Kotlin]
- **Reporting**: Allure (`io.qameta.allure:allure-junit5`)

---

## Base classes

[НАСТРОИТЬ: укажи базовые классы тестов, если есть]

Examples:

```
Unit tests:        no base class (plain JUnit5)
Integration tests: BaseIntegrationTest (starts Spring context + Testcontainers)
API tests:         BaseApiTest (configures RestAssured / Ktor client)
```

---

## Allure annotations

[НАСТРОИТЬ: укажи обязательные и желательные аннотации]

```kotlin
@Epic("...")       // [НАСТРОИТЬ: соответствует Jira Epic / модулю]
@Feature("...")    // [НАСТРОИТЬ: функциональная область]
@Story("...")      // [НАСТРОИТЬ: пользовательская история или требование]
@Severity(SeverityLevel.CRITICAL) // BLOCKER | CRITICAL | NORMAL | MINOR | TRIVIAL
@Owner("...")      // [НАСТРОИТЬ: имя/логин ответственного]
```

---

## Naming conventions

[НАСТРОИТЬ: выбери одно соглашение или опиши своё]

Option A — snake_case inside backticks:
```kotlin
@Test
fun `should return 404 when user not found`() { ... }
```

Option B — camelCase:
```kotlin
@Test
fun shouldReturn404WhenUserNotFound() { ... }
```

Test class name: `<TestedClass>Test` or `<TestedClass>IntegrationTest`.

---

## Rules

1. Mirror the package of the class under test inside `src/test/kotlin/`.
2. One test class per production class.
3. Every test method has exactly one logical assertion (use `assertAll` for compound checks).
4. Use `@DisplayName` when the method name alone is not clear enough.
5. Prefer `@ParameterizedTest` + `@MethodSource` for data-driven cases.
6. Do not use `Thread.sleep` — use Awaitility or coroutine test utilities.
7. Do not catch exceptions manually — use `assertThrows` / `shouldThrow`.
8. Apply all required Allure annotations to the class, not individual methods (unless they differ).
9. [НАСТРОИТЬ: добавь специфичные для проекта правила]

---

## Test structure template

```kotlin
package [НАСТРОИТЬ: пакет, зеркалящий production-класс]

import io.qameta.allure.*
import org.junit.jupiter.api.*
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource
// [НАСТРОИТЬ: добавь импорты для assertion-библиотеки и моков]

@Epic("[НАСТРОИТЬ]")
@Feature("[НАСТРОИТЬ]")
@DisplayName("[НАСТРОИТЬ: понятное название тестируемого компонента]")
class ExampleTest {

    // [НАСТРОИТЬ: объяви зависимости / моки]

    @BeforeEach
    fun setUp() {
        // [НАСТРОИТЬ: подготовка состояния]
    }

    @Test
    @Story("[НАСТРОИТЬ]")
    @Severity(SeverityLevel.CRITICAL)
    fun `should do something when condition`() {
        // Arrange
        // [НАСТРОИТЬ]

        // Act
        // [НАСТРОИТЬ]

        // Assert
        // [НАСТРОИТЬ]
    }
}
```

---

## Examples

[НАСТРОИТЬ: вставь 1–2 реальных теста из своего проекта как образцы стиля]

```kotlin
// Example placeholder — replace with a real test from your codebase
@Test
fun `should calculate correct total when discount is applied`() {
    val order = OrderBuilder().withItems(2).withDiscount(10).build()

    val total = orderService.calculateTotal(order)

    assertThat(total).isEqualTo(BigDecimal("90.00"))
}
```

---

## Coverage checklist

When generating tests, ensure coverage of:

- [ ] Happy path (main success scenario)
- [ ] Boundary values (empty collections, zero, max values)
- [ ] Invalid / null inputs
- [ ] Expected exceptions and error messages
- [ ] [НАСТРОИТЬ: специфичные для домена сценарии]

---

## Steps

1. Read the production class provided by the user.
2. Identify public methods and their contracts (return types, thrown exceptions, side effects).
3. Determine test type (unit / integration / API) based on the class dependencies.
4. Generate a complete test class following the template and rules above.
5. Ask the user if they want to add parametrized or edge-case tests.
