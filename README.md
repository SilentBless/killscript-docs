# KILLSCRIPT Docs

Двуязычная документация по Lua API игры KILLSCRIPT на базе Astro Starlight.

Русская версия является исходной. Английская страница создаётся только после проверки и завершения соответствующей русской страницы. Непроверенный API не публикуется.

## Локальная разработка

Требуется Node.js 22.12 или новее.

```sh
npm install
npm run dev
```

Проверка перед коммитом:

```sh
npm run verify
```

## Структура контента

- `src/content/docs/` — основная русская документация;
- `src/content/docs/en/` — английский перевод;
- `src/styles/` — стили сайта;
- `.github/workflows/` — проверка и публикация GitHub Pages.

Одинаковые страницы RU и EN должны иметь одинаковый относительный путь. Например:

```text
src/content/docs/api/camera.md
src/content/docs/en/api/camera.md
```

## Публикация

Push в ветку `master` запускает сборку и публикацию на GitHub Pages:

<https://silentbless.github.io/killscript-docs/>

## Коммиты

```text
[site] initialize Astro Starlight
[docs] add verified Camera reference
[i18n] add English Camera translation
[fix] correct Camera.IsMainCamera access
[ci] configure GitHub Pages deployment
```
