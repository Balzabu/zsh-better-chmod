# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.1.0] - 2026-06-26

### Fixed
- `-h` is no longer treated as "help". It is the standard `--no-dereference`
  flag, valid on both GNU and BSD/macOS. Help is shown only on `--help`.
- Octal mode no longer breaks on BSD/macOS. `stat` and `--version` are detected
  at runtime (GNU `stat -c %A` vs BSD `stat -f %Sp`).
- Recursive symbolic changes (`chmod -R -rwxr-xr-x dir/`) are no longer rejected
  by the file or directory type check.
- Colored output and Unicode markers are suppressed when stdout is not a
  terminal, so raw ANSI escapes no longer appear in pipes, logs or redirects.
- `.gitignore` no longer ignores `README.md`, `LICENSE` and `screenshot.png`.
- Oh My Zsh install instructions now use `$ZSH_CUSTOM/plugins` instead of the
  core plugins directory.

### Added
- Setuid, setgid and sticky bits in symbolic input (`-rwsr-xr-x` produces `4755`).
- Dedicated `bchmod` command, always available. `chmod` is left untouched by
  default; set `ZSH_BETTER_CHMOD_OVERRIDE=1` to also alias `chmod`.
- Conformance to the Zsh Plugin Standard: autoloaded function in `functions/`,
  `$0` and `$fpath` handling, `compdef` to preserve completion.
- Test suite (`tests/test.zsh`) and CI on Linux and macOS.
- Install instructions for zinit, antidote, zplug and zgenom.

### Changed
- The `chmod` override is now a strict superset. Any input the plugin does not
  enhance is passed through to `command chmod` unchanged.

## [1.0.0]

- Initial release: symbolic and octal input formats with colored output.
