---
title: Audio
description: Загрузка звуков, локальное воспроизведение и состояние голосового чата.
---

:::note[Актуально для текущей сборки]
На странице описано поведение API в текущей версии игры.
:::

<span class="api-context api-context--client">Только client</span> Аудио API недоступен в `server.lua` Reflex-модуля.

## Быстрый пример

Поместите `Alert.wav` в папку `sounds` модуля:

```lua
local sound = Sounds:GetSound("Alert.wav")

if sound ~= nil then
    Sounds:PlaySound2D(sound, 0.7, 1)
end
```

## Sound

Загруженный звуковой ресурс. Объект передаётся в методы `Sounds`.

## Sounds

Глобальный API загрузки и воспроизведения звуков.

### GetSound

```lua
Sounds:GetSound(soundName: string): Sound
```

Ищет файл в папке `sounds` текущего модуля. Имя указывается с расширением, но без пути к папке. Поддерживаются форматы `.wav`, `.mp3` и `.ogg`. Для отсутствующего файла возвращает `nil`.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `soundName` | string |  | Имя файла, например `Alert.wav`. |

**Возвращает:** [Sound](../audio/#sound) или nil

### PlaySound

```lua
Sounds:PlaySound(
    sound: Sound,
    position: Vector3,
    volume: number = 1,
    minDistance: number = 5,
    maxDistance: number = 500,
    pitch: number = 1
)
```

Проигрывает пространственный звук в указанной точке мира. Вызов возвращает `nil`.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `sound` | [Sound](../audio/#sound) |  | Загруженный звуковой ресурс. |
| `position` | [Vector3](../vector3/) |  | Позиция источника в мировых координатах. |
| `volume` | number | ✅ | Громкость звука. |
| `minDistance` | number | ✅ | Расстояние, внутри которого сохраняется полная громкость. |
| `maxDistance` | number | ✅ | Расстояние, к которому звук затихает. |
| `pitch` | number | ✅ | Высота тона и скорость воспроизведения. |

### PlaySound2D

```lua
Sounds:PlaySound2D(sound: Sound, volume: number = 1, pitch: number = 1)
```

Проигрывает звук без пространственного позиционирования. Вызов возвращает `nil`.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `sound` | [Sound](../audio/#sound) |  | Загруженный звуковой ресурс. |
| `volume` | number | ✅ | Громкость от `0` до `1`. |
| `pitch` | number | ✅ | Высота тона и скорость воспроизведения. |

## VoiceChat

Состояние голосового чата для указанного агента.

### IsAvailable

```lua
VoiceChat:IsAvailable(agent: Agent): bool
```

Возвращает true, если агент доступен в текущей голосовой комнате. При недоступном соединении возвращает false.

### IsMuted

```lua
VoiceChat:IsMuted(agent: Agent): bool
```

Возвращает локальное состояние заглушения агента.

### IsSpeaking

```lua
VoiceChat:IsSpeaking(agent: Agent): bool
```

Возвращает true, если агент сейчас говорит в доступной голосовой комнате.

### SetMuted

```lua
VoiceChat:SetMuted(agent: Agent, muted: bool): bool
```

Локально заглушает или разглушает агента. Возвращает true, если EOS принял запрос на изменение состояния. Возвращает false, если агент недоступен, голосовая комната не подключена или запрос нельзя отправить.

### ToggleMuted

```lua
VoiceChat:ToggleMuted(agent: Agent): bool
```

Читает текущее локальное состояние, переключает его и возвращает результат отправки запроса. При ошибке возвращает false.

:::tip
Перед изменением состояния проверяйте `VoiceChat:IsAvailable(agent)`. Заглушение локальное: оно влияет только на то, слышите ли вы этого игрока.
:::

Для всех методов параметр `agent` имеет тип [Agent](../agent/#agent).

## VoiceLinePlayer

Состояние встроенного проигрывателя голосовых реплик.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `IsPlaying` | bool | `get` | true, если сейчас проигрывается голосовая реплика. |
| `Subtitle` | string | `get` | Текст субтитров текущей реплики. |
