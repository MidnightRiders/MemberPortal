/** @type {import('eslint').Linter.Config} */
const config = {
  extends: 'airbnb-typescript-prettier',
  plugins: ['simple-import-sort', 'import', 'prefer-arrow-functions'],
  rules: {
    'no-plusplus': 'off',
    // Preact 'h' is injected by Vite
    'react/react-in-jsx-scope': 'off',

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
    'simple-import-sort/imports': [
      'error',
      {
        groups: [
          ['^\\u0000'],
          ['^@?\\w'],
          ['^\\.\\./(?!.*\\.module\\.css$)'],
          ['^\\./(?!.*\\.module\\.css$)', '^\\.$'],
          [
            '^~(?!.*\\.module\\.css$)',
            '^~.*\\.module\\.css',
            '\\.module\\.css$',
          ],
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
