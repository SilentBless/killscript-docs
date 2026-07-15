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
					items: [{ slug: 'api/array' }, { slug: 'api/camera' }, { slug: 'api/texture' }],
				},
			],
		}),
	],
});
