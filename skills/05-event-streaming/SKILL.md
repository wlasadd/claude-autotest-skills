---
name: event-streaming
description: >
  Скилл для написания и доработки автотестов на проверку асинхронных событий
  (Kafka / RabbitMQ / любой message broker) в интеграционных тестах.
  Используй этот скилл ВСЕГДА когда нужно: написать тест на проверку
  Kafka-события или сообщения из очереди, добавить вызов checkEvent/verifyEvent
  в существующий тест, создать метод получения/сравнения события, написать
  тест-класс для нового сценария с проверкой событий, разобраться как устроены
  ожидаемые события в проекте. Если пользователь упоминает event streaming,
  Kafka, RabbitMQ, события/сообщения в очереди, checkEvent, compareEvents,
  createExpectedEvent — используй скилл.
---

# Event Streaming Autotest Skill

> ⚙️ **Секции `[НАСТРОИТЬ]` нужно заполнить под свой проект перед использованием.**
> Остальное — универсальные паттерны, работающие в большинстве Kotlin-проектов.

---

## Архитектура (типовая)

```
tests/eventstreaming/     ← Тест-классы с проверками событий
junitsteps/               ← Steps: получение и проверка событий
manager/                  ← Manager: низкоуровневые вызовы к брокеру / stubber
utils/eventstreaming/     ← Утилиты: createExpectedEvent, compareEvents
api/clients/              ← [НАСТРОИТЬ] Клиент для получения событий (Feign / REST)
```

**Слои вызовов:** `Test → checkEvent() → EventSteps → EventManager → EventClient`

---

## Структура тест-класса

```kotlin
// [НАСТРОИТЬ] @Owner, @Story, @Tag под свой проект
@Owner("your-username")
@Story("Проверка событий по [тип сущности / сценарий]")
@Tag(TagName.EVENT_STREAMING)  // [НАСТРОИТЬ] название тега
class [Entity][Scenario]EventTests : BaseTest() {  // [НАСТРОИТЬ] базовый класс

    // [НАСТРОИТЬ] Подключи нужные Steps через @Autowired
    @Autowired private lateinit var eventSteps: EventStreamingSteps
    // ... другие Steps, специфичные для вашего домена

    // Данные, специфичные для теста — заполняются в beforeEach
    private lateinit var entityId: UUID
    // [НАСТРОИТЬ] остальные поля (пользователи, склады, продукты и т.д.)

    @BeforeEach
    fun beforeEach() {
        // [НАСТРОИТЬ] подготовка: создание сущностей, пользователей, данных
    }

    @AllureId("XXXXX")
    @Test
    @DisplayName("Event streaming: проверка события [статус] при [действие]")
    fun [scenario]Test() {
        // Шаги бизнес-сценария
        // ...

        // Проверка события после каждого значимого шага
        checkEvent(task, EventStatus.SomeStatus)
    }

    // Приватный метод checkEvent — определяется в конце каждого тест-класса.
    // Принимает контекст (task/command/message) и ожидаемый статус.
    private fun checkEvent(context: TaskOrCommand, status: EventStatus) {
        val event = eventSteps.getEvent(entityId, status)
        val expectedEvent = createExpectedEvent(entityId, context, status /*, доп. параметры */)
        compareEvents(event!!, expectedEvent)
    }
}
```

**Ключевые принципы:**
- `checkEvent` вызывается **сразу после** шага, который должен породить событие
- `checkEvent` определяется как `private fun` **в конце** каждого тест-класса
- Дополнительные параметры (`hub`, `warehouse`, `config`) передаются через замыкание, а не как аргументы

---

## Утилиты: createExpectedEvent

Функция строит ожидаемое событие по данным из контекста задачи/команды. Размещается в `utils/eventstreaming/`.

```kotlin
// [НАСТРОИТЬ] сигнатуру и поля под свою доменную модель
fun createExpectedEvent(
    entityId: UUID,
    context: TaskOrCommand,       // [НАСТРОИТЬ] тип контекста — TaskV2, CommandDto и т.д.
    status: EventStatus,          // [НАСТРОИТЬ] ваш enum статусов
    // [НАСТРОИТЬ] доп. параметры: warehouse, hub, config и т.д.
): ExpectedEvent {
    return ExpectedEvent(
        // Метаданные протокола (CloudEvents / кастомный формат)
        specversion = "1.0",          // [НАСТРОИТЬ] или убрать, если не CloudEvents
        type = getType(status),       // "created" / "updated" — логика ниже
        subject = "your.topic.name",  // [НАСТРОИТЬ] название топика

        data = EventData(
            entityId = "$entityId",
            status = "$status",

            // [НАСТРОИТЬ] поля из вашей доменной модели
            storeId = "...",
            changeDateTime = "${context.acceptedAt}",

            // SLA / дедлайн — считается на основе acceptedAt + стратегии
            dueDateTime = getDueDateTime(context, status),  // [НАСТРОИТЬ] логику

            // Адрес / координаты, если применимо
            // address = buildAddress(context.customerAddress),
        )
    )
}
```

**Паттерн `getType`** — первое событие сущности "created", все последующие "updated":
```kotlin
// [НАСТРОИТЬ] первый статус для вашего типа сущности
private fun getType(status: EventStatus): String = when (status) {
    EventStatus.Initial -> "created"   // [НАСТРОИТЬ] ваш начальный статус
    else -> "updated"
}
```

---

## Утилиты: compareEvents

Функция сравнения фактического и ожидаемого события. Размещается рядом с `createExpectedEvent`.

