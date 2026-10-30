# AgroCompare

**Compare agricultural prices. Make smarter market decisions.**

## African Context

Smallholder farmers across East Africa often don't know what their crops are selling for in nearby markets. Traders and middlemen usually have that information, so farmers can end up selling below the market price. AgroCompare puts crop prices from several markets in one place that anyone can check from a phone, so farmers can decide where and when to sell.

## Team Members

- Jongkuch Isaac Chol Anyar ([@Jongkuch1](https://github.com/Jongkuch1)) - Team Lead / DevOps
- Agertu Diriba Aliko ([@AgertuDA](https://github.com/AgertuDA)) - Backend
- Betelhem Feleke Cheleno ([@Betelhemf567](https://github.com/Betelhemf567)) - Frontend, Tests and CI
- Beni Niyogisubizo ([@be-niy](https://github.com/be-niy)) - Project Board and Documentation

## Project Overview

AgroCompare is a simple web application that shows current prices for common crops across different markets in East Africa. A Flask backend API reads price data and returns it as JSON, and a React frontend displays the results in a table.

Users can filter prices by crop or by market, and compare the same crop across markets to see where it sells for the most. The first version uses a sample JSON data file served by the API. Later versions will move to a real database and be containerized and deployed to the cloud.

**Note:** the prices in this version are sample data for demonstration, not real market prices.

## Target Users

- Smallholder farmers deciding where to sell
- Small traders comparing market prices
- Agricultural extension officers advising farmers

## Core Features

- **View prices:** see prices for 5+ crops (maize, tomatoes, onions, teff, potatoes) from the backend API
- **Filter by crop or market:** narrow the table to the crop or market you care about
- **Compare markets:** see the same crop across markets (Sample Markets A-D)
- **Last updated date:** each price shows when it was last updated

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
git clone https://github.com/Jongkuch1/AgroCompare.git
cd AgroCompare
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

### Running the tests

```bash
cd backend && pytest        # backend tests
cd frontend && npm test     # frontend tests
```

### Usage

Open the dev server URL in your browser to see the price listings table. Use the search box and market filter to narrow results, and the compare section to see a product's price side by side across two markets. If the backend isn't running, the app falls back to bundled sample data and shows a notice.

You can also call the API directly while the backend is running:

```bash
curl http://localhost:5000/api/prices
curl "http://localhost:5000/api/prices?product=maize"
curl "http://localhost:5000/api/prices?market=m-a"
```

`/api/prices` returns JSON with three lists: `products`, `markets` and `observations` (each observation has a product, a market, a price, a currency, a unit and a date). The `product` and `market` query parameters filter the observations.

See [frontend/README.md](frontend/README.md) and [backend/README.md](backend/README.md) for full details.

## Project Structure

```
AgroCompare/
├── frontend/     # React/Vite app: price table, filters, compare, tests
├── backend/      # Flask API: serves products/markets/prices as JSON, pytest tests
├── .github/      # CODEOWNERS and CI workflow
├── README.md
└── .gitignore
```

## Links

- [GitHub Repository](https://github.com/Jongkuch1/AgroCompare)
- [Project Board](https://github.com/users/Jongkuch1/projects/7) (Kanban: Backlog, In Progress, Done)
- [Issues](https://github.com/Jongkuch1/AgroCompare/issues)
- [Pull Requests](https://github.com/Jongkuch1/AgroCompare/pulls?q=is%3Apr)
- [Backend README](backend/README.md)
- [Frontend README](frontend/README.md)
- [Team Participation Sheet](https://docs.google.com/spreadsheets/d/1apJFWX5-BIjBpPVhniaPmolSvizBKX4rTitMLN0pWt4/edit?gid=0#gid=0)

## Branch Protection

The `main` branch is protected so that no code reaches it unreviewed:
- Changes must go through a pull request, with at least 1 approving review.
- New commits dismiss earlier approvals, so reviewers always see the final code.
- The `frontend-tests` and `backend-tests` CI checks must pass, and branches must be up to date.
- All review conversations must be resolved before merging.
- The rules apply to administrators too, so nobody can bypass them.

Pull requests should include `Closes #N` so the matching issue closes automatically.

## License

## Run with Docker Compose

### Prerequisites

- Git
- Docker Engine with Docker Compose, or Docker Desktop
- On Windows with WSL, enable Docker Desktop integration for your Ubuntu distribution.
- Ports 8080 and 5000 must be available.

Docker installs the application dependencies inside the images, so local Python and Node.js installations are not required for this method.

### Build and start

From the repository root, where `docker-compose.yml` is located:

```bash
docker compose up --build -d
```

The first build downloads the base images and installs dependencies. The frontend starts after the backend health check passes.

Open:

- Frontend: http://localhost:8080
- Backend health check: http://localhost:5000/api/health
- Price API: http://localhost:5000/api/prices

The frontend serves the built React application through Nginx. Requests to `/api/` are forwarded to the backend service over the shared Compose network.

### Check service status

Run from the repository root:

```bash
docker compose ps
curl -f http://localhost:5000/api/health
curl -f http://localhost:8080/api/health
```

Both health requests should return `{"status":"ok"}`. The second request checks that the frontend can forward requests to the backend.

### View logs

```bash
docker compose logs --tail=100
docker compose logs -f backend frontend
```

Press Ctrl+C to stop following logs. The containers continue running.

### Stop and rebuild

Stop and remove the application's containers and Compose network:

```bash
docker compose down
```

Rebuild and start again after changing application code or dependencies:

```bash
docker compose up --build -d
```

The current application uses sample JSON data packaged in the backend image. It has no database or persistent data volume. Changes to the source dataset require rebuilding the backend image.

### Troubleshooting

- **Docker command unavailable in WSL:** enable the Ubuntu distribution under Docker Desktop → Settings → Resources → WSL Integration, then reopen the terminal.
- **Cannot connect to the Docker daemon:** start Docker Desktop or the Docker Engine and check `docker info`.
- **Port already allocated:** stop the application or container already using port 5000 or 8080, then retry.
- **Backend unhealthy or frontend fails to start:** inspect `docker compose logs backend` and check `docker compose ps`.
- **Page loads but API requests fail:** check both health URLs above and inspect `docker compose logs frontend backend`.
- **Build fails:** read the first build error, check network access, and retry after correcting the cause.

## Continuous Integration

The workflow is defined in `.github/workflows/ci.yml`.

It runs on:

- Pushes to every branch except `main`.
- Pull requests targeting `main`.

The workflow contains three jobs:

| Job | Checks |
| --- | --- |
| `frontend-tests` | Sets up Node.js 18, installs dependencies, runs frontend linting, runs tests, and builds the frontend |
| `backend-tests` | Sets up Python 3.11, installs backend dependencies and Flake8, runs linting, and runs pytest |
| `docker-build` | Builds the backend image from the root Dockerfile and the frontend image from `frontend/Dockerfile` |

Each job fails if one of its commands fails. The Docker job builds images for validation; the current workflow does not publish them to a registry or deploy the application.

### Check a workflow run

1. Open the repository's **Actions** tab.
2. Select the **CI** workflow.
3. Open the run for your branch or pull request.
4. Select a job and expand the failed step to inspect its logs.
5. Correct the problem, commit the fix, and push to the same branch to trigger another run.

Pull requests display their CI results in the checks section. Required checks and review approvals must be satisfied before merging under the repository's branch protection rules.
