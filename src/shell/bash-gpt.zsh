# bash-gpt.zsh - ZLE widgets for always-on English-to-bash suggestions
# Similar to zsh-autosuggestions, shows grayed-out hints that can be accepted with Tab/Right Arrow

# State file location
BASH_GPT_STATE_FILE="${TMPDIR:-/tmp}/bash-gpt-state"

# Store the current suggestion
typeset -g _BASH_GPT_SUGGESTION=""
typeset -g _BASH_GPT_PENDING=""

# Debounce timer
typeset -g _BASH_GPT_TIMER_PID=""

# Check if bash-gpt is enabled
_bash_gpt_enabled() {
    [[ -f "$BASH_GPT_STATE_FILE" ]] && [[ "$(cat "$BASH_GPT_STATE_FILE" 2>/dev/null)" == "on" ]]
}

# Clear the current suggestion
_bash_gpt_clear() {
    _BASH_GPT_SUGGESTION=""
    POSTDISPLAY=""
}

# Display the suggestion as grayed-out text
_bash_gpt_display() {
    if [[ -n "$_BASH_GPT_SUGGESTION" ]] && [[ "$_BASH_GPT_SUGGESTION" != "$BUFFER" ]]; then
        # Show the suggestion after the cursor
        POSTDISPLAY="${_BASH_GPT_SUGGESTION:${#BUFFER}}"
    else
        POSTDISPLAY=""
    fi
}

# Async suggestion fetcher
_bash_gpt_fetch_async() {
    local input="$1"
    local result

    # Call bash-gpt with --suggest flag for quick response
    result=$(bash-gpt --suggest "$input" 2>/dev/null)

    if [[ -n "$result" ]] && [[ "$result" != "$input" ]]; then
        echo "$result"
    fi
}

# Request a suggestion (debounced)
_bash_gpt_suggest_async() {
    # Kill any pending suggestion request
    if [[ -n "$_BASH_GPT_TIMER_PID" ]]; then
        kill "$_BASH_GPT_TIMER_PID" 2>/dev/null
        _BASH_GPT_TIMER_PID=""
    fi

    local buffer="$BUFFER"

    # Skip if buffer is empty or too short
    [[ ${#buffer} -lt 8 ]] && return

    # Store pending query
    _BASH_GPT_PENDING="$buffer"

    # Debounce: wait 500ms before fetching
    {
        sleep 0.5

        # Check if input changed during debounce
        if [[ "$_BASH_GPT_PENDING" != "$buffer" ]]; then
            exit 0
        fi

        # Fetch suggestion
        local suggestion
        suggestion=$(_bash_gpt_fetch_async "$buffer")

        if [[ -n "$suggestion" ]]; then
            # Write suggestion to a temp file for the main process to read
            echo "$suggestion" > "${TMPDIR:-/tmp}/bash-gpt-suggestion-$$"
            kill -USR1 $$ 2>/dev/null
        fi
    } &!

    _BASH_GPT_TIMER_PID=$!
}

# Signal handler to update suggestion
_bash_gpt_update_suggestion() {
    local suggestion_file="${TMPDIR:-/tmp}/bash-gpt-suggestion-$$"
    if [[ -f "$suggestion_file" ]]; then
        _BASH_GPT_SUGGESTION=$(cat "$suggestion_file")
        rm -f "$suggestion_file"
        _bash_gpt_display
        zle -R
    fi
}

# Wrapped self-insert widget
_bash_gpt_self_insert() {
    zle .self-insert

    if _bash_gpt_enabled; then
        _bash_gpt_clear
        _bash_gpt_suggest_async
    fi
}

# Wrapped backward-delete-char widget
_bash_gpt_backward_delete_char() {
    zle .backward-delete-char

    if _bash_gpt_enabled; then
        _bash_gpt_clear
        _bash_gpt_suggest_async
    fi
}

# Accept suggestion with Tab or Right Arrow
_bash_gpt_accept() {
    if [[ -n "$_BASH_GPT_SUGGESTION" ]] && [[ "$_BASH_GPT_SUGGESTION" != "$BUFFER" ]]; then
        BUFFER="$_BASH_GPT_SUGGESTION"
        CURSOR=${#BUFFER}
        _bash_gpt_clear
    else
        # Default behavior: expand-or-complete for Tab
        zle expand-or-complete
    fi
}

# Accept suggestion with Right Arrow (only if at end of line)
_bash_gpt_forward_char() {
    if [[ $CURSOR -eq ${#BUFFER} ]] && [[ -n "$_BASH_GPT_SUGGESTION" ]] && [[ "$_BASH_GPT_SUGGESTION" != "$BUFFER" ]]; then
        BUFFER="$_BASH_GPT_SUGGESTION"
        CURSOR=${#BUFFER}
        _bash_gpt_clear
    else
        zle .forward-char
    fi
}

# Clear suggestion on Enter
_bash_gpt_accept_line() {
    _bash_gpt_clear
    zle .accept-line
}

# Set up signal handler
trap '_bash_gpt_update_suggestion' USR1

# Create and bind widgets
zle -N self-insert _bash_gpt_self_insert
zle -N backward-delete-char _bash_gpt_backward_delete_char
zle -N _bash_gpt_accept
zle -N _bash_gpt_forward_char
zle -N accept-line _bash_gpt_accept_line

# Bind keys
bindkey '^I' _bash_gpt_accept           # Tab
bindkey '^[[C' _bash_gpt_forward_char   # Right arrow

# Cleanup function for when the shell exits
_bash_gpt_cleanup() {
    rm -f "${TMPDIR:-/tmp}/bash-gpt-suggestion-$$" 2>/dev/null
    if [[ -n "$_BASH_GPT_TIMER_PID" ]]; then
        kill "$_BASH_GPT_TIMER_PID" 2>/dev/null
    fi
}

trap '_bash_gpt_cleanup' EXIT
