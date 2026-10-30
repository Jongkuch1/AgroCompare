import { useEffect, useMemo, useState } from "react";
import { products as fallbackProducts, markets as fallbackMarkets, observations as fallbackObservations } from "./data/prices.js";
import { buildRecords, filterRecords } from "./utils/prices.js";
import { fetchPrices } from "./api.js";
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
  const [selectedProductId, setSelectedProductId] = useState(null);
  const [dataset, setDataset] = useState(null);
  const [status, setStatus] = useState("loading"); // "loading" | "live" | "offline"

  useEffect(() => {
    let cancelled = false;

    fetchPrices()
      .then((data) => {
        if (cancelled) return;
        setDataset(data);
        setStatus("live");
        setSelectedProductId((current) => current ?? data.products[0]?.id ?? null);
      })
      .catch(() => {
        if (cancelled) return;
        setDataset({ products: fallbackProducts, markets: fallbackMarkets, observations: fallbackObservations });
        setStatus("offline");
        setSelectedProductId((current) => current ?? fallbackProducts[0]?.id ?? null);
      });

    return () => {
      cancelled = true;
    };
  }, []);

  const products = useMemo(() => dataset?.products ?? [], [dataset]);
  const markets = useMemo(() => dataset?.markets ?? [], [dataset]);
  const observations = useMemo(() => dataset?.observations ?? [], [dataset]);

  const records = useMemo(() => buildRecords(products, markets, observations), [products, markets, observations]);
  const visibleRecords = useMemo(() => filterRecords(records, query, marketId), [records, query, marketId]);
  const selectedProduct = products.find((p) => p.id === selectedProductId);
  const selectedRecords = records.filter((r) => r.productId === selectedProductId);

  if (status === "loading") {
    return (
      <>
        <Navbar />
        <main>
          <p className="panel">Loading prices…</p>
        </main>
        <Footer />
      </>
    );
  }

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

        {status === "offline" && (
          <div className="notice" role="alert">
            <strong>Could not reach the prices API.</strong> Showing bundled sample data instead.
          </div>
        )}

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
