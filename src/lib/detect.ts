// Natural language indicators (prepositions, articles, common phrases)
const ENGLISH_PATTERNS = /\b(at|in|on|with|the|all|that|are|which|from|into|named|called|containing|larger|smaller|older|newer|than|find|list|show|delete|remove|create|make|copy|move|search|get|display|count|sort|filter)\b/i;

// Pure bash patterns (pipes, redirections, flags at start, paths)
const PURE_BASH = /(\||>|>>|<|&&|\|\||;\s*$|^\.\/|^\.\.\/)|(^[a-z]+\s+-[a-zA-Z])/;

// Common bash-only commands that are unlikely to be part of English sentences
const BASH_COMMANDS = /^(ls|cd|pwd|cat|head|tail|grep|sed|awk|chmod|chown|mkdir|rmdir|touch|cp|mv|rm|echo|export|source|alias|which|whereis|man|sudo|apt|yum|brew|npm|yarn|bun|git|docker|kubectl|curl|wget)\s*$/;

export function looksLikeEnglish(input: string): boolean {
  const trimmed = input.trim();

  // Too short - wait for more input
  if (trimmed.length < 8) return false;

  // Single bash command without args - not English
  if (BASH_COMMANDS.test(trimmed)) return false;

  // Clear bash syntax (pipes, redirections) - don't suggest
  if (PURE_BASH.test(trimmed)) return false;

  // Has English patterns and spaces - likely English!
  // "kill app at port 3000" → true (has "at")
  // "find files larger than 100mb" → true (has "larger than")
  return ENGLISH_PATTERNS.test(trimmed) && trimmed.includes(' ');
}

export function isAlreadyBash(input: string): boolean {
  const trimmed = input.trim();

  // Has clear bash syntax
  if (PURE_BASH.test(trimmed)) return true;

  // Starts with common commands followed by flags or paths
  if (/^(ls|cd|cat|grep|find|chmod|mkdir|rm|cp|mv|echo|tar|git|docker|npm|yarn|bun)\s+[-\/\.]/.test(trimmed)) {
    return true;
  }

  return false;
}
