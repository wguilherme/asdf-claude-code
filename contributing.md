# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

asdf plugin test claude-code https://github.com/wguilherme/asdf-claude-code.git "claude --version"
```

Tests are automatically run in GitHub Actions on push and PR.
