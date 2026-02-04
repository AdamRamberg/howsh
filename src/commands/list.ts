import chalk from 'chalk';
import { readFileSync, readdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Find cheatsheets directory - works both in dev and when installed
function findCheatsheetsDir(): string {
  const possiblePaths = [
    join(__dirname, '../../cheatsheets'),      // dev mode (src/commands/)
    join(__dirname, '../cheatsheets'),         // bundled (dist/)
    join(__dirname, 'cheatsheets'),            // alternative bundled layout
  ];

  for (const p of possiblePaths) {
    if (existsSync(p)) {
      return p;
    }
  }

  return possiblePaths[0]; // fallback
}

const CHEATSHEETS_DIR = findCheatsheetsDir();

interface CheatsheetEntry {
  name: string;
  path: string;
}

function getCheatsheets(): CheatsheetEntry[] {
  try {
    const files = readdirSync(CHEATSHEETS_DIR);
    return files
      .filter(f => f.endsWith('.md'))
      .map(f => ({
        name: f.replace('.md', ''),
        path: join(CHEATSHEETS_DIR, f)
      }));
  } catch {
    return [];
  }
}

function formatCheatsheet(content: string): string {
  return content
    .split('\n')
    .map(line => {
      // Format headers
      if (line.startsWith('# ')) {
        return chalk.bold.cyan(line.slice(2));
      }
      if (line.startsWith('## ')) {
        return '\n' + chalk.bold.yellow(line.slice(3));
      }
      if (line.startsWith('### ')) {
        return chalk.bold(line.slice(4));
      }
      // Format code blocks
      if (line.startsWith('```')) {
        return '';
      }
      // Format inline code
      if (line.includes('`')) {
        return line.replace(/`([^`]+)`/g, chalk.green('$1'));
      }
      // Format list items
      if (line.startsWith('- ')) {
        return chalk.dim('  •') + line.slice(1);
      }
      return line;
    })
    .filter(line => line !== '')
    .join('\n');
}

export async function listCommand(query?: string, options?: { search?: boolean }): Promise<void> {
  const cheatsheets = getCheatsheets();

  if (cheatsheets.length === 0) {
    console.log(chalk.yellow('No cheatsheets found.'));
    console.log(chalk.dim('Cheatsheets should be in: ' + CHEATSHEETS_DIR));
    return;
  }

  // Search mode
  if (options?.search && query) {
    searchCheatsheets(cheatsheets, query);
    return;
  }

  // Specific cheatsheet
  if (query) {
    // First try exact/partial name match
    const match = cheatsheets.find(c =>
      c.name.toLowerCase().includes(query.toLowerCase())
    );

    if (match) {
      const content = readFileSync(match.path, 'utf-8');
      console.log(formatCheatsheet(content));
      return;
    }

    // If no name match, search for the query as a command (with backticks)
    const commandPattern = new RegExp('`' + query.toLowerCase(), 'i');
    for (const sheet of cheatsheets) {
      const content = readFileSync(sheet.path, 'utf-8');
      if (commandPattern.test(content)) {
        // Found a cheatsheet containing the command
        const lines = content.split('\n');
        const matchingLines = lines.filter(line =>
          commandPattern.test(line.toLowerCase())
        );
        if (matchingLines.length > 0) {
          console.log(chalk.bold.cyan(`Commands matching "${query}":\n`));
          matchingLines.forEach(line => {
            const formatted = line.replace(/`([^`]+)`/g, chalk.green('$1'));
            console.log(chalk.dim('  •') + formatted.slice(1));
          });
          return;
        }
      }
    }

    console.log(chalk.yellow(`No cheatsheet found for "${query}"`));
    console.log('\nAvailable cheatsheets:');
    cheatsheets.forEach(c => {
      console.log(`  ${chalk.cyan(c.name)}`);
    });
    return;
  }

  // List all categories
  console.log(chalk.bold('Available cheatsheets:\n'));
  cheatsheets.forEach(c => {
    console.log(`  ${chalk.cyan(c.name)}`);
  });
  console.log(chalk.dim('\nUsage: bash-gpt list <name>'));
  console.log(chalk.dim('       bash-gpt list --search <query>'));
}

function searchCheatsheets(cheatsheets: CheatsheetEntry[], query: string): void {
  const results: { sheet: string; line: string; lineNum: number }[] = [];
  const queryLower = query.toLowerCase();

  for (const sheet of cheatsheets) {
    const content = readFileSync(sheet.path, 'utf-8');
    const lines = content.split('\n');

    lines.forEach((line, i) => {
      if (line.toLowerCase().includes(queryLower)) {
        results.push({
          sheet: sheet.name,
          line: line.trim(),
          lineNum: i + 1
        });
      }
    });
  }

  if (results.length === 0) {
    console.log(chalk.yellow(`No results found for "${query}"`));
    return;
  }

  console.log(chalk.bold(`Search results for "${query}":\n`));
  results.forEach(r => {
    console.log(`${chalk.cyan(r.sheet)}:${chalk.dim(r.lineNum)} ${r.line}`);
  });
}
