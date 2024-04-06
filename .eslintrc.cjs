/* eslint-disable import/no-extraneous-dependencies, @typescript-eslint/no-var-requires */

/** @type {import('eslint').Linter.Config} */
const config = {
  extends: ['@bensaufley', require.resolve('@bensaufley/eslint-config/preact.cjs')],
  rules: {
    'implicit-arrow-linebreak': 'off',
  },
  overrides: [
    {
      files: ['*.jsx', '*.tsx'],
      parserOptions: {
        jsx: true,
      },
    },
  ],
};

module.exports = config;
