---
title: Imports and packages
description: Folder modules, .KillScript files, Import, Fork, and safe distribution.
---

The `.KillScript` format is a ready-to-install single-file package. It contains module metadata, Lua code, and assets inside one file.

:::caution[It is not a Lua file]
`Module.KillScript` is not a standalone text script with a custom extension. It is a packaged module with the same internal structure as a folder project.
:::

## Folder or package

| | Folder module | `.KillScript` |
|---|---|---|
| Purpose | Development and editing | Installation and distribution |
| Location | `Modules/MyModule/` | `Modules/MyModule.KillScript` |
| Source hot reload | Yes | No |
| Open in a text editor | Yes | No |
| Contains `module.json` | Yes | Yes, inside the package |

## Import a .KillScript file

1. Open the module menu.
2. Select **Import**.
3. Choose a `.KillScript` file.
4. Enable the imported module.
5. Enter a game session and check the console for errors.

The game copies the package into its `Modules` directory. If a file with the same name exists, the new import receives an available name with a numeric suffix.

## When you have a source folder

The **Import** dialog expects `.KillScript`, so it cannot select a directory. Copy the complete project directory directly into the game's module directory:

```text
KILLSCRIPT Pre-Alpha/
└── Modules/
    └── MyModule/
        ├── module.json
        └── scripts/
            └── main.lua
```

Return to the module menu afterward. The game scans direct subdirectories of `Modules` as folder projects.

## Fork an existing module

Use **Fork** when you want to modify an installed or built-in module. The game creates a separate editable folder copy with its own metadata. Edit that copy without changing the original package.

After the fork:

1. set a clear name and author;
2. verify the new `Id`;
3. open the copy through **Folder** or **VS Code**;
4. disable the original if both modules cover the same feature.

## Required package structure

The package root must contain `module.json`. Other paths match the [folder structure](../module-structure/):

```text
module.json
scripts/main.lua
scripts/server.lua      # Reflex only
config.json             # optional
inputs.json             # optional
images/...
sounds/...
ui/...
```

Simply renaming a `.zip` or `.lua` file to `.KillScript` does not guarantee a valid package. The game validates its structure and metadata during import.

## Before distribution

- remove temporary and unnecessary large files;
- verify the name, author, version, description, and tags;
- test the module after a clean installation;
- do not include secrets, tokens, or local data;
- state whether the module is Reflex and which modules may conflict with it.
