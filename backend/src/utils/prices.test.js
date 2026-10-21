// Minimal checks for the helper logic. Run with: npm test
import assert from "node:assert/strict";
import { products, markets, observations } from "../data/prices.js";
import { buildRecords, filterRecords, summarizePrices, compareRecords, formatDate } from "./prices.js";

const records = buildRecords(products, markets, observations);

assert.equal(records.length, observations.length);
assert.ok(records.every((r) => r.productName !== "Unknown product" && r.marketName !== "Unknown market"));

assert.deepEqual([...new Set(filterRecords(records, "maize", "all").map((r) => r.productName))], ["Maize"]);
assert.equal(filterRecords(records, "  TOMA ", "all").length, 3);
assert.equal(filterRecords(records, "xyz", "all").length, 0);
assert.ok(filterRecords(records, "", "m-b").every((r) => r.marketId === "m-b"));
assert.equal(filterRecords(records, "teff", "m-c").length, 0);

const maize = summarizePrices(filterRecords(records, "maize", "all"));
assert.equal(maize.lowest.marketId, "m-b");
assert.equal(maize.highest.marketId, "m-a");
assert.equal(maize.average, (32 + 28 + 30) / 3);
assert.equal(summarizePrices([]), null);

const [a, b] = records.filter((r) => r.productId === "maize");
const cmp = compareRecords(a, b);
assert.equal(cmp.lower.marketId, "m-b");
assert.equal(cmp.difference, 4);
assert.equal(compareRecords(a, { ...a }).lower, null);

assert.equal(formatDate("2026-10-12"), "12 Oct 2026");

console.log("All helper tests passed.");
