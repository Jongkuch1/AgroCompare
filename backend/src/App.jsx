import { useMemo, useState } from "react";
import { products, markets, observations } from "./data/prices.js";
import { buildRecords, filterRecords } from "./utils/prices.js";
import Navbar from "./components/Navbar.jsx";
import DemoNotice from "./components/DemoNotice.jsx";
import SummaryDashboard from "./components/SummaryDashboard.jsx";
import Filters from "./components/Filters.jsx";
import PriceTable from "./components/PriceTable.jsx";
import CompareSection from "./components/CompareSection.jsx";
import Footer from "./components/Footer.jsx";

export default function App() {
  const [query, setQuery] = useState("");
  const [marketId, setMarketId] = useState("all");
  const [selectedProductId, setSelectedProductId] = useState(products[0].id);

  const records = useMemo(() => buildRecords(products, markets, observations), []);
  const visibleRecords = useMemo(() => filterRecords(records, query, marketId), [records, query, marketId]);
  const selectedProduct = products.find((p) => p.id === selectedProductId);
  const selectedRecords = records.filter((r) => r.productId === selectedProductId);

  return (
    <>
      <Navbar />
      <main>
        <section className="hero">
          <h1>See what your crop is listed for in each market</h1>
          <p>
            AgroCompare puts agricultural prices from different markets side by side, so farmers,
            buyers and traders can compare before they decide.
          </p>
        </section>

        <DemoNotice />

        <SummaryDashboard
          records={records}
          products={products}
          selectedProduct={selectedProduct}
          selectedRecords={selectedRecords}
          onSelectProduct={setSelectedProductId}
        />

        <section aria-labelledby="listing-heading" className="panel">
          <h2 id="listing-heading">Price listings</h2>
          <Filters
            query={query}
            onQueryChange={setQuery}
            marketId={marketId}
            onMarketChange={setMarketId}
            markets={markets}
            resultCount={visibleRecords.length}
          />
          <PriceTable
            records={visibleRecords}
            onClear={() => {
              setQuery("");
              setMarketId("all");
            }}
          />
        </section>

        <CompareSection
          products={products}
          selectedProduct={selectedProduct}
          onSelectProduct={setSelectedProductId}
          records={selectedRecords}
        />
      </main>
      <Footer />
    </>
  );
}
