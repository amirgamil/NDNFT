module.exports = {
    env: {
        browser: false,
        es2021: true,
        mocha: true,
        node: true,
    },
    extends: ["eslint:recommended"],
    parser: "@typescript-eslint/parser",
    parserOptions: {
        ecmaVersion: 12,
    },
    rules: {
        "node/no-unsupported-features/es-syntax": [
            "error",
            { ignores: ["modules"] },
        ],
    },
};
