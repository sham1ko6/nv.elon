import { query } from '../src/config/db';

export function randomPhone(): string {
  const subscriber = Math.floor(900000000 + Math.random() * 99999999);
  return `+998${subscriber}`;
}

export async function getAnyCategoryId(): Promise<number> {
  const [category] = await query<{ id: number }>('SELECT id FROM categories LIMIT 1');
  if (!category) {
    throw new Error('No seeded categories found — run db:seed against the test database first');
  }
  return category.id;
}
