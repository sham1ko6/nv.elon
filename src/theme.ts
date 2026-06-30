// Ravoq design tokens — warm terracotta palette + editorial type
export const c = {
  bg: '#F6EFE4',
  ink: '#241C15',
  accent: '#C2613B',
  accentSoft: '#fbeee4',
  muted: '#9b8a73',
  line: '#E7DCC9',
  card: '#FFFDF9',
  gold: '#E0A33E',
  green: '#2f9e5c',
  greenSoft: '#e9f4ec',
  greenLine: '#bfe0c9',
  dark: '#15110d',
};

export const serif = "'Spectral', Georgia, serif";
export const sans = "'Hanken Grotesk', system-ui, sans-serif";

// money formatter: 125000 -> "125 000"
export const fmt = (n: number): string =>
  n.toLocaleString('en-US').replace(/,/g, ' ');

export const price = (n: number, cur: string = '$'): string =>
  cur === '$' ? `$${fmt(n)}` : `${fmt(n)} ${cur}`;
