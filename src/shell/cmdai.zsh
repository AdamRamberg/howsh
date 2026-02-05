# cmdai.zsh - ZLE widgets for always-on English-to-bash suggestions
# Uses region_highlight (like zsh-autosuggestions) for compatibility

# State file location
CMDAI_STATE_FILE="${TMPDIR:-/tmp}/cmdai-state"
CMDAI_SUGGESTION_FILE="${TMPDIR:-/tmp}/cmdai-suggestion-$$"

# Highlight style (gray/dim text)
: ${CMDAI_HIGHLIGHT_STYLE:='fg=8'}

# Store the current suggestion
typeset -g _CMDAI_SUGGESTION=""
typeset -g _CMDAI_LAST_BUFFER=""
typeset -g _CMDAI_WAITING=0

# Check if cmdai is enabled
_cmdai_enabled() {
    [[ -f "$CMDAI_STATE_FILE" ]] && [[ "$(cat "$CMDAI_STATE_FILE" 2>/dev/null)" == "on" ]]
}

# Clear the current suggestion
_cmdai_clear() {
    _CMDAI_SUGGESTION=""
    BUFFER="${BUFFER%% → *}"  # Remove any appended suggestion
}

# Display the suggestion using BUFFER + region_highlight
_cmdai_display() {
    if [[ -n "$_CMDAI_SUGGESTION" ]] && [[ "$_CMDAI_SUGGESTION" != "$BUFFER" ]]; then
        local orig_len=${#BUFFER}
        local suffix

        if [[ "$_CMDAI_SUGGESTION" == "$BUFFER"* ]]; then
            # Suggestion continues what user typed - append the rest
            suffix=${_CMDAI_SUGGESTION:${#BUFFER}}
        else
            # Full replacement - show after arrow
            suffix=" → ${_CMDAI_SUGGESTION}"
        fi

        BUFFER="${BUFFER}${suffix}"
        region_highlight+=("$orig_len $((orig_len + ${#suffix})) $CMDAI_HIGHLIGHT_STYLE")
    fi
}

# Check for suggestion file (does NOT display)
_cmdai_check_suggestion() {
    if [[ -f "$CMDAI_SUGGESTION_FILE" ]]; then
        local suggestion
        IFS= read -r suggestion < "$CMDAI_SUGGESTION_FILE" 2>/dev/null
        rm -f "$CMDAI_SUGGESTION_FILE" 2>/dev/null
        _CMDAI_WAITING=0

        if [[ -n "$suggestion" ]]; then
            _CMDAI_SUGGESTION=$suggestion
            return 0
        fi
    fi
    return 1
}

# Check for suggestion and display it
_cmdai_check_and_display() {
    if _cmdai_check_suggestion; then
        # Clean buffer and display
        BUFFER="${BUFFER%% → *}"
        _cmdai_display
        return 0
    fi
    return 1
}

# Request a suggestion in background
_cmdai_suggest_async() {
    local buffer="${BUFFER%% → *}"  # Get clean buffer without suggestion

    # Skip if buffer is empty or too short
    [[ ${#buffer} -lt 8 ]] && return

    # Skip if buffer hasn't changed
    [[ "$buffer" == "$_CMDAI_LAST_BUFFER" ]] && return
    _CMDAI_LAST_BUFFER="$buffer"
    _CMDAI_WAITING=1

    # Clean up old suggestion file
    rm -f "$CMDAI_SUGGESTION_FILE" 2>/dev/null

    # Fetch suggestion in background
    {
        local result
        result=$(cmdai --suggest "$buffer" 2>/dev/null)

        if [[ -n "$result" ]] && [[ "$result" != "$buffer" ]]; then
            print -r -- "$result" > "$CMDAI_SUGGESTION_FILE"
        fi
    } &!
}

# Wrapped self-insert widget
_cmdai_self_insert() {
    # Remove any existing suggestion from buffer before inserting
    BUFFER="${BUFFER%% → *}"

    # Also remove completion suffix if suggestion was inline
    if [[ -n "$_CMDAI_SUGGESTION" ]] && [[ "$BUFFER" == *"$_CMDAI_SUGGESTION"* ]]; then
        BUFFER="${BUFFER%${_CMDAI_SUGGESTION:${#_CMDAI_LAST_BUFFER}}}"
    fi

    _CMDAI_SUGGESTION=""
    zle .self-insert

    if _cmdai_enabled; then
        _cmdai_check_and_display || _cmdai_suggest_async
    fi
}

# Wrapped backward-delete-char widget
_cmdai_backward_delete_char() {
    BUFFER="${BUFFER%% → *}"
    if [[ -n "$_CMDAI_SUGGESTION" ]]; then
        BUFFER="${BUFFER%${_CMDAI_SUGGESTION:${#_CMDAI_LAST_BUFFER}}}"
    fi
    _CMDAI_SUGGESTION=""

    zle .backward-delete-char

    if _cmdai_enabled; then
        _cmdai_check_and_display || _cmdai_suggest_async
    fi
}

# Accept suggestion with Tab
_cmdai_accept() {
    # Check for any pending suggestion (don't display, just load)
    _cmdai_check_suggestion

    if [[ -n "$_CMDAI_SUGGESTION" ]]; then
        # Clear buffer completely and set to suggestion
        BUFFER=""
        BUFFER=$_CMDAI_SUGGESTION
        CURSOR=${#BUFFER}
        _CMDAI_LAST_BUFFER=$BUFFER
        _CMDAI_SUGGESTION=""
        region_highlight=()
    else
        zle expand-or-complete
    fi
}

# Accept suggestion with Right Arrow (only if at end of line)
_cmdai_forward_char() {
    _cmdai_check_suggestion

    local clean_buffer="${BUFFER%% → *}"
    if [[ $CURSOR -ge ${#clean_buffer} ]] && [[ -n "$_CMDAI_SUGGESTION" ]]; then
        BUFFER=""
        BUFFER=$_CMDAI_SUGGESTION
        CURSOR=${#BUFFER}
        _CMDAI_LAST_BUFFER=$BUFFER
        _CMDAI_SUGGESTION=""
        region_highlight=()
    else
        zle .forward-char
    fi
}

# Clear suggestion on Enter
_cmdai_accept_line() {
    # Clean buffer before executing
    BUFFER="${BUFFER%% → *}"
    if [[ -n "$_CMDAI_SUGGESTION" ]]; then
        BUFFER="${BUFFER%${_CMDAI_SUGGESTION:${#_CMDAI_LAST_BUFFER}}}"
    fi
    _CMDAI_SUGGESTION=""
    _CMDAI_LAST_BUFFER=""
    _CMDAI_WAITING=0
    zle .accept-line
}

# Polling widget for async updates
_cmdai_poll() {
    if (( _CMDAI_WAITING )) && _cmdai_enabled; then
        if _cmdai_check_and_display; then
            zle -R
        fi
    fi
}

# Create widgets
zle -N self-insert _cmdai_self_insert
zle -N backward-delete-char _cmdai_backward_delete_char
zle -N _cmdai_accept
zle -N _cmdai_forward_char
zle -N accept-line _cmdai_accept_line
zle -N _cmdai_poll

# Bind keys
bindkey '^I' _cmdai_accept           # Tab
bindkey '^[[C' _cmdai_forward_char   # Right arrow

# Periodic polling using TMOUT
TMOUT=1
TRAPALRM() {
    if (( _CMDAI_WAITING )); then
        zle _cmdai_poll 2>/dev/null
    fi
}

# Cleanup
_cmdai_cleanup() {
    rm -f "$CMDAI_SUGGESTION_FILE" 2>/dev/null
}
trap '_cmdai_cleanup' EXIT
