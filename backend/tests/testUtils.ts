import { supabase } from '../src/config/db';

export function randomPhone(): string {
  const subscriber = Math.floor(900000000 + Math.random() * 99999999);
  return `+998${subscriber}`;
}

export async function getAnyCategoryId(): Promise<number> {
  const { data, error } = await supabase.from('categories').select('id').limit(1).single();
  if (error || !data) {
    throw new Error('No seeded categories found — run seed.sql against the Supabase database first');
  }
  return (data as { id: number }).id;
}
