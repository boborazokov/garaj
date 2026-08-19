const perfectionistRuleConfig = [
  'error',
  {
    order: 'asc',
    type: 'line-length',
  },
];

module.exports = [
  js.configs.recommended,

  {
    languageOptions: {
      parser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: './tsconfig.json',
      },
      globals: {
        Buffer: 'readonly',
        console: 'readonly',
      },
    },
    env: {
      node: true,
      es2021: true,
    },
    files: ['**/*.ts'],
    plugins: {
      '@typescript-eslint': typescript,
      perfectionist,
      import: importPlugin,
    },
    rules: {
      'perfectionist/sort-array-includes': perfectionistRuleConfig,
      'perfectionist/sort-exports': perfectionistRuleConfig,
      'perfectionist/sort-imports': perfectionistRuleConfig,
      'perfectionist/sort-enums': perfectionistRuleConfig,
      'perfectionist/sort-object-types': perfectionistRuleConfig,
      'perfectionist/sort-interfaces': perfectionistRuleConfig,
      'perfectionist/sort-jsx-props': perfectionistRuleConfig,
      'perfectionist/sort-objects': perfectionistRuleConfig,
      'perfectionist/sort-union-types': perfectionistRuleConfig,
      'perfectionist/sort-named-imports': perfectionistRuleConfig,
    },
  },

  {
    rules: {
      ...prettier.rules,
    },
  },
  {
    rules: {
      'no-unused-vars': 'off',
      '@typescript-eslint/no-unused-vars': [
        'warn',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
    },
  },
];
