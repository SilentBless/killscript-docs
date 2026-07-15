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
			description: 'Проверенная документация по Lua API игры KILLSCRIPT.',
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
					label: 'О документации',
					translations: { en: 'About the docs' },
					items: [{ slug: 'about/verification' }],
				},
			],
		}),
	],
});
