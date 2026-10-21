# SokoWatch

> Know the market price before you sell.

## African Context

Smallholder farmers across East Africa often don't know what their crops are selling for in nearby markets. Traders and middlemen usually have that information, so farmers can end up selling below the market price. SokoWatch puts crop prices from several markets in one place that anyone can check from a phone, so farmers can decide where and when to sell. ("Soko" is Swahili for "market".)

## Team Members

- Jongkuch Isaac Chol Anyar (@Jongkuch1) - Team Lead / DevOps
- Agertu Diriba Aliko (@AgertuDA) - Backend
- Betelhem Feleke Cheleno (@Betelhemf567) - Frontend, Tests and CI
- Beni Niyogisubizo (@be-niy) - Project Board and Documentation

## Project Overview

SokoWatch is a demonstration crop price tracker designed to help farmers and traders explore agricultural price information in one place. A Flask backend reads a sample JSON dataset, and a React frontend displays products, markets, prices, currencies, units, and observation dates.

Users can search by product name, filter by market, and compare a selected product across two markets. The interface also displays summary statistics for the selected product.

**Note:** Prices, market names, locations, and dates in this version are illustrative sample data, not verified current market information.

### Target Users

- Smallholder farmers deciding where to sell
- Small traders comparing market prices
- Agricultural extension officers advising farmers

### Core Features

- **View prices:** see prices for 5+ crops (maize, tomatoes, onions, teff, potatoes) from the backend API
- **Search and filter:** search by product name and filter the listings by market
- **Compare markets:** see the same crop across markets (Sample Markets A-D)
- **Last updated date:** each price shows when it was last updated

## Current Scope and Limitations

- The backend dataset is stored in `backend/data/prices.json`.
- The frontend uses bundled sample data if the API cannot be reached and displays a fallback notice.
- Currency conversion is not implemented. Compare prices only when their currencies and units match.
- Comparisons exclude transport costs, fees, and other selling expenses.
- The first version does not include login, a database, payments, or automatic price updates.
- Database storage, verified data sources, containerization, and cloud deployment are possible future improvements.

## Technology Stack

- **Frontend**: React 18, JavaScript, Vite, plain CSS
- **Backend**: Python, Flask, Flask-CORS
- **Data**: JSON file served by the backend API for now (database planned)
- **Other**: pytest (backend) and Node's built-in test runner (frontend) for tests, GitHub Actions for CI

## Getting Started

### Prerequisites
- [Node.js](https://nodejs.org/) 18 or newer (includes npm)
- Python 3.9+
- Git

### Installation and running

1. Clone the repository
```bash
git clone https://github.com/Jongkuch1/sokowatch.git
cd sokowatch
```

2. Start the backend (in one terminal)
```bash
cd backend
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python app.py       # serves the API at http://localhost:5000
```

3. Start the frontend (in another terminal)
```bash
cd frontend
npm install
npm run dev         # opens the app at http://localhost:5173, proxies /api to the backend
```

### Usage

Open the dev server URL in your browser to see the price listings table. Use the search box and market filter to narrow results, and the compare section to see a product's price side by side across two markets. If the backend isn't running, the app falls back to bundled sample data and shows a notice. See [frontend/README.md](frontend/README.md) and [backend/README.md](backend/README.md) for full details.

## Project Structure

```
sokowatch/
├── frontend/     # React/Vite app: price table, filters, compare, tests
├── backend/      # Flask API: serves products/markets/prices as JSON, pytest tests
├── .github/      # CODEOWNERS and CI workflow
├── README.md
└── .gitignore
```

## Links

- [Project Board](https://github.com/users/Jongkuch1/projects/7)

## Branch Protection

The `main` branch is protected so that no code reaches it unreviewed:
- Changes must go through a pull request, with at least 1 approving review.
- New commits dismiss earlier approvals, so reviewers always see the final code.
- The `frontend-tests` and `backend-tests` CI checks must pass, and branches must be up to date.
- All review conversations must be resolved before merging.
- The rules apply to administrators too, so nobody can bypass them.

Pull requests should include `Closes #N` so the matching issue closes automatically.

## License

MIT License
