# AgroCompare

**Compare agricultural prices. Make smarter market decisions.**

## Project overview

AgroCompare is a small web application that lets users view and compare the listed prices of agricultural products across different markets. It is designed with an African context in mind and uses Ethiopian birr (ETB) in its sample data.

This is an initial university project version, not a production platform.

## Problem statement

Farmers and buyers may find it hard to access and compare agricultural prices across local markets. Without that information, farmers may struggle to find suitable markets and buyers may struggle to compare prices. AgroCompare shows price information in one place so it is easier to view and compare.

## Target users

- Farmers who want to compare selling prices.
- Buyers who want to compare the prices of agricultural products.
- Agricultural traders who want to view prices across markets.
- Anyone interested in agricultural market information.

## Main features

- **Price listings:** table of products with market, location, price, currency, unit and date (cards on mobile).
- **Search and filter:** search by product name and filter by market. Both work on the dataset, and an empty result shows a message with a "Clear search and filter" button.
- **Compare across markets:** pick a product and two markets to see both prices side by side, which one is lower, and the difference. A note explains that transport and other costs are not included.
- **Data transparency:** a visible demo-data notice, plus a date shown on every price.
- **Summary dashboard:** number of products, markets and observations, plus the lowest, highest and average price for the selected product. All values are calculated from the dataset.

## Technology stack

React 18, JavaScript, plain CSS, Vite. Data is fetched from the Flask API in [`../backend`](../backend), with the bundled local file (`src/data/prices.js`) used as an offline fallback if the API can't be reached.

## Project structure

```
agrocompare/
├── index.html                  # HTML entry point
├── package.json                # Dependencies and scripts
├── vite.config.js              # Vite configuration (React plugin, dev proxy for /api)
├── README.md
└── src/
    ├── main.jsx                # React entry point
    ├── App.jsx                 # Page layout, data fetching, and shared state (search, market filter, selected product)
    ├── api.js                  # fetchPrices() — calls the backend's GET /api/prices
    ├── styles.css               # All styling
    ├── data/
    │   └── prices.js           # Offline fallback data, same shape as the API response
    ├── utils/
    │   ├── prices.js           # Joining, filtering, summary, comparison and formatting functions
    │   └── prices.test.js      # Small checks for the functions above
    └── components/
        ├── Navbar.jsx          # Name and tagline
        ├── DemoNotice.jsx      # Demo-data disclaimer
        ├── SummaryDashboard.jsx
        ├── Filters.jsx         # Search box and market select
        ├── PriceTable.jsx      # Listing table and empty state
        ├── CompareSection.jsx  # Two-market comparison
        └── Footer.jsx
```

## Prerequisites

- [Node.js](https://nodejs.org/) 18 or newer (includes npm).
- Git (optional, for team collaboration).

## Installation

```bash
cd agrocompare
npm install
```

## Running locally

Start the backend first (see [`../backend/README.md`](../backend/README.md)), then:

```bash
npm run dev       # start the development server (usually http://localhost:5173)
npm run build     # create a production build in dist/
npm run preview   # serve the production build locally
npm test          # run the helper-function checks
```

In dev, requests to `/api/*` are proxied to `http://localhost:5000` (configured in `vite.config.js`). To point at a different backend URL, set `VITE_API_URL` (e.g. in a `.env` file) to a full base URL such as `http://localhost:5000/api`.

If the backend isn't running or the request fails, the app falls back to the bundled sample data in `src/data/prices.js` and shows a small "could not reach the prices API" notice, so the UI still works for a quick demo.

## How the sample dataset works

`src/data/prices.js` has three lists:

- `products`: `id`, `name`, `icon` (emoji used as a simple visual).
- `markets`: `id`, `name`, `location`.
- `observations`: `id`, `productId`, `marketId`, `price`, `currency`, `unit`, `date`.

`buildRecords` in `src/utils/prices.js` joins them into flat records that the components display. To add data, add a product or market, then add observations that reference their ids. Keep one observation per product and market, and use the same unit for a product across markets so comparisons are fair. Markets with no observation for a product simply do not appear for it.

## Disclaimer

**Demo data for educational purposes. Prices are illustrative and are not live market prices.** Market names, locations, prices and dates are sample values, not verified market reports or real submissions.

## Current limitations and possible future improvements

Limitations:

- Data is static and local; nothing updates automatically.
- One observation per product and market, so there is no price history.
- Currency and unit are displayed but not converted, so compare only like with like.
- Comparison covers two markets at a time and ignores transport and other costs.
- Automated checks cover the helper functions only, not the interface.
- Not yet checked with a screen reader.

Possible improvements:

- A backend and database, with the data layer in `src/data/` replaced by API calls.
- Price history and charts.
- More products, markets and local languages.
- Real data sources, with proper verification.
- Component-level tests.

## Team

| Name | GitHub profile |
|------|----------------|
| _[Member name]_ | _[GitHub profile link]_ |
| _[Member name]_ | _[GitHub profile link]_ |
| _[Member name]_ | _[GitHub profile link]_ |
