module.exports = {
  plugins: ["prettier-plugin-solidity"],
  overrides: [
    { files: "*.sol", options: { printWidth: 100 } },
    { files: "*.ts", options: { semi: true, singleQuote: false } }
  ]
};
