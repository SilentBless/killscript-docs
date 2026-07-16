// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://silentbless.github.io',
	base: '/killscript-docs',
	integrations: [
		starlight({
			title: 'KILLSCRIPT Docs',
			description: 'Lua API, модули и практические руководства для KILLSCRIPT.',
			favicon: '/favicon.svg',
			defaultLocale: 'root',
			locales: {
				root: {
					label: 'Русский',
					lang: 'ru',
				},
				en: {
					label: 'English',
					lang: 'en',
				},
			},
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/SilentBless/killscript-docs',
				},
			],
			editLink: {
				baseUrl: 'https://github.com/SilentBless/killscript-docs/edit/master/',
			},
			lastUpdated: true,
			customCss: ['./src/styles/custom.css'],
			sidebar: [
				{ slug: 'docs' },
				{
					label: 'Начало работы',
					translations: { en: 'Getting started' },
					collapsed: true,
					items: [
						{ slug: 'getting-started/overview' },
						{ slug: 'getting-started/first-module' },
						{ slug: 'getting-started/first-reflex-module' },
						{ slug: 'getting-started/module-structure' },
						{ slug: 'getting-started/workflow' },
						{ slug: 'getting-started/packages' },
					],
				},
				{
					label: 'Вайбкодинг',
					translations: { en: 'Vibe coding' },
					collapsed: true,
					items: [
						{ slug: 'vibe-coding/overview' },
						{ slug: 'vibe-coding/context' },
						{ slug: 'vibe-coding/workflow' },
					],
				},
				{
					label: 'Разработка модулей',
					translations: { en: 'Module development' },
					collapsed: true,
					items: [
						{ slug: 'module-development/editor' },
						{ slug: 'module-development/code-organization' },
						{ slug: 'module-development/data-and-input' },
						{ slug: 'module-development/assets' },
					],
				},
				{
					label: 'Интерфейсные руководства',
					translations: { en: 'Interface guides' },
					collapsed: true,
					items: [
						{ slug: 'interface/choosing-ui' },
						{ slug: 'interface/imgui-hud' },
						{ slug: 'interface/uxml-interface' },
						{ slug: 'interface/interactive-ui' },
					],
				},
				{
					label: 'Reflex-модули',
					translations: { en: 'Reflex modules' },
					collapsed: true,
					items: [
						{ slug: 'reflex/architecture' },
						{ slug: 'reflex/network-protocol' },
						{ slug: 'reflex/server-loop' },
						{ slug: 'reflex/complete-module' },
					],
				},
				{
					label: 'Практические рецепты',
					translations: { en: 'Practical recipes' },
					collapsed: true,
					items: [
						{ slug: 'recipes/toggle-action' },
						{ slug: 'recipes/persistent-state' },
						{ slug: 'recipes/ally-labels' },
						{ slug: 'recipes/camera-preview' },
					],
				},
				{
					label: 'Пользовательские серверы',
					translations: { en: 'Custom servers' },
					collapsed: true,
					items: [
						{ slug: 'servers/custom-server' },
						{ slug: 'servers/commands' },
					],
				},
				{
					label: 'Справочник API',
					translations: { en: 'API reference' },
					collapsed: true,
					items: [
						{
							label: 'Базовые типы',
							translations: { en: 'Core types' },
							collapsed: true,
							items: [
								{ slug: 'api/array' },
								{ slug: 'api/color' },
								{ slug: 'api/rect' },
								{ slug: 'api/vector2' },
								{ slug: 'api/vector3' },
								{ slug: 'api/quaternion' },
							],
						},
						{
							label: 'Выполнение',
							translations: { en: 'Runtime' },
							collapsed: true,
							items: [{ slug: 'api/time' }, { slug: 'api/scheduler' }],
						},
						{
							label: 'Данные и ввод',
							translations: { en: 'Data and input' },
							collapsed: true,
							items: [
								{ slug: 'api/input-action' },
								{ slug: 'api/config' },
								{ slug: 'api/storage' },
								{ slug: 'api/localization' },
							],
						},
						{
							label: 'Окружение',
							translations: { en: 'Environment' },
							collapsed: true,
							items: [
								{ slug: 'api/cpu-limit' },
								{ slug: 'api/map-info' },
								{ slug: 'api/network-info' },
								{ slug: 'api/performance' },
								{ slug: 'api/screen' },
							],
						},
						{
							label: 'Графика',
							translations: { en: 'Graphics' },
							collapsed: true,
							items: [{ slug: 'api/camera' }, { slug: 'api/texture' }],
						},
						{
							label: 'Игровой мир',
							translations: { en: 'Game world' },
							collapsed: true,
							items: [
								{ slug: 'api/agent' },
								{ slug: 'api/item' },
								{ slug: 'api/entity' },
								{ slug: 'api/game-config' },
								{ slug: 'api/shop' },
							],
						},
						{
							label: 'Матч и сеть',
							translations: { en: 'Match and networking' },
							collapsed: true,
							items: [
								{ slug: 'api/network' },
								{ slug: 'api/defusal-game' },
								{ slug: 'api/team' },
								{ slug: 'api/physics' },
								{ slug: 'api/combat-log' },
							],
						},
						{
							label: 'Отображение и общение',
							translations: { en: 'Presentation and communication' },
							collapsed: true,
							items: [
								{ slug: 'api/audio' },
								{ slug: 'api/world-visuals' },
								{ slug: 'api/notification' },
								{ slug: 'api/chat' },
							],
						},
						{
							label: 'Интерфейс',
							translations: { en: 'Interface' },
							collapsed: true,
							items: [
								{ slug: 'api/imgui' },
								{
									label: 'UI',
									collapsed: true,
									items: [
										{ slug: 'api/ui' },
										{ slug: 'api/ui-elements' },
										{ slug: 'api/ui-style' },
										{ slug: 'api/ui-animation' },
									],
								},
							],
						},
					],
				},
				{
					label: 'TypeScript (экспериментально)',
					translations: { en: 'TypeScript (experimental)' },
					collapsed: true,
					items: [{ slug: 'typescript/overview' }],
				},
			],
		}),
	],
});
