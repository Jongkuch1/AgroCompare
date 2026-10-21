# SokoWatch backend

A small Flask API that serves the AgroCompare price dataset (products, markets, and price observations) as JSON.

## Prerequisites

- Python 3.9+
- pip

## Installation

```bash
cd backend
python3 -m venv venv
source venv/bin/activate   # on Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Running locally

```bash
python app.py
```

The API listens on `http://localhost:5000`.

## Running tests

```bash
pytest
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check, returns `{"status": "ok"}` |
| GET | `/api/products` | List of products (`id`, `name`, `icon`) |
| GET | `/api/markets` | List of markets (`id`, `name`, `location`) |
| GET | `/api/prices` | Products, markets and observations, joined. Supports optional `?product=<id>` and `?market=<id>` query params to filter the observations returned. |

Example:

```bash
curl http://localhost:5000/api/prices
curl "http://localhost:5000/api/prices?product=maize"
```

## Data

Data lives in `data/prices.json` (same shape as the sample data the frontend used before the API existed). It's read fresh on every request, so you can edit it without restarting the server (in debug mode the server does auto-reload anyway).

## Disclaimer

Demo data for educational purposes. Prices are illustrative and are not live market prices.
