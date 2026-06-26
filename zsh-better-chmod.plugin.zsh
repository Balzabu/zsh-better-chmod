# zsh-better-chmod.plugin.zsh
#
# Enhanced chmod with symbolic/octal input, validation and colored output.
# Author:  Balzabu  (https://github.com/Balzabu/zsh-better-chmod)
# License: MIT
# Version: 1.1.0
#
# Configuration (export before the plugin is loaded):
#   ZSH_BETTER_CHMOD_OVERRIDE=1   # also alias `chmod` to the enhanced command
#
# By default the plugin installs the `bchmod` command and leaves the system
# `chmod` untouched. When the override is enabled it is a transparent, strict
# superset of the real command: every standard flag keeps its meaning and any
# unrecognized input is delegated to `command chmod`.

# --- Standard $0 handling (Zsh Plugin Standard) ----------------------------
# Resolve an absolute path to this file regardless of how it was sourced.
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# --- Register functions/ on $fpath and autoload the function ---------------
if [[ ${zsh_loaded_plugins[-1]} != */zsh-better-chmod \
   && -z ${fpath[(r)${0:h}/functions]} ]]; then
    fpath+=( "${0:h}/functions" )
fi
autoload -Uz chmod_extended

# --- Dedicated command, always available -----------------------------------
alias bchmod='chmod_extended'

# --- Optional transparent override of `chmod` (default: off) ---------------
if [[ ${ZSH_BETTER_CHMOD_OVERRIDE:-0} == 1 ]]; then
    alias chmod='chmod_extended'
    # Keep `chmod`'s native completion working through the wrapper.
    if (( $+functions[compdef] )); then
        compdef chmod_extended=chmod
    fi
fi
