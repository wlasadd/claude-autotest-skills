# Skill: Test Data

Create and manage test data: builders, object mothers, fixtures, and factories for Kotlin tests.

---

## Invocation

```
/test-data [ClassName or description]
```

Examples:
- `/test-data User` — generate a builder/factory for the `User` domain class
- `/test-data create fixture for checkout flow` — generate fixtures for a scenario

---

## Project context

[НАСТРОИТЬ: замени на актуальные данные своего проекта]

```
Base package:         com.example.myapp
Test data package:    com.example.myapp.testdata   (or testfixtures / support)
Domain model package: com.example.myapp.domain
```

---

## Stack

- **Language**: Kotlin
- **Test framework**: JUnit5
- **Builders**: [НАСТРОИТЬ: hand-written builders / AutoBuilder / fixture libraries]
- **Persistence**: [НАСТРОИТЬ: например Spring Data JPA, Exposed, JOOQ]
- **Database**: [НАСТРОИТЬ: например PostgreSQL via Testcontainers, H2 in-memory]

---

## Patterns in use

[НАСТРОИТЬ: отметь какие паттерны используются в проекте]

- [ ] **Builder** — fluent builder with sensible defaults
- [ ] **Object Mother** — static factory methods for named scenarios
- [ ] **Fixture** — JSON/YAML files loaded from `src/test/resources/fixtures/`
- [ ] **Factory function** — top-level Kotlin functions (`fun testUser(...): User`)
- [ ] **DSL** — Kotlin DSL block for building complex graphs

---

## Builder template

```kotlin
package [НАСТРОИТЬ: пакет для тестовых данных]

// [НАСТРОИТЬ: добавь импорты domain-классов]

class [Entity]Builder {

    // [НАСТРОИТЬ: перечисли поля с дефолтными значениями]
    private var id: Long = 1L
    private var name: String = "Default Name"
    // ...

    fun withId(id: Long) = apply { this.id = id }
    fun withName(name: String) = apply { this.name = name }
    // [НАСТРОИТЬ: добавь методы для каждого поля]

    fun build() = [Entity](
        id = id,
        name = name,
        // [НАСТРОИТЬ]
    )

    companion object {
        // Named scenarios — add as your project grows
        fun default() = [Entity]Builder().build()
        // fun active()   = [Entity]Builder().withStatus(Status.ACTIVE).build()
        // [НАСТРОИТЬ: добавь именованные сценарии]
    }
}
```

---

## Object Mother template

```kotlin
package [НАСТРОИТЬ: пакет для тестовых данных]

object [Entity]Mother {

    fun default(): [Entity] = [Entity]Builder.default()

    // [НАСТРОИТЬ: добавь именованные сценарии]
    fun withMinimalData(): [Entity] = [Entity]Builder()
        // .withX(...)
        .build()

    fun withAllFields(): [Entity] = [Entity]Builder()
        // .withX(...).withY(...)
        .build()
}
```

---

## Factory function template

```kotlin
package [НАСТРОИТЬ: пакет для тестовых данных]

fun test[Entity](
    // [НАСТРОИТЬ: перечисли поля с дефолтными значениями]
    id: Long = 1L,
    name: String = "Test Name",
    // ...
): [Entity] = [Entity](
    id = id,
    name = name,
    // [НАСТРОИТЬ]
)
```

---

## Database fixture helper

[НАСТРОИТЬ: адаптируй под свой persistence-слой или удали секцию]

```kotlin
package [НАСТРОИТЬ]

// Spring Data JPA example
@Component
class [Entity]Fixture(
    private val repository: [Entity]Repository,
) {
    fun persist(builder: [Entity]Builder = [Entity]Builder()): [Entity] =
        repository.save(builder.build())

    fun persistAll(count: Int): List<[Entity]> =
        (1..count).map { i -> persist([Entity]Builder().withId(i.toLong())) }

    fun clear() = repository.deleteAll()
}
```

---

## JSON fixture

[НАСТРОИТЬ: укажи путь к ресурсам и формат]

```
src/test/resources/fixtures/
├── entity/
│   ├── default.json
│   └── minimal.json
└── scenario/
    └── checkout-flow.json
```

Loader utility:

```kotlin
// [НАСТРОИТЬ: адаптируй под свой JSON-сериализатор (Jackson / Gson / kotlinx.serialization)]
inline fun <reified T> loadFixture(path: String): T {
    val json = object {}.javaClass.getResourceAsStream("/fixtures/$path")
        ?: error("Fixture not found: $path")
    return objectMapper.readValue(json, T::class.java)
}
```

---

## Rules

1. Builders must provide sensible defaults so a `Builder().build()` call always produces a valid object.
2. Named scenarios (e.g., `withActiveStatus()`) are preferred over free-form field manipulation in tests.
3. Keep builders next to tests, not in production sources.
4. Avoid `Random` in defaults — use deterministic values to make failures reproducible.
5. For database fixtures, always clean up in `@AfterEach` or use transactions that roll back.
6. [НАСТРОИТЬ: добавь специфичные для проекта правила]

---

## Examples

[НАСТРОИТЬ: вставь реальный Builder или Mother из своего проекта]

```kotlin
// Example placeholder — replace with a real builder from your codebase
class UserBuilder {
    private var id: Long = 1L
    private var email: String = "test@example.com"
    private var role: Role = Role.USER

    fun withRole(role: Role) = apply { this.role = role }
    fun build() = User(id = id, email = email, role = role)

    companion object {
        fun admin() = UserBuilder().withRole(Role.ADMIN).build()
    }
}
```

---

## Steps

1. Ask the user which domain class or scenario needs test data.
2. Read the domain class to understand its fields, types, and constraints.
3. Identify the appropriate pattern (Builder / Mother / Factory / Fixture).
4. Generate the test data class following the templates and rules above.
5. If persistence is involved, generate a fixture helper as well.
6. Suggest named scenarios that cover the most common test cases for this entity.
