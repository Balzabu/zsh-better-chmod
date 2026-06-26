# zsh-better-chmod

A Zsh plugin that enhances the `chmod` command with input validation, colored
output, and support for both symbolic (`-rwxr-xr--`) and octal (`755`)
permission formats, including setuid, setgid and sticky bits.

By default it installs a dedicated `bchmod` command and leaves the system
`chmod` untouched. You can opt in to override `chmod` itself, in which case it
behaves as a strict superset of the real command: every standard flag keeps its
meaning, and any input it does not specifically enhance is passed through to
`command chmod` unchanged.

<p align="center">
  <img src="https://github.com/Balzabu/zsh-better-chmod/blob/main/screenshot.png?raw=true">
</p>

## Features

- Symbolic (`-rwxr-xr--` / `drwxr-xr--`) and octal (`755`) input formats.
- Setuid, setgid and sticky bits in symbolic form (`-rwsr-xr-x` produces `4755`).
- Input validation with colored status indicators.
- Colors are disabled automatically when stdout is not a terminal, so no ANSI
  escape codes end up in pipes, logs or redirected output.
- Standard flags keep their exact meaning; unrecognized input is delegated to
  `command chmod`.
- Works on GNU/Linux and BSD/macOS (`stat` and `--version` are detected at
  runtime).
- Follows the [Zsh Plugin Standard](https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html):
  autoloaded function, `$fpath` integration, compatible with every plugin
  manager.

## Installation

### Oh My Zsh

1. Clone into Oh My Zsh's custom plugins directory:
   ```bash
   git clone https://github.com/Balzabu/zsh-better-chmod \
     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-better-chmod"
   ```
2. Add it to the plugin list in `~/.zshrc`:
   ```bash
   plugins=(... zsh-better-chmod)
   ```

### zinit
```bash
zinit light Balzabu/zsh-better-chmod
```

### antidote
```bash
# add to ~/.zsh_plugins.txt
Balzabu/zsh-better-chmod
```

### zplug
```bash
zplug "Balzabu/zsh-better-chmod"
```

### zgenom
```bash
zgenom load Balzabu/zsh-better-chmod
```

### Antigen
```bash
antigen bundle Balzabu/zsh-better-chmod
```

### Manual
```bash
git clone https://github.com/Balzabu/zsh-better-chmod ~/.zsh/zsh-better-chmod
echo 'source ~/.zsh/zsh-better-chmod/zsh-better-chmod.plugin.zsh' >> ~/.zshrc
```

## Configuration

By default the plugin provides `bchmod` and does not touch `chmod`. The
`bchmod` command is always available regardless of this setting.

| Variable | Default | Effect |
| --- | --- | --- |
| `ZSH_BETTER_CHMOD_OVERRIDE` | `0` | Set to `1` to also alias `chmod` to the enhanced command |

```bash
# In ~/.zshrc, before the plugin is loaded:
ZSH_BETTER_CHMOD_OVERRIDE=1
```

## Usage

```bash
# Symbolic format for files
bchmod -rwxr-xr-- file.txt
✓ file.txt → 754 (-rwxr-xr--)

# Symbolic format for directories
bchmod drwxr-x--- dir/
✓ dir/ → 750 (drwxr-x---)

# Setuid, setgid and sticky bits
bchmod -rwsr-xr-x script
✓ script → 4755 (-rwsr-xr-x)

# Standard octal format
bchmod 755 file.txt
✓ file.txt → 755 (-rwxr-xr-x)

# Everything the real chmod does keeps working, unchanged:
bchmod -R 755 directory/
bchmod -h 644 symlink            # -h is no-dereference, not help
bchmod u+x,g-w file              # operator syntax is delegated to chmod
bchmod --reference=a.txt b.txt

# Help and version
bchmod --help
bchmod --version
```

With `ZSH_BETTER_CHMOD_OVERRIDE=1` you can type `chmod` directly instead of
`bchmod`.

## Permission format reference

### Symbolic (`-rwxr-xr--` or `drwxr-xr--`)

- First char: type indicator, `-` (file) or `d` (directory).
- Chars 2 to 4: user permissions.
- Chars 5 to 7: group permissions.
- Chars 8 to 10: others permissions.

| Char | Meaning |
| --- | --- |
| `r` | read (4) |
| `w` | write (2) |
| `x` | execute (1) |
| `s` / `S` | setuid (user) or setgid (group), with or without execute |
| `t` / `T` | sticky (others), with or without execute |
| `-` | no permission |

### Octal (for example `755` or `4755`)

Each digit is the sum of `4` (read), `2` (write) and `1` (execute). An optional
leading fourth digit encodes special bits: `4` setuid, `2` setgid, `1` sticky.

## Compatibility

- Zsh 5.x and newer.
- GNU/Linux and BSD/macOS (`stat` and `--version` are detected at runtime).
- Works standalone or with any plugin manager (Oh My Zsh, zinit, antidote,
  zplug, zgenom, Antigen).

## Development

```bash
zsh -n zsh-better-chmod.plugin.zsh   # syntax check
zsh tests/test.zsh                   # run the test suite
```

CI runs the suite on Linux and macOS. See `.github/workflows/ci.yml`.

## License

MIT. See [LICENSE](LICENSE).
