// Pure helper functions. They take data as arguments so they are easy to test
// and keep working if the data later comes from an API instead of a local file.

/** Join observations with their product and market into flat records for the UI. */
export function buildRecords(products, markets, observations) {
  return observations.map((obs) => {
    const product = products.find((p) => p.id === obs.productId);
    const market = markets.find((m) => m.id === obs.marketId);
    return {
      id: obs.id,
      productId: obs.productId,
      productName: product?.name ?? "Unknown product",
      icon: product?.icon ?? "",
      marketId: obs.marketId,
      marketName: market?.name ?? "Unknown market",
      location: market?.location ?? "",
      price: obs.price,
      currency: obs.currency,
      unit: obs.unit,
      date: obs.date,
    };
  });
}

/** Case-insensitive name search combined with an optional market filter ("all" = no filter). */
export function filterRecords(records, query, marketId) {
  const text = query.trim().toLowerCase();
  return records.filter(
    (r) =>
      (marketId === "all" || r.marketId === marketId) &&
      (text === "" || r.productName.toLowerCase().includes(text))
  );
}

/** Lowest, highest and average listed price for a set of records of one product. */
export function summarizePrices(records) {
  if (records.length === 0) return null;
  const sorted = [...records].sort((a, b) => a.price - b.price);
  const total = records.reduce((sum, r) => sum + r.price, 0);
  return {
    count: records.length,
    lowest: sorted[0],
    highest: sorted[sorted.length - 1],
    average: total / records.length,
  };
}

/** Compare two records. Returns which has the lower listed price (null when equal). */
export function compareRecords(a, b) {
  const difference = Math.abs(a.price - b.price);
  const lower = a.price === b.price ? null : a.price < b.price ? a : b;
  const higher = lower === null ? null : lower === a ? b : a;
  const percent = higher ? (difference / higher.price) * 100 : 0;
  return { lower, difference, percent };
}

export function formatPrice(price, currency) {
  return `${Number.isInteger(price) ? price : price.toFixed(2)} ${currency}`;
}

export function formatDate(isoDate) {
  return new Date(isoDate).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
    timeZone: "UTC",
  });
}
