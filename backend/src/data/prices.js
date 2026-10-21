// Sample data for AgroCompare. ALL values are illustrative demonstration data.
// They are NOT real or live market prices, and the markets are used only as sample locations.
//
// To extend: add an entry to `products` or `markets`, then add rows to `observations`
// that reference them by id. Keep one observation per product + market.

export const DATA_NOTICE =
  "Demo data for educational purposes. Prices are illustrative and are not live market prices.";

export const products = [
  { id: "maize", name: "Maize", icon: "🌽" },
  { id: "tomatoes", name: "Tomatoes", icon: "🍅" },
  { id: "onions", name: "Onions", icon: "🧅" },
  { id: "teff", name: "Teff", icon: "🌾" },
  { id: "potatoes", name: "Potatoes", icon: "🥔" },
];

export const markets = [
  { id: "m-a", name: "Sample Market A", location: "Addis Ababa (sample location)" },
  { id: "m-b", name: "Sample Market B", location: "Bahir Dar (sample location)" },
  { id: "m-c", name: "Sample Market C", location: "Hawassa (sample location)" },
  { id: "m-d", name: "Sample Market D", location: "Adama (sample location)" },
];

export const observations = [
  // Maize (per kg)
  { id: "o1", productId: "maize", marketId: "m-a", price: 32, currency: "ETB", unit: "kg", date: "2026-10-12" },
  { id: "o2", productId: "maize", marketId: "m-b", price: 28, currency: "ETB", unit: "kg", date: "2026-10-12" },
  { id: "o3", productId: "maize", marketId: "m-c", price: 30, currency: "ETB", unit: "kg", date: "2026-10-13" },
  // Tomatoes (per kg)
  { id: "o4", productId: "tomatoes", marketId: "m-a", price: 55, currency: "ETB", unit: "kg", date: "2026-10-12" },
  { id: "o5", productId: "tomatoes", marketId: "m-c", price: 48, currency: "ETB", unit: "kg", date: "2026-10-13" },
  { id: "o6", productId: "tomatoes", marketId: "m-d", price: 52, currency: "ETB", unit: "kg", date: "2026-10-14" },
  // Onions (per kg)
  { id: "o7", productId: "onions", marketId: "m-b", price: 40, currency: "ETB", unit: "kg", date: "2026-10-12" },
  { id: "o8", productId: "onions", marketId: "m-d", price: 44, currency: "ETB", unit: "kg", date: "2026-10-14" },
  // Teff (per kg)
  { id: "o9", productId: "teff", marketId: "m-a", price: 98, currency: "ETB", unit: "kg", date: "2026-10-12" },
  { id: "o10", productId: "teff", marketId: "m-b", price: 92, currency: "ETB", unit: "kg", date: "2026-10-12" },
  { id: "o11", productId: "teff", marketId: "m-d", price: 95, currency: "ETB", unit: "kg", date: "2026-10-14" },
  // Potatoes (per kg)
  { id: "o12", productId: "potatoes", marketId: "m-a", price: 26, currency: "ETB", unit: "kg", date: "2026-10-13" },
  { id: "o13", productId: "potatoes", marketId: "m-c", price: 22, currency: "ETB", unit: "kg", date: "2026-10-13" },
];
