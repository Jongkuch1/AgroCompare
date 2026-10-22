const API_BASE = import.meta.env.VITE_API_URL ?? "/api";

/** Fetch the joined price dataset from the backend. Throws on a non-OK response or network error. */
export async function fetchPrices() {
  const res = await fetch(`${API_BASE}/prices`);
  if (!res.ok) {
    throw new Error(`API responded with ${res.status}`);
  }
  return res.json();
}