```kotlin
fun compareEvents(
    actual: YourEventType,
    expected: YourEventType,
) {
    val entityId = expected.data.entityId

    // Строгое сравнение всех полей, кроме исключённых
    assertThat(actual)
        .describedAs("Event for entity [$entityId] is not as expected")
        .usingRecursiveComparison()
        .ignoringFields(
            // [НАСТРОИТЬ] поля с нестабильными значениями:
            "data.changeDateTime",     // сравниваем отдельно с допуском
            "data.delivery.dueDateTime",
            "id", "version", "time",   // генерируемые значения
            // ... добавь поля, специфичные для вашей модели
        )
        .isEqualTo(expected)

    // Отдельные проверки с допуском / regexp / notNull
    assertSoftly {
        // [НАСТРОИТЬ] поля с временны́м допуском
        assertThat(Instant.parse(actual.data.changeDateTime))
            .describedAs("[$entityId] Incorrect changeDateTime")
            .isCloseTo(
                Instant.parse(expected.data.changeDateTime),
                within(1, ChronoUnit.MINUTES),  // [НАСТРОИТЬ] допуск
            )

        // [НАСТРОИТЬ] поля, проверяемые по regexp
        // assertThat(actual.source)
        //     .matches("^/your-service/\\d\\.\\d+\\.\\d$")

        // Генерируемые поля — только notNull
        assertThat(actual.id).describedAs("[$entityId] id must not be null").isNotNull
        assertThat(actual.time).describedAs("[$entityId] time must not be null").isNotNull
    }
}
```

**Типовые категории полей:**

| Тип проверки | Примеры полей |
|---|---|
| Строгое равенство | `status`, `entityId`, `logisticalStrategy`, `sla` |
| Допуск ±N минут | `changeDateTime`, `dueDateTime`, `completedDateTime` |
| По regexp | `source` (версия сервиса), `dataschema` |
| Только notNull | `id`, `version`, `time` |
| Только isNull | поля, не применимые для данного статуса |
| Игнорируются | нестабильные / несущественные поля |

---

## Steps: получение события

```kotlin
@Component
class EventStreamingSteps {

    @Autowired private lateinit var eventManager: EventStreamingManager

    // [НАСТРОИТЬ] сигнатуру под вашу доменную модель
    @Step("Получение события из топика \"[НАСТРОИТЬ: название топика]\"")
    fun getEvent(entityId: UUID, status: EventStatus): YourEventType? {
        return eventManager.verifyEvent(entityId, status)
    }
}
```

---

## Manager: ожидание события

Manager реализует retry-логику — событие может появиться в брокере с задержкой.

```kotlin
@Component
class EventStreamingManager(
    private val eventClient: YourEventClient,  // [НАСТРОИТЬ] ваш клиент
) {
    fun verifyEvent(entityId: UUID, status: EventStatus): YourEventType? =
        repeatUntilAppears {
            eventClient.findEvent(entityId, status)
        }.unwrap {
            "Event streaming: could not find event for entity [$entityId] with status [$status]"
        }
}
```

**`repeatUntilAppears`** — утилита повтора запроса до появления результата (polling).
Реализуйте под свой проект или используйте `Awaitility`:
```kotlin
// Пример с Awaitility
fun verifyEvent(entityId: UUID, status: EventStatus): YourEventType =
    Awaitility.await()
        .atMost(30, TimeUnit.SECONDS)  // [НАСТРОИТЬ] таймаут
        .pollInterval(1, TimeUnit.SECONDS)
        .until { eventClient.findEvent(entityId, status) != null }
        .let { eventClient.findEvent(entityId, status)!! }
```

---

## Client: интерфейс получения событий

```kotlin
// [НАСТРОИТЬ] под ваш способ чтения из брокера (Feign, REST, TestContainers Kafka и т.д.)
interface YourEventClient {
    fun findEvent(entityId: UUID, status: EventStatus): YourEventType?
}

// Пример реализации через Feign (если события читаются через stubber/mock-сервис):
@FeignInterface("your-stubber")
interface YourEventFeignClient : YourEventClient {
    @RequestLine("GET /event-streaming/your-topic?entityId={entityId}&status={status}")
    override fun findEvent(
        @Param("entityId") entityId: UUID,
        @Param("status") status: EventStatus,
    ): YourEventType?
}
```

---

## Чеклист нового теста

- [ ] `EventStreamingSteps` добавлен через `@Autowired` в тест-классе
- [ ] `checkEvent` вызывается **сразу после** каждого шага, порождающего событие
- [ ] `checkEvent` определён как `private fun` в конце тест-класса
- [ ] Статусы проверяются в правильном порядке для данного сценария
- [ ] `createExpectedEvent` заполняет все поля из актуального контекста задачи
- [ ] `compareEvents` исключает нестабильные поля из строгого сравнения
- [ ] Временны́е поля сравниваются с допуском, а не точно
- [ ] `@DisplayName` описывает сценарий, включая проверяемый статус

---

## Частые ошибки

- **`checkEvent` вызван до завершения шага** — событие ещё не появилось в брокере. Всегда вызывай после, не до.
- **Строгое сравнение `Instant`** — наносекунды не совпадут; используй `isCloseTo(..., within(...))`.
- **Один `checkEvent` на несколько статусов** — каждый статус порождает отдельное событие; проверяй каждый отдельно.
- **Передача неправильной задачи в `checkEvent`** — для каждого статуса передавай задачу/контекст, актуальный **на момент** этого статуса (например, для `Completed` — результат `finishDelivery`, а не начальный `pickingTask`).
- **Игнорирование всех полей подряд** — добавляй в `ignoringFields` только реально нестабильные; остальные должны проверяться строго.
