import { useState } from "react";
import { compareRecords, formatPrice, formatDate } from "../utils/prices.js";

function ComparisonCard({ record, isLower }) {
  return (
    <article className={`compare-card${isLower ? " is-lower" : ""}`}>
      {isLower && <p className="badge">Lower listed price</p>}
      <h3>{record.marketName}</h3>
      <p className="muted">{record.location}</p>
      <p className="big-price">{formatPrice(record.price, record.currency)}</p>
      <p>{record.productName}, per {record.unit}</p>
      <p className="muted">Sample date: {formatDate(record.date)}</p>
    </article>
  );
}

export default function CompareSection({ products, selectedProduct, onSelectProduct, records }) {
  const [chosenA, setChosenA] = useState("");
  const [chosenB, setChosenB] = useState("");

  // Fall back to the first two available markets when a choice is empty or not valid for this product.
  const recordA = records.find((r) => r.marketId === chosenA) ?? records[0];
  const recordB = records.find((r) => r.marketId === chosenB) ?? records.find((r) => r !== recordA);

  const canCompare = recordA && recordB;
  const result = canCompare ? compareRecords(recordA, recordB) : null;

  return (
    <section aria-labelledby="compare-heading" className="panel">
      <h2 id="compare-heading">Compare a product across two markets</h2>

      <div className="filters">
        <div className="field">
          <label htmlFor="compare-product">Product</label>
          <select id="compare-product" value={selectedProduct.id} onChange={(e) => onSelectProduct(e.target.value)}>
            {products.map((p) => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>
        </div>
        <div className="field">
          <label htmlFor="compare-a">First market</label>
          <select id="compare-a" value={recordA?.marketId ?? ""} onChange={(e) => setChosenA(e.target.value)}>
            {records.map((r) => (
              <option key={r.marketId} value={r.marketId}>{r.marketName}</option>
            ))}
          </select>
        </div>
        <div className="field">
          <label htmlFor="compare-b">Second market</label>
          <select id="compare-b" value={recordB?.marketId ?? ""} onChange={(e) => setChosenB(e.target.value)}>
            {records.map((r) => (
              <option key={r.marketId} value={r.marketId}>{r.marketName}</option>
            ))}
          </select>
        </div>
      </div>

      {!canCompare ? (
        <p role="status">At least two markets with prices are needed to compare {selectedProduct.name}.</p>
      ) : recordA.marketId === recordB.marketId ? (
        <p role="status">Choose two different markets to compare.</p>
      ) : (
        <>
          <div className="compare-grid">
            <ComparisonCard record={recordA} isLower={result.lower === recordA} />
            <ComparisonCard record={recordB} isLower={result.lower === recordB} />
          </div>
          <p className="compare-result" role="status">
            {result.lower
              ? `${result.lower.marketName} lists ${selectedProduct.name} ${formatPrice(result.difference, recordA.currency)} per ${recordA.unit} lower (${result.percent.toFixed(1)}%).`
              : `Both markets list the same price for ${selectedProduct.name}.`}
          </p>
          <p className="muted">
            A lower listed price does not always mean the better market to sell or buy. Transport,
            fees and other costs are not included.
          </p>
        </>
      )}
    </section>
  );
}
