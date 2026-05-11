#!/usr/bin/env zsh

# --- Terminal helpers (Bubble Tea–style UX, pure zsh) ---
_section() {
    print ""
    print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print "  $1"
    print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

_status() {
    print "[*] $1"
}

_warn() {
    print "[!] $1"
}

_err() {
    print "[ERROR] $1" >&2
}

# Restore cursor visibility; call on exit / interrupt
_brew_menu_cleanup() {
    printf '\033[?25h' 2>/dev/null
    stty sane 2>/dev/null
}

# Load Homebrew into PATH when it exists but shellenv was not sourced (fresh login scripts).
_homebrew_prepare_path() {
    if command -v brew >/dev/null 2>&1; then
        return 0
    fi
    local brew_exe
    for brew_exe in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$brew_exe" ]]; then
            eval "$("$brew_exe" shellenv)"
            return 0
        fi
    done
    return 1
}

# True when brew is installed and responds (skip official installer).
_homebrew_is_available() {
    command -v brew >/dev/null 2>&1 && brew --version >/dev/null 2>&1
}

# Dotbot / IDE often run with stdin not connected to the keyboard; attach real TTY for prompts.
_cask_ensure_interactive_stdin() {
    [[ -t 0 ]] && return 0
    [[ -r /dev/tty ]] || return 1
    exec 0</dev/tty
}

# Tokens for one picker category (cask names and/or mas:<id> from brew/casks.zsh).
_cask_tokens_for_category() {
    emulate -L zsh
    typeset -ga __cask_tokens_reply
    __cask_tokens_reply=()
    local cat=$1
    eval "__cask_tokens_reply=( \"\${BREW_CASKS_${cat}[@]}\" )"
}

# Bracket for category header: [ ] none, [x] all, [~] partial
_cask_header_bracket() {
    emulate -L zsh
    local cat=$1
    local -a cs
    _cask_tokens_for_category "$cat"
    cs=( "${__cask_tokens_reply[@]}" )
    local n=${#cs[@]} on=0 c
    (( n == 0 )) && { print -n "[ ]"; return }
    for c in "${cs[@]}"; do
        (( __cask_sel[$c] )) && (( on++ ))
    done
    (( on == 0 )) && { print -n "[ ]"; return }
    (( on == n )) && { print -n "[x]"; return }
    print -n "[~]"
}

# Build flat menu lines: CAT:slug | ASK:slug:caskToken
_cask_build_menu_lines() {
    emulate -L zsh
    typeset -ga __cask_menu_lines
    __cask_menu_lines=()
    local cat c
    for cat in "${BREW_CASK_CATEGORY_ORDER[@]}"; do
        __cask_menu_lines+=( "CAT:$cat" )
        _cask_tokens_for_category "$cat"
        for c in "${__cask_tokens_reply[@]}"; do
            __cask_menu_lines+=( "ASK:$cat:$c" )
        done
    done
}

# TTY nested cask picker. Sets global typeset -A __cask_sel (token -> 0|1). Returns 1 on quit.
_cask_nested_multiselect() {
    emulate -L zsh
    typeset -gA __cask_sel=()
    _cask_build_menu_lines
    local n=${#__cask_menu_lines[@]}
    if (( n == 0 )); then
        return 0
    fi

    local cursor=0 key k1 k2 j
    local line mark box hdr indent label
    local H=${LINES:-32}
    local max_vis=$(( H - 10 ))
    (( max_vis < 8 )) && max_vis=8

    trap '_brew_menu_cleanup' INT EXIT
    stty -echo -icanon min 1 time 0 2>/dev/null || true
    printf '\033[?25l' 2>/dev/null

    while true; do
        printf '\033[2J\033[H'
        print "  Casks & Mac App Store (nested — finetune per app)"
        print "  ─────────────────────────"
        print ""
        local start=$(( cursor - max_vis / 2 ))
        (( start < 0 )) && start=0
        (( start > n - max_vis )) && start=$(( n - max_vis ))
        (( start < 0 )) && start=0

        for (( j = start; j < start + max_vis && j < n; j++ )); do
            line=${__cask_menu_lines[j + 1]}
            mark=" "
            (( j == cursor )) && mark=">"
            if [[ $line == CAT:* ]]; then
                local slug=${line#CAT:}
                label="${BREW_CASK_CATEGORY_LABEL[$slug]:-$slug}"
                hdr=$(_cask_header_bracket "$slug")
                print "  $mark$hdr  $label"
            else
                # ASK:slug:token
                local rest=${line#ASK:}
                local slug=${rest%%:*}
                local tok=${rest#*:}
                (( __cask_sel[$tok] )) && box="[x]" || box="[ ]"
                if [[ $tok == bundle:dev ]]; then
                    print "  $mark$box      Brewfile.dev — brew formulae + VS Code extensions"
                elif [[ $tok == mas:* ]]; then
                    local mid=${tok#mas:}
                    label="${BREW_MAS_NAME[$mid]:-App $mid}"
                    print "  $mark$box      $label  (MAS ${mid})"
                else
                    print "  $mark$box      $tok"
                fi
            fi
        done
        if (( n > max_vis )); then
            print ""
            print "  … scroll $(( start + 1 ))–$(( j )) of $n (move cursor to scroll)"
        fi
        print ""
        print "  ↑/k · ↓/j move   space toggle row (category toggles all)   enter confirm   q quit"
        print ""

        if ! read -k key; then
            _brew_menu_cleanup
            trap - INT EXIT
            printf '\033[?25h' 2>/dev/null
            stty sane 2>/dev/null
            print "[!] Cannot read the keyboard. Run in Terminal.app or: zsh ~/.dotfiles/setup_homebrew.zsh" >&2
            __cask_sel=()
            return 2
        fi

        case $key in
            $'\n'|$'\r')
                break
                ;;
            ' '|$'\t')
                line=${__cask_menu_lines[cursor + 1]}
                if [[ $line == CAT:* ]]; then
                    local slug=${line#CAT:}
                    local -a cs
                    _cask_tokens_for_category "$slug"
                    cs=( "${__cask_tokens_reply[@]}" )
                    local all=1
                    for tok in "${cs[@]}"; do
                        (( __cask_sel[$tok] )) || all=0
                    done
                    if (( all )); then
                        for tok in "${cs[@]}"; do
                            __cask_sel[$tok]=0
                        done
                    else
                        for tok in "${cs[@]}"; do
                            __cask_sel[$tok]=1
                        done
                    fi
                else
                    rest=${line#ASK:}
                    tok=${rest#*:}
                    (( __cask_sel[$tok] )) && __cask_sel[$tok]=0 || __cask_sel[$tok]=1
                fi
                ;;
            'k'|'K')
                (( cursor > 0 )) && (( cursor-- ))
                ;;
            'j'|'J')
                (( cursor < n - 1 )) && (( cursor++ ))
                ;;
            'q'|'Q')
                _brew_menu_cleanup
                trap - INT EXIT
                __cask_sel=()
                return 1
                ;;
            $'\e')
                read -k k1 -t 0.05 2>/dev/null || true
                read -k k2 -t 0.05 2>/dev/null || true
                if [[ $k1 == '[' ]]; then
                    case $k2 in
                        A) (( cursor > 0 )) && (( cursor-- )) ;;
                        B) (( cursor < n - 1 )) && (( cursor++ )) ;;
                    esac
                fi
                ;;
        esac
    done

    printf '\033[?25h' 2>/dev/null
    stty sane 2>/dev/null
    trap - INT EXIT
    return 0
}

# Line-based y/N per cask (reads from /dev/tty when stdin is not the keyboard)
_cask_nested_multiselect_plain() {
    emulate -L zsh
    typeset -gA __cask_sel=()
    local cat c r
    local tty_in=/dev/stdin
    [[ -r /dev/tty ]] && tty_in=/dev/tty
    for cat in "${BREW_CASK_CATEGORY_ORDER[@]}"; do
        print ""
        print "── ${BREW_CASK_CATEGORY_LABEL[$cat]:-$cat} ──"
        _cask_tokens_for_category "$cat"
        local -a cs=( "${__cask_tokens_reply[@]}" )
        for c in "${cs[@]}"; do
            if [[ $c == bundle:dev ]]; then
                print "Run brew bundle for Brewfile.dev (CLI + VS Code extensions)? (y/N)"
            elif [[ $c == mas:* ]]; then
                local mid=${c#mas:}
                print "Install Mac App Store \"${BREW_MAS_NAME[$mid]:-$mid}\" (id $mid)? (y/N)"
            else
                print "Install cask \"$c\"? (y/N)"
            fi
            if ! read -r r <"$tty_in"; then
                _warn "Input ended before cask selection finished — remaining casks left unselected."
                return 0
            fi
            [[ "$r" =~ ^[yY]$ ]] && __cask_sel[$c]=1 || __cask_sel[$c]=0
        done
    done
    return 0
}

_brewfile_has_bundle_entries() {
    [[ -f "$1" ]] && grep -qE '^[[:space:]]*(brew|cask|vscode|mas|tap)[[:space:]]' "$1"
}

# Development profile (~/.dev_setup_enabled): set here so ./install can link dev files afterward.
_section "Development profile"
DEV_SETUP_ENABLED=0
if [[ -t 0 ]] || [[ -r /dev/tty ]]; then
    _cask_ensure_interactive_stdin 2>/dev/null || true
    print "Controls ~/.dev_setup_enabled (zsh loads ~/.zshrc.dev when present)."
    print "When you run ./install, Dotbot links VS Code settings and ~/.zshrc.dev after this step if the file exists."
    print ""
    print "Enable development setup? (y/N)"
    local _dev_ans
    if [[ -t 0 ]]; then
        read -r _dev_ans
    else
        read -r _dev_ans </dev/tty
    fi
    if [[ "$_dev_ans" =~ ^[yY]$ ]]; then
        touch "$HOME/.dev_setup_enabled"
        DEV_SETUP_ENABLED=1
        _status "Development setup: ENABLED (~/.dev_setup_enabled)"
    else
        rm -f "$HOME/.dev_setup_enabled"
        _status "Development setup: DISABLED (removed ~/.dev_setup_enabled if it existed)"
    fi
else
    [[ -f "$HOME/.dev_setup_enabled" ]] && DEV_SETUP_ENABLED=1
    if (( DEV_SETUP_ENABLED )); then
        _status "Non-interactive session: keeping existing ~/.dev_setup_enabled (dev ON)."
    else
        _status "Non-interactive session: no ~/.dev_setup_enabled (dev OFF)."
    fi
fi

# Only install NVM if development setup is enabled
if [ "$DEV_SETUP_ENABLED" = "1" ]; then
    _section "Setup NVM"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi

_section "Starting Homebrew"
_homebrew_prepare_path
if _homebrew_is_available; then
    _status "Homebrew already installed ($(command -v brew)); skipping installer."
else
    _status "Running official Homebrew installer…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    _homebrew_prepare_path
    if ! _homebrew_is_available; then
        _err "Homebrew is still not on PATH or not working. Add brew to your shell (e.g. eval \"\$(/opt/homebrew/bin/brew shellenv)\") and re-run this script."
        exit 1
    fi
fi

# Ensure the 'brew' directory exists for Brewfiles
local_brew_dir="$(dirname "$0")/brew"
mkdir -p "$local_brew_dir"

_section "Homebrew taps (prerequisites)"
if [[ -f "$local_brew_dir/Brewfile.taps" ]]; then
    _status "Installing taps from Brewfile.taps"
    brew bundle --verbose --file "$local_brew_dir/Brewfile.taps" || { _err "Error installing taps. Exiting."; exit 1; }
else
    _warn "Brewfile.taps not found at '$local_brew_dir/Brewfile.taps'. Skipping tap installation."
fi

# Cask catalog (categories + per-cask lists). Edit brew/casks.zsh to finetune.
if [[ -f "$local_brew_dir/casks.zsh" ]]; then
    . "$local_brew_dir/casks.zsh"
    # Prepend Brewfile.dev as its own category when dev setup is on (single row token bundle:dev).
    if [[ "$DEV_SETUP_ENABLED" = "1" ]] && [[ ${+BREW_CASK_CATEGORY_ORDER} -eq 1 ]]; then
        typeset -ga BREW_CASK_CATEGORY_ORDER
        BREW_CASK_CATEGORY_ORDER=(brewfile_dev "${BREW_CASK_CATEGORY_ORDER[@]}")
        typeset -A BREW_CASK_CATEGORY_LABEL
        BREW_CASK_CATEGORY_LABEL[brewfile_dev]="Development CLI (Brewfile.dev)"
        typeset -ga BREW_CASKS_brewfile_dev
        BREW_CASKS_brewfile_dev=(bundle:dev)
    fi
else
    _warn "Missing brew/casks.zsh — cask picker skipped."
fi

_section "CLI formulae (Brewfile.essential)"
if [[ -f "$local_brew_dir/Brewfile.essential" ]] && _brewfile_has_bundle_entries "$local_brew_dir/Brewfile.essential"; then
    _status "brew bundle --file Brewfile.essential"
    brew bundle --verbose --file "$local_brew_dir/Brewfile.essential" || _warn "Brewfile.essential reported errors (continuing)."
else
    _warn "Skipping Brewfile.essential (missing or empty)."
fi

if [[ "$DEV_SETUP_ENABLED" != "1" ]]; then
    _status "Brewfile.dev is not listed in the picker (development profile disabled above)."
fi

if [[ -f "$local_brew_dir/Brewfile.others" ]] && _brewfile_has_bundle_entries "$local_brew_dir/Brewfile.others"; then
    _section "Optional extra bundle (Brewfile.others)"
    brew bundle --verbose --file "$local_brew_dir/Brewfile.others" || _warn "Brewfile.others reported errors (continuing)."
fi

_section "Apps & bundles (picker)"
typeset -a __casks_to_install=()
if [[ ${+BREW_CASK_CATEGORY_ORDER} -eq 1 ]] && (( ${#BREW_CASK_CATEGORY_ORDER[@]} > 0 )); then
    # So Dotbot / Cursor runs still get prompts: reopen stdin from the controlling terminal when possible.
    _cask_ensure_interactive_stdin 2>/dev/null || true

    if [[ -t 0 && -t 1 ]]; then
        print "Toggle rows (with dev: Brewfile.dev = CLI + VS Code extensions). Space / Enter as before."
        print ""
        _cask_nested_multiselect
        case $? in
            1)
                _warn "Quit from picker — no bundles or GUI apps will be installed."
                ;;
            2)
                typeset -gA __cask_sel=()
                _warn "Cask UI could not read keys — falling back to y/N prompts on /dev/tty."
                _cask_nested_multiselect_plain
                ;;
        esac
    else
        _warn "Full-screen cask UI needs stdin and stdout on a terminal; using y/N prompts (input from /dev/tty when available)."
        _cask_nested_multiselect_plain
    fi

    cat=""
    tok=""
    _cask_toks=()
    for cat in "${BREW_CASK_CATEGORY_ORDER[@]}"; do
        _cask_tokens_for_category "$cat"
        for tok in "${__cask_tokens_reply[@]}"; do
            (( __cask_sel[$tok] )) && __casks_to_install+=( "$tok" )
        done
    done

    if (( ${#__casks_to_install[@]} > 0 )); then
        _section "Installing selected (${#__casks_to_install[@]})"
        typeset -a _only_casks=() _only_mas=()
        typeset -gi __run_dev_bundle=0
        for tok in "${__casks_to_install[@]}"; do
            if [[ $tok == bundle:dev ]]; then
                __run_dev_bundle=1
            elif [[ $tok == mas:* ]]; then
                _only_mas+=( "${tok#mas:}" )
            else
                _only_casks+=( "$tok" )
            fi
        done
        if (( __run_dev_bundle )); then
            if [[ -f "$local_brew_dir/Brewfile.dev" ]] && _brewfile_has_bundle_entries "$local_brew_dir/Brewfile.dev"; then
                _status "brew bundle --file Brewfile.dev"
                brew bundle --verbose --file "$local_brew_dir/Brewfile.dev" || _warn "Brewfile.dev reported errors (continuing)."
            else
                _warn "Brewfile.dev missing or empty — cannot run bundle."
            fi
        fi
        if (( ${#_only_casks[@]} > 0 )); then
            _status "brew install --cask …"
            brew install --cask "${_only_casks[@]}" || _warn "Some casks may have failed; check brew output above."
        fi
        if (( ${#_only_mas[@]} > 0 )); then
            if command -v mas >/dev/null 2>&1; then
                _status "mas install …"
                mas install "${_only_mas[@]}" || _warn "Some MAS installs may have failed (sign in to App Store / check mas output)."
            else
                _warn "Selected Mac App Store apps but 'mas' is not on PATH (add brew \"mas\" / run bundle essential first)."
            fi
        fi
    else
        _warn "Nothing selected — skipping Brewfile.dev bundle, brew install --cask, and mas install."
    fi
else
    _warn "Cask catalog not loaded — skipping cask installs."
fi

_section "Default file extensions (duti)"
duti "$(dirname "$0")/extensions.duti" || _warn "'extensions.duti' not found or 'duti' command failed."

_section "Homebrew setup complete"
print ""
