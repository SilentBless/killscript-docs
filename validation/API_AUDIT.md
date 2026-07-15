# Состояние аудита API

Внутренний список проверки. Статусы из этой таблицы не являются публичной документацией.

| Статус | Значение |
|---|---|
| `queued` | Ещё не проверялось |
| `testing` | Подготовлен или выполняется диагностический батч |
| `verified` | Проверены доступ, поведение, контексты и примеры |

## Батчи

| Порядок | Разделы | Статус |
|---:|---|---|
| 1 | Camera, Texture | `testing` |
| 2 | Array, Structs | `queued` |
| 3 | Time, Scheduler | `queued` |
| 4 | Environment | `queued` |
| 5 | InputAction, Storage, Config, Localization | `queued` |
| 6 | UI, ImGui | `queued` |
| 7 | WorldVisuals, Audio, Notification | `queued` |
| 8 | Team, Agent | `queued` |
| 9 | Item, GameConfig, Shop | `queued` |
| 10 | Entity, Physics | `queued` |
| 11 | DefusalGame, CombatLog, Tutorial | `queued` |
| 12 | Chat | `queued` |
| 13 | Network и полный аудит Reflex-контекста | `queued` |

Порядок может меняться, если один раздел нужен для безопасной проверки другого.

## Текущий батч: Camera и Texture

- [ ] свойства главной камеры читаются;
- [ ] свойства пользовательской камеры читаются;
- [ ] каждый заявленный setter проверен отдельно;
- [ ] `IsMainCamera` подтверждён как getter-only;
- [ ] `CreateCamera` и `RemoveCamera` проверены;
- [ ] `SetActive` проверен на вызов и фактическое поведение;
- [ ] `SetRenderSize` проверен по размеру `OutputTexture`;
- [ ] `WorldToViewportPoint` проверен на тип и значения результата;
- [ ] `Texture.width` и `Texture.height` проверены;
- [ ] контекст ClientOnly подтверждён в Reflex server;
- [ ] создан минимальный независимый пример;
- [ ] записана версия игры;
- [ ] опубликованы RU и EN страницы.
