---
name: nuxt-eslint-typescript-setup
description: Workaround for @nuxt/eslint not auto-detecting TypeScript, causing vue-eslint-parser to fail on <script lang="ts"> blocks
---

# @nuxt/eslint TypeScript Setup Gotcha

## Problem

When adding `@nuxt/eslint` to a Nuxt 3 project, ESLint fails to parse TypeScript in Vue SFCs with errors like:

```
Parsing error: Unexpected token {
```

This happens because `@nuxt/eslint` does NOT auto-detect TypeScript. Without explicit configuration, `features.typescript` defaults to `false`, and `vue-eslint-parser` never gets `parserOptions.parser` set to `@typescript-eslint/parser`.

## Solution

Explicitly enable TypeScript in `nuxt.config.ts`:

```ts
export default defineNuxtConfig({
  modules: ['@nuxt/eslint'],

  eslint: {
    config: {
      typescript: true,
    },
  },
})
```

Then run `nuxt prepare` to regenerate `.nuxt/eslint.config.mjs`.

## Diagnosis

You can verify the issue by inspecting the generated config:

```bash
node --input-type=module -e "
import { options } from './.nuxt/eslint.config.mjs'
console.log('features:', JSON.stringify(options?.features, null, 2))
"
```

If `typescript: false`, that's the problem.

## Additional Notes

- `@nuxt/eslint` requires ESLint 9 (not 10). ESLint 10 causes peer dependency failures.
- Install `typescript-eslint` as a devDependency alongside `@nuxt/eslint`.
- Vue SFC `<!-- eslint-disable -->` comments placed before `<script>` do NOT cover the `<template>` block. Use global rule config or inline comments per usage instead.
