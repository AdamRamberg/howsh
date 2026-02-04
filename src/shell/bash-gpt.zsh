# bash-gpt.zsh - ZLE widgets for always-on English-to-bash suggestions
# Uses region_highlight (like zsh-autosuggestions) for compatibility

# State file location
BASH_GPT_STATE_FILE="${TMPDIR:-/tmp}/bash-gpt-state"
BASH_GPT_SUGGESTION_FILE="${TMPDIR:-/tmp}/bash-gpt-suggestion-$$"

# Highlight style (gray/dim text)
: ${BASH_GPT_HIGHLIGHT_STYLE:='fg=8'}

# Store the current suggestion
typeset -g _BASH_GPT_SUGGESTION=""
typeset -g _BASH_GPT_LAST_BUFFER=""
typeset -g _BASH_GPT_WAITING=0

# Check if bash-gpt is enabled
_bash_gpt_enabled() {
    [[ -f "$BASH_GPT_STATE_FILE" ]] && [[ "$(cat "$BASH_GPT_STATE_FILE" 2>/dev/null)" == "on" ]]
}

# Clear the current suggestion
_bash_gpt_clear() {
    _BASH_GPT_SUGGESTION=""
    BUFFER="${BUFFER%% → *}"  # Remove any appended suggestion
}

