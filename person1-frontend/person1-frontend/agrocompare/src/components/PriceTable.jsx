import { formatPrice, formatDate } from "../utils/prices.js";

export default function PriceTable({ records, onClear }) {
  if (records.length === 0) {
    return (
      <div className="empty" role="status">
        <p>No prices match your search and market filter.</p>
        <button type="button" onClick={onClear}>Clear search and filter</button>
      </div>
    );
  }

  return (
    <table className="price-table">
      <thead>
        <tr>
          <th scope="col">Product</th>
          <th scope="col">Market</th>
          <th scope="col">Location</th>
          <th scope="col">Price</th>
          <th scope="col">Unit</th>
          <th scope="col">Date (sample)</th>
        </tr>
      </thead>
      <tbody>
        {records.map((r) => (
          <tr key={r.id}>
            <th scope="row" data-label="Product">
              <span aria-hidden="true">{r.icon}</span> {r.productName}
            </th>
            <td data-label="Market">{r.marketName}</td>
            <td data-label="Location">{r.location}</td>
            <td data-label="Price" className="price">{formatPrice(r.price, r.currency)}</td>
            <td data-label="Unit">per {r.unit}</td>
            <td data-label="Date (sample)">{formatDate(r.date)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
