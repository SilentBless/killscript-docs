---
title: How we verify the documentation
description: Verification and publishing rules for the KILLSCRIPT documentation.
---

The KILLSCRIPT documentation is based on the Lua API's actual in-game behavior. The existing Russian documentation is treated as a checklist of candidates to test, not as an unquestionable source of truth.

## What verified means

For every property and method, we confirm:

- its actual name and type;
- read and write access: `get`, `set`, or `get/set`;
- execution context, including Client, Server, Reflex, and other restrictions;
- accepted arguments and return value;
- observed behavior and Lua bridge errors;
- that the published example works.

## Publishing workflow

1. Review the existing Russian material.
2. Create a minimal diagnostic module.
3. Run the test in the game and record the result.
4. Write the corrected Russian page.
5. Test the complete example again.
6. Translate the finished page into English.
7. Publish both versions.

## Confirmed material only

We do not publish unverified API pages, speculative signatures, or broken examples. Sections may therefore appear gradually: accuracy matters more than the number of pages.

If a game update changes the behavior, the affected section will be verified again.
