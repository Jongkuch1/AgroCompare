export default function Filters({ query, onQueryChange, marketId, onMarketChange, markets, resultCount }) {
  return (
    <div className="filters">
      <div className="field">
        <label htmlFor="search">Search by product name</label>
        <input
          id="search"
          type="search"
          placeholder="e.g. maize"
          value={query}
          onChange={(e) => onQueryChange(e.target.value)}
        />
      </div>
      <div className="field">
        <label htmlFor="market-filter">Market</label>
        <select id="market-filter" value={marketId} onChange={(e) => onMarketChange(e.target.value)}>
          <option value="all">All markets</option>
          {markets.map((m) => (
            <option key={m.id} value={m.id}>{m.name}</option>
          ))}
        </select>
      </div>
      <p className="result-count" aria-live="polite">
        {resultCount} {resultCount === 1 ? "listing" : "listings"} shown
      </p>
    </div>
  );
}
