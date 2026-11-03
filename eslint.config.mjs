import tseslint from "@typescript-eslint/eslint-plugin";
import parser from "@typescript-eslint/parser";
import prettier from "eslint-config-prettier";

export default [
  { ignores: ["**/dist/**", "**/node_modules/**", "apps/api/scaffold/**"] },
  {
    files: ["**/*.{ts,tsx}"],
    languageOptions: { parser, parserOptions: { projectService: true } },
    plugins: { "@typescript-eslint": tseslint },
    rules: { ...tseslint.configs.recommended.rules },
  },
  prettier,
];