# Display the suggestion using BUFFER + region_highlight
_bash_gpt_display() {
    if [[ -n "$_BASH_GPT_SUGGESTION" ]] && [[ "$_BASH_GPT_SUGGESTION" != "$BUFFER" ]]; then
        local orig_len=${#BUFFER}
        local suffix

        if [[ "$_BASH_GPT_SUGGESTION" == "$BUFFER"* ]]; then
            # Suggestion continues what user typed - append the rest
            suffix=${_BASH_GPT_SUGGESTION:${#BUFFER}}
        else
            # Full replacement - show after arrow
            suffix=" → ${_BASH_GPT_SUGGESTION}"
        fi

        BUFFER="${BUFFER}${suffix}"
        region_highlight+=("$orig_len $((orig_len + ${#suffix})) $BASH_GPT_HIGHLIGHT_STYLE")
    fi
}

# Check for suggestion file (does NOT display)
_bash_gpt_check_suggestion() {
    if [[ -f "$BASH_GPT_SUGGESTION_FILE" ]]; then
        local suggestion
        IFS= read -r suggestion < "$BASH_GPT_SUGGESTION_FILE" 2>/dev/null
        rm -f "$BASH_GPT_SUGGESTION_FILE" 2>/dev/null
        _BASH_GPT_WAITING=0

        if [[ -n "$suggestion" ]]; then
            _BASH_GPT_SUGGESTION=$suggestion
            return 0
        fi
    fi
    return 1
}

# Check for suggestion and display it
_bash_gpt_check_and_display() {
    if _bash_gpt_check_suggestion; then
        # Clean buffer and display
        BUFFER="${BUFFER%% → *}"
        _bash_gpt_display
        return 0
    fi
    return 1
}

# Request a suggestion in background
_bash_gpt_suggest_async() {
    local buffer="${BUFFER%% → *}"  # Get clean buffer without suggestion

    # Skip if buffer is empty or too short
    [[ ${#buffer} -lt 8 ]] && return

    # Skip if buffer hasn't changed
    [[ "$buffer" == "$_BASH_GPT_LAST_BUFFER" ]] && return
    _BASH_GPT_LAST_BUFFER="$buffer"
    _BASH_GPT_WAITING=1

    # Clean up old suggestion file
    rm -f "$BASH_GPT_SUGGESTION_FILE" 2>/dev/null

    # Fetch suggestion in background
    {
        local result
        result=$(bash-gpt --suggest "$buffer" 2>/dev/null)

        if [[ -n "$result" ]] && [[ "$result" != "$buffer" ]]; then
            print -r -- "$result" > "$BASH_GPT_SUGGESTION_FILE"
        fi
    } &!
}

# Wrapped self-insert widget
_bash_gpt_self_insert() {
    # Remove any existing suggestion from buffer before inserting
    BUFFER="${BUFFER%% → *}"

    # Also remove completion suffix if suggestion was inline
    if [[ -n "$_BASH_GPT_SUGGESTION" ]] && [[ "$BUFFER" == *"$_BASH_GPT_SUGGESTION"* ]]; then
        BUFFER="${BUFFER%${_BASH_GPT_SUGGESTION:${#_BASH_GPT_LAST_BUFFER}}}"
    fi

    _BASH_GPT_SUGGESTION=""
    zle .self-insert

    if _bash_gpt_enabled; then
        _bash_gpt_check_and_display || _bash_gpt_suggest_async
    fi
}

# Wrapped backward-delete-char widget
_bash_gpt_backward_delete_char() {
    BUFFER="${BUFFER%% → *}"
    if [[ -n "$_BASH_GPT_SUGGESTION" ]]; then
        BUFFER="${BUFFER%${_BASH_GPT_SUGGESTION:${#_BASH_GPT_LAST_BUFFER}}}"
    fi
    _BASH_GPT_SUGGESTION=""

    zle .backward-delete-char

    if _bash_gpt_enabled; then
        _bash_gpt_check_and_display || _bash_gpt_suggest_async
    fi
}

# Accept suggestion with Tab
_bash_gpt_accept() {
    # Check for any pending suggestion (don't display, just load)
    _bash_gpt_check_suggestion

    if [[ -n "$_BASH_GPT_SUGGESTION" ]]; then
        # Clear buffer completely and set to suggestion
        BUFFER=""
        BUFFER=$_BASH_GPT_SUGGESTION
        CURSOR=${#BUFFER}
        _BASH_GPT_LAST_BUFFER=$BUFFER
        _BASH_GPT_SUGGESTION=""
        region_highlight=()
    else
        zle expand-or-complete
    fi
}

# Accept suggestion with Right Arrow (only if at end of line)
_bash_gpt_forward_char() {
    _bash_gpt_check_suggestion

    local clean_buffer="${BUFFER%% → *}"
    if [[ $CURSOR -ge ${#clean_buffer} ]] && [[ -n "$_BASH_GPT_SUGGESTION" ]]; then
        BUFFER=""
        BUFFER=$_BASH_GPT_SUGGESTION
        CURSOR=${#BUFFER}
        _BASH_GPT_LAST_BUFFER=$BUFFER
        _BASH_GPT_SUGGESTION=""
        region_highlight=()
    else
        zle .forward-char
    fi
}

# Clear suggestion on Enter
_bash_gpt_accept_line() {
    # Clean buffer before executing
    BUFFER="${BUFFER%% → *}"
    if [[ -n "$_BASH_GPT_SUGGESTION" ]]; then
        BUFFER="${BUFFER%${_BASH_GPT_SUGGESTION:${#_BASH_GPT_LAST_BUFFER}}}"
    fi
    _BASH_GPT_SUGGESTION=""
    _BASH_GPT_LAST_BUFFER=""
    _BASH_GPT_WAITING=0
    zle .accept-line
}

# Polling widget for async updates
_bash_gpt_poll() {
    if (( _BASH_GPT_WAITING )) && _bash_gpt_enabled; then
        if _bash_gpt_check_and_display; then
            zle -R
        fi
    fi
}

# Create widgets
zle -N self-insert _bash_gpt_self_insert
zle -N backward-delete-char _bash_gpt_backward_delete_char
zle -N _bash_gpt_accept
zle -N _bash_gpt_forward_char
zle -N accept-line _bash_gpt_accept_line
zle -N _bash_gpt_poll

# Bind keys
bindkey '^I' _bash_gpt_accept           # Tab
bindkey '^[[C' _bash_gpt_forward_char   # Right arrow

# Periodic polling using TMOUT
TMOUT=1
TRAPALRM() {
    if (( _BASH_GPT_WAITING )); then
        zle _bash_gpt_poll 2>/dev/null
    fi
}

# Cleanup
_bash_gpt_cleanup() {
    rm -f "$BASH_GPT_SUGGESTION_FILE" 2>/dev/null
}
trap '_bash_gpt_cleanup' EXIT
