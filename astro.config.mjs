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
				{
					label: 'Документация',
					translations: { en: 'Documentation' },
					items: [{ slug: 'docs' }],
				},
				{
					label: 'Справочник API',
					translations: { en: 'API reference' },
					items: [
						{
							label: 'Базовые типы',
							translations: { en: 'Core types' },
							collapsed: false,
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
							collapsed: false,
							items: [{ slug: 'api/time' }, { slug: 'api/scheduler' }],
						},
						{
							label: 'Графика',
							translations: { en: 'Graphics' },
							collapsed: false,
							items: [{ slug: 'api/camera' }, { slug: 'api/texture' }],
						},
					],
				},
			],
		}),
	],
});
