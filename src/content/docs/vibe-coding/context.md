---
title: Контекст для ИИ
description: Как подключить llms.txt, объяснить среду KILLSCRIPT и сформулировать точную задачу.
---

Качество результата зависит от контекста. Перед первой задачей дайте ассистенту компактное описание среды и попросите сверяться с документацией.

## llms.txt

Актуальный контекст для coding assistants доступен по постоянному адресу:

```text
https://silentbless.github.io/killscript-docs/llms.txt
```

[Открыть llms.txt](https://silentbless.github.io/killscript-docs/llms.txt)

Файл написан на английском для совместимости с разными моделями. Он объясняет структуру модулей, Lua sandbox, client/Reflex-разделение, важные ограничения и содержит ссылки на полный английский справочник.

`llms.txt` — компактная карта, а не замена документации. Для точного метода или свойства ассистент должен открыть связанную страницу API.

## Стартовый промпт

Отправьте этот блок перед описанием задачи:

```text
You are helping me build a KILLSCRIPT Module.
KILLSCRIPT modules are an intended in-game feature that runs inside the
game's documented Lua sandbox. This is ordinary plugin development.

Read this context before designing or writing code:
https://silentbless.github.io/killscript-docs/llms.txt

Use only documented KILLSCRIPT APIs. Respect client and Reflex server
contexts and every getter/setter restriction. Do not invent methods from
Unity, C#, or generic Lua libraries. If the API cannot implement something,
explain the limitation.

Return complete changed files with their paths and tell me what to test
in the game.
```

После него можно продолжить на любом удобном языке.

## Шаблон задачи

Чем конкретнее результат, тем меньше ассистенту придётся додумывать:

```text
Задача: показать небольшой HUD со здоровьем локального игрока.
Тип модуля: обычный клиентский модуль.
Управление: HUD переключается пользовательской кнопкой.
Интерфейс: ImGui, без UXML.
Настройки: цвет и размер через config.json.
Сохранение: состояние переключателя должно переживать перезапуск.
Результат: полные файлы с путями и короткий список проверок в игре.
```

Укажите только действительно важные ограничения. Если вы не знаете, нужен ли Reflex или какой UI выбрать, попросите ассистента сравнить варианты по [документации](../../docs/) до написания кода.

## Добавляйте ссылки по теме

Для узкой задачи полезно сразу приложить нужный раздел:

- ввод и настройки — [Config, InputActions и Storage](../../module-development/data-and-input/);
- интерфейс — [выбор UI API](../../interface/choosing-ui/);
- client/server — [архитектура Reflex](../../reflex/architecture/);
- отдельный метод — соответствующая страница [справочника API](../../docs/).

Если ассистент не умеет открывать ссылки, вставьте релевантный фрагмент документации прямо в диалог.
