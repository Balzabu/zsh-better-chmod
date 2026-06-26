#!/usr/bin/env zsh
# Test suite for zsh-better-chmod. Run with: zsh tests/test.zsh
emulate -L zsh
setopt local_options

# Resolve repo root *before* sourcing the plugin (sourcing rewrites $0).
local here="${0:A:h}"
local root="${here:h}"

# Load the plugin. The override is off by default; the in-process tests call
# chmod_extended directly, so they do not rely on the chmod alias.
source "$root/zsh-better-chmod.plugin.zsh"
autoload -Uz chmod_extended

# --- tiny assertion harness ------------------------------------------------
typeset -i pass=0 fail=0
typeset -a failed

_ok()  { (( pass++ )); print -r -- "  ok   - $1"; }
_no()  { (( fail++ )); failed+=("$1"); print -r -- "  FAIL - $1 :: $2"; }

assert_eq() {  # desc expected actual
    [[ "$2" == "$3" ]] && _ok "$1" || _no "$1" "expected [$2] got [$3]"
}
assert_has() { # desc haystack needle
    [[ "$2" == *"$3"* ]] && _ok "$1" || _no "$1" "[$3] not found"
}
assert_hasnt() { # desc haystack needle
    [[ "$2" != *"$3"* ]] && _ok "$1" || _no "$1" "[$3] unexpectedly present"
}

# Portable octal-mode reader that keeps the special bits (setuid/setgid/sticky).
# GNU `stat -c %a` already yields e.g. 4755 or 644. BSD/macOS `stat -f %Lp`
# drops the special bits, so read the full mode with `%p` (e.g. 104755) and keep
# the last four octal digits.
if stat -c '%a' . >/dev/null 2>&1; then
    _statmode() { stat -c '%a' "$1"; }
else
    _statmode() { local m; m="$(stat -f '%p' "$1")"; print -r -- "${m[-4,-1]}"; }
fi
mode() {
    local m="$(_statmode "$1")"
    [[ "$m" == 0[0-7][0-7][0-7] ]] && m="${m#0}"   # 0644 -> 644
    print -r -- "$m"
}

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

print -r -- "zsh-better-chmod tests"
print -r -- "----------------------"

# 1. octal
touch "$work/f1"
out="$(chmod_extended 640 "$work/f1")"
assert_eq  "octal 640 sets mode"            "640"  "$(mode "$work/f1")"
assert_has "octal output shows arrow"       "$out" "→"

# 2. symbolic file -> octal
touch "$work/f2"
chmod_extended -rwxr-xr-- "$work/f2" >/dev/null
assert_eq  "symbolic -rwxr-xr-- => 754"     "754"  "$(mode "$work/f2")"

# 3. symbolic directory
mkdir "$work/d1"
chmod_extended drwxr-x--- "$work/d1" >/dev/null
assert_eq  "symbolic drwxr-x--- => 750"     "750"  "$(mode "$work/d1")"

# 4. special bits: setuid
touch "$work/f3"
chmod_extended -rwsr-xr-x "$work/f3" >/dev/null
assert_eq  "setuid -rwsr-xr-x => 4755"      "4755" "$(mode "$work/f3")"

# 5. special bits: setgid
touch "$work/f4"
chmod_extended -rwxr-sr-x "$work/f4" >/dev/null
assert_eq  "setgid -rwxr-sr-x => 2755"      "2755" "$(mode "$work/f4")"

# 6. THE BUG FIX: -h must NOT be hijacked as help; --help must show help
help_out="$(chmod_extended --help)"
assert_has   "--help shows usage"           "$help_out" "Enhanced permission formats"
h_out="$(chmod_extended -h 2>&1)"
assert_hasnt "-h is NOT treated as help"    "$h_out"    "Enhanced permission formats"

# 7. THE BUG FIX: recursive symbolic on a directory must not be rejected
mkdir -p "$work/tree/sub"
touch "$work/tree/a" "$work/tree/sub/b"
rout="$(chmod_extended -R -rwxr-xr-x "$work/tree" 2>&1)"
assert_hasnt "recursive symbolic not rejected" "$rout" "Not a regular file"
assert_eq    "recursive applies inside tree"   "755"   "$(mode "$work/tree/sub/b")"

# 8. TTY-aware: no ANSI escapes when output is captured (not a tty)
touch "$work/f5"
cout="$(chmod_extended 600 "$work/f5")"
assert_hasnt "no ANSI escapes when piped"   "$cout" $'\e['

# 9. fallback: unsupported symbolic op delegates to real chmod
touch "$work/f6"; command chmod 644 "$work/f6"
chmod_extended u+x "$work/f6" >/dev/null 2>&1
assert_eq  "fallback u+x on 644 => 744"     "744"  "$(mode "$work/f6")"

# 10. missing file is reported in symbolic mode
mout="$(chmod_extended -rw-r--r-- "$work/does-not-exist" 2>&1)"
assert_has "missing file reported"          "$mout" "File not found"

# 11. dedicated bchmod alias exists
assert_has "bchmod alias defined"           "$(alias bchmod 2>/dev/null)" "chmod_extended"

# 12. --version prints the plugin version
vout="$(chmod_extended --version)"
assert_has "version prints plugin version"  "$vout" "zsh-better-chmod 1.1.0"

# 13. chmod is NOT overridden by default
def="$(zsh -c "source '$root/zsh-better-chmod.plugin.zsh'; alias chmod 2>/dev/null; print END")"
assert_hasnt "chmod not overridden by default" "$def" "chmod_extended"

# 14. override is opt-in via ZSH_BETTER_CHMOD_OVERRIDE=1
on="$(ZSH_BETTER_CHMOD_OVERRIDE=1 zsh -c "source '$root/zsh-better-chmod.plugin.zsh'; alias chmod 2>/dev/null")"
assert_has  "override=1 aliases chmod"         "$on" "chmod_extended"

# --- summary ---------------------------------------------------------------
print -r -- "----------------------"
print -r -- "passed: $pass   failed: $fail"
if (( fail > 0 )); then
    print -r -- "failing: ${(j:, :)failed}"
    exit 1
fi
exit 0
