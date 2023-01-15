/* eslint-disable import/no-extraneous-dependencies, @typescript-eslint/no-var-requires */

/** @type {import('eslint').Linter.Config} */
const config = {
  extends: 'airbnb-typescript-prettier',
  plugins: ['simple-import-sort', 'import', 'prefer-arrow-functions'],
  rules: {
    'no-restricted-imports': [
      'error',
      {
        paths: [
          {
            name: 'wouter-preact',
            importNames: ['Link'],
            message: 'Use <Link> from ~shared/components/Link instead',
          },
        ],
      },
    ],
    'no-plusplus': 'off',
    'no-underscore-dangle': 'off',
    'prefer-const': ['error', { destructuring: 'all' }],

    // Preact 'h' is injected by Vite
    'react/react-in-jsx-scope': 'off',
    'react/function-component-definition': [
      'error',
      {
        namedComponents: 'arrow-function',
        unnamedComponents: 'arrow-function',
      },
    ],
    'react/require-default-props': 'off',
    'react/jsx-props-no-spreading': 'off',

    '@typescript-eslint/no-non-null-assertion': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-unused-vars': [
      'error',
      { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
    ],
    // TSX files require …extends unknown inside generics to avoid
    // confusion with JSX syntax; this rule is not configurable, so
    // we disable it.
    '@typescript-eslint/no-unnecessary-type-constraint': 'off',
    '@typescript-eslint/ban-ts-comment': 'off',

    'import/first': 'error',
    'import/newline-after-import': 'error',
    'import/no-duplicates': 'error',
    'prefer-arrow-functions/prefer-arrow-functions': [
      'warn',
      {
        classPropertiesAllowed: true,
        disallowPrototype: true,
        returnStyle: 'implicit',
        singleReturnOnly: false,
      },
    ],
    'import/order': 'off',
    'simple-import-sort/imports': [
      'error',
      {
        groups: [
          ['^\\u0000'],
          ['^@?\\w'],
          ['^~(?!.*\\.module\\.css$)'],
          ['^\\.\\./(?!.*\\.module\\.css$)'],
          ['^\\./(?!.*\\.module\\.css$)', '^\\.$'],
          ['^~.*\\.module\\.css', '\\.module\\.css$'],
        ],
      },
    ],
    'simple-import-sort/exports': 'error',
  },
  settings: {
    'import/parsers': {
      '@typescript-eslint/parser': ['.ts', '.tsx'],
    },
    'import/resolver': {
      typescript: { project: './tsconfig.json' },
    },
    react: {
      pragma: 'h',
      version: '18.2.0',
    },
  },
};

module.exports = config;
