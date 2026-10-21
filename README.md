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

SokoWatch is a simple web application that shows current prices for common crops across different markets in East Africa. A backend API reads price data and returns it as JSON, and a lightweight web page displays the results in a table.

Users can filter prices by crop or by market, and compare the same crop across markets to see where it sells for the most. The first version uses a sample data file. Later versions will move to a database and be containerized and deployed to the cloud.

**Note:** the prices in this version are sample data for demonstration, not real market prices.

### Target Users

- Smallholder farmers deciding where to sell
- Small traders comparing market prices
- Agricultural extension officers advising farmers

### Core Features

- **View prices:** see prices for 5+ crops (maize, beans, tomatoes, rice, potatoes) from a data source
- **Filter by crop or market:** narrow the table to the crop or market you care about
- **Compare markets:** see the same crop across markets (Nairobi, Kampala, Kigali)
- **Last updated date:** each price shows when it was last updated

## Technology Stack

- **Backend**: Python / Flask
- **Frontend**: HTML, CSS and vanilla JavaScript
- **Database**: JSON file for now (PostgreSQL planned)
- **Other**: pytest for testing, GitHub Actions for CI

## Getting Started

### Prerequisites
- Python 3.9+
- Git

### Installation

1. Clone the repository
```bash
git clone https://github.com/Jongkuch1/sokowatch.git
cd sokowatch
```

2. Setup instructions will be added once the backend is merged.

3. Run the application
```bash
# command will be added with the backend
```

### Usage

Usage examples will be added with the first working feature.

## Project Structure

```
sokowatch/
├── backend/      # API and tests (planned)
├── frontend/     # price table page (planned)
├── data/         # prices.json (planned)
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
- The `backend-tests` CI check must pass, and branches must be up to date.
- All review conversations must be resolved before merging.
- The rules apply to administrators too, so nobody can bypass them.

Pull requests should include `Closes #N` so the matching issue closes automatically.

## License

MIT License
