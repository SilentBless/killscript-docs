---
title: Разработка через TypeScript
description: Экспериментальный community-инструмент для разработки KILLSCRIPT-модулей на TypeScript.
---

:::caution[Для продвинутых пользователей]
TypeScript toolchain — сторонний community-проект, а не встроенный или официальный способ работы с API KILLSCRIPT. Он находится в активной разработке и может отставать от изменений игры. Нативная Lua-документация на этом сайте остаётся источником истины.
:::

Этот путь подходит, если вы уже понимаете [структуру обычных и Reflex-модулей](../../getting-started/overview/) и хотите получить типы, автодополнение, многофайловый проект и проверку ошибок до запуска игры. Для первого модуля проще начать с Lua.

## Как это работает

Вы пишете клиентскую и серверную части на TypeScript. Community-компилятор:

1. проверяет доступность API для client и Reflex server;
2. объединяет импортированные файлы и транспилирует их в Lua;
3. создаёт необходимые `config.json`, `inputs.json` и точки входа;
4. синхронизирует папочный модуль для hot reload или собирает `.KillScript`.

В самой игре продолжает выполняться обычный Lua-модуль. Инструмент не добавляет новых разрешений и не обходит ограничения API: клиентский код остаётся клиентским, а серверная логика по-прежнему требует Reflex.

```text
TypeScript → проверка и сборка → scripts/main.lua + scripts/server.lua → KILLSCRIPT
```

## Небольшой пример

Настройку кнопки можно объявить рядом с использующим её кодом:

```ts
import { Keyboard, defineControls } from "@killscript/sdk/client";

const controls = defineControls("hello", {
  showMessage: Keyboard.F6,
});

controls.showMessage.onPressed(() => {
  NotificationController.ShowHint("Hello from TypeScript", 2);
});
```

Во время сборки объявление попадёт в игровой конфиг ввода, а обработчик — в сгенерированный `scripts/main.lua`. Итоговый код использует тот же [`NotificationController`](../../api/notification/), что и модуль, написанный вручную на Lua.

## Где продолжить

Полная установка, CLI, архитектура проекта, SDK-обёртки и ограничения описаны в отдельной [документации KILLSCRIPT TypeScript SDK](https://silentbless.github.io/killscript/ru/guides/getting-started/).

Исходный код инструмента доступен в [репозитории killscript](https://github.com/SilentBless/killscript). Перед обновлением зависимостей проверяйте документацию выбранной версии и тестируйте результат в игре.
