<div align="center">

# asdf-claude-code [![Build](https://github.com/wguilherme/asdf-claude-code/actions/workflows/build.yml/badge.svg)](https://github.com/wguilherme/asdf-claude-code/actions/workflows/build.yml) [![Lint](https://github.com/wguilherme/asdf-claude-code/actions/workflows/lint.yml/badge.svg)](https://github.com/wguilherme/asdf-claude-code/actions/workflows/lint.yml)

[Claude Code](https://claude.ai/code) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- Optional: `jq` for better JSON parsing (checksum verification works without it too).

# Install

Plugin:

```shell
asdf plugin add claude-code
# or
asdf plugin add claude-code https://github.com/wguilherme/asdf-claude-code.git
```

claude-code:

```shell
# Show all installable versions
asdf list-all claude-code

# Install specific version
asdf install claude-code latest

# Set a version globally (on your ~/.tool-versions file)
asdf global claude-code latest

# Now claude-code commands are available
claude --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/wguilherme/asdf-claude-code/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Witney Guilherme](https://github.com/wguilherme/)
