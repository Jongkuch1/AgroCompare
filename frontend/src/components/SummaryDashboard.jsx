import { summarizePrices, formatPrice } from "../utils/prices.js";

export default function SummaryDashboard({ records, products, selectedProduct, selectedRecords, onSelectProduct }) {
  // All figures are derived from the dataset, never hardcoded.
  const productCount = new Set(records.map((r) => r.productId)).size;
  const marketCount = new Set(records.map((r) => r.marketId)).size;
  const summary = summarizePrices(selectedRecords);
  const currency = selectedRecords[0]?.currency ?? "";
  const unit = selectedRecords[0]?.unit ?? "";

  return (
    <section aria-labelledby="summary-heading" className="panel">
      <h2 id="summary-heading">Summary</h2>
      <dl className="stats">
        <div className="stat">
          <dt>Products listed</dt>
          <dd>{productCount}</dd>
        </div>
        <div className="stat">
          <dt>Markets represented</dt>
          <dd>{marketCount}</dd>
        </div>
        <div className="stat">
          <dt>Price observations</dt>
          <dd>{records.length}</dd>
        </div>
      </dl>

      <div className="field">
        <label htmlFor="summary-product">Show prices summary for</label>
        <select id="summary-product" value={selectedProduct.id} onChange={(e) => onSelectProduct(e.target.value)}>
          {products.map((p) => (
            <option key={p.id} value={p.id}>{p.name}</option>
          ))}
        </select>
      </div>

      {summary ? (
        <ul className="product-summary">
          <li>
            Lowest listed: <strong>{formatPrice(summary.lowest.price, currency)}/{unit}</strong> at {summary.lowest.marketName}
          </li>
          <li>
            Highest listed: <strong>{formatPrice(summary.highest.price, currency)}/{unit}</strong> at {summary.highest.marketName}
          </li>
          <li>
            Average of {summary.count} markets: <strong>{formatPrice(Number(summary.average.toFixed(2)), currency)}/{unit}</strong>
          </li>
        </ul>
      ) : (
        <p>No price observations for this product.</p>
      )}
    </section>
  );
}
