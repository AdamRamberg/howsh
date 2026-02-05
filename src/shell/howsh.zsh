# howsh.zsh - ZLE widgets for always-on English-to-bash suggestions
# Uses region_highlight (like zsh-autosuggestions) for compatibility

# State file location
HOWSH_STATE_FILE="${TMPDIR:-/tmp}/howsh-state"
HOWSH_SUGGESTION_FILE="${TMPDIR:-/tmp}/howsh-suggestion-$$"

# Highlight style (gray/dim text)
: ${HOWSH_HIGHLIGHT_STYLE:='fg=8'}

# Store the current suggestion
typeset -g _HOWSH_SUGGESTION=""
typeset -g _HOWSH_LAST_BUFFER=""
typeset -g _HOWSH_WAITING=0

# Check if howsh is enabled
_howsh_enabled() {
    [[ -f "$HOWSH_STATE_FILE" ]] && [[ "$(cat "$HOWSH_STATE_FILE" 2>/dev/null)" == "on" ]]
}

# Clear the current suggestion
_howsh_clear() {
    _HOWSH_SUGGESTION=""
    BUFFER="${BUFFER%% → *}"  # Remove any appended suggestion
}

# Display the suggestion using BUFFER + region_highlight
_howsh_display() {
    if [[ -n "$_HOWSH_SUGGESTION" ]] && [[ "$_HOWSH_SUGGESTION" != "$BUFFER" ]]; then
        local orig_len=${#BUFFER}
        local suffix

        if [[ "$_HOWSH_SUGGESTION" == "$BUFFER"* ]]; then
            # Suggestion continues what user typed - append the rest
            suffix=${_HOWSH_SUGGESTION:${#BUFFER}}
        else
            # Full replacement - show after arrow
            suffix=" → ${_HOWSH_SUGGESTION}"
        fi

        BUFFER="${BUFFER}${suffix}"
        region_highlight+=("$orig_len $((orig_len + ${#suffix})) $HOWSH_HIGHLIGHT_STYLE")
    fi
}

# Check for suggestion file (does NOT display)
_howsh_check_suggestion() {
    if [[ -f "$HOWSH_SUGGESTION_FILE" ]]; then
        local suggestion
        IFS= read -r suggestion < "$HOWSH_SUGGESTION_FILE" 2>/dev/null
        rm -f "$HOWSH_SUGGESTION_FILE" 2>/dev/null
        _HOWSH_WAITING=0

        if [[ -n "$suggestion" ]]; then
            _HOWSH_SUGGESTION=$suggestion
            return 0
        fi
    fi
    return 1
}

# Check for suggestion and display it
_howsh_check_and_display() {
    if _howsh_check_suggestion; then
        # Clean buffer and display
        BUFFER="${BUFFER%% → *}"
        _howsh_display
        return 0
    fi
    return 1
}

# Request a suggestion in background
_howsh_suggest_async() {
    local buffer="${BUFFER%% → *}"  # Get clean buffer without suggestion

    # Skip if buffer is empty or too short
    [[ ${#buffer} -lt 8 ]] && return

    # Skip if buffer hasn't changed
    [[ "$buffer" == "$_HOWSH_LAST_BUFFER" ]] && return
    _HOWSH_LAST_BUFFER="$buffer"
    _HOWSH_WAITING=1

    # Clean up old suggestion file
    rm -f "$HOWSH_SUGGESTION_FILE" 2>/dev/null

    # Fetch suggestion in background
    {
        local result
        result=$(howsh --suggest "$buffer" 2>/dev/null)

        if [[ -n "$result" ]] && [[ "$result" != "$buffer" ]]; then
            print -r -- "$result" > "$HOWSH_SUGGESTION_FILE"
        fi
    } &!
}

# Wrapped self-insert widget
_howsh_self_insert() {
    # Remove any existing suggestion from buffer before inserting
    BUFFER="${BUFFER%% → *}"

    # Also remove completion suffix if suggestion was inline
    if [[ -n "$_HOWSH_SUGGESTION" ]] && [[ "$BUFFER" == *"$_HOWSH_SUGGESTION"* ]]; then
        BUFFER="${BUFFER%${_HOWSH_SUGGESTION:${#_HOWSH_LAST_BUFFER}}}"
    fi

    _HOWSH_SUGGESTION=""
    zle .self-insert

    if _howsh_enabled; then
        _howsh_check_and_display || _howsh_suggest_async
    fi
}

# Wrapped backward-delete-char widget
_howsh_backward_delete_char() {
    BUFFER="${BUFFER%% → *}"
    if [[ -n "$_HOWSH_SUGGESTION" ]]; then
        BUFFER="${BUFFER%${_HOWSH_SUGGESTION:${#_HOWSH_LAST_BUFFER}}}"
    fi
    _HOWSH_SUGGESTION=""

    zle .backward-delete-char

    if _howsh_enabled; then
        _howsh_check_and_display || _howsh_suggest_async
    fi
}

# Accept suggestion with Tab
_howsh_accept() {
    # Check for any pending suggestion (don't display, just load)
    _howsh_check_suggestion

    if [[ -n "$_HOWSH_SUGGESTION" ]]; then
        # Clear buffer completely and set to suggestion
        BUFFER=""
        BUFFER=$_HOWSH_SUGGESTION
        CURSOR=${#BUFFER}
        _HOWSH_LAST_BUFFER=$BUFFER
        _HOWSH_SUGGESTION=""
        region_highlight=()
    else
        zle expand-or-complete
    fi
}

# Accept suggestion with Right Arrow (only if at end of line)
_howsh_forward_char() {
    _howsh_check_suggestion

    local clean_buffer="${BUFFER%% → *}"
    if [[ $CURSOR -ge ${#clean_buffer} ]] && [[ -n "$_HOWSH_SUGGESTION" ]]; then
        BUFFER=""
        BUFFER=$_HOWSH_SUGGESTION
        CURSOR=${#BUFFER}
        _HOWSH_LAST_BUFFER=$BUFFER
        _HOWSH_SUGGESTION=""
        region_highlight=()
    else
        zle .forward-char
    fi
}

# Clear suggestion on Enter
_howsh_accept_line() {
    # Clean buffer before executing
    BUFFER="${BUFFER%% → *}"
    if [[ -n "$_HOWSH_SUGGESTION" ]]; then
        BUFFER="${BUFFER%${_HOWSH_SUGGESTION:${#_HOWSH_LAST_BUFFER}}}"
    fi
    _HOWSH_SUGGESTION=""
    _HOWSH_LAST_BUFFER=""
    _HOWSH_WAITING=0
    zle .accept-line
}

# Polling widget for async updates
_howsh_poll() {
    if (( _HOWSH_WAITING )) && _howsh_enabled; then
        if _howsh_check_and_display; then
            zle -R
        fi
    fi
}

# Create widgets
zle -N self-insert _howsh_self_insert
zle -N backward-delete-char _howsh_backward_delete_char
zle -N _howsh_accept
zle -N _howsh_forward_char
zle -N accept-line _howsh_accept_line
zle -N _howsh_poll

# Bind keys
bindkey '^I' _howsh_accept           # Tab
bindkey '^[[C' _howsh_forward_char   # Right arrow

# Periodic polling using TMOUT
TMOUT=1
TRAPALRM() {
    if (( _HOWSH_WAITING )); then
        zle _howsh_poll 2>/dev/null
    fi
}

# Cleanup
_howsh_cleanup() {
    rm -f "$HOWSH_SUGGESTION_FILE" 2>/dev/null
}
trap '_howsh_cleanup' EXIT
