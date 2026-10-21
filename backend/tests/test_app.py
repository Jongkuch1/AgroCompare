import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pytest

from app import create_app


@pytest.fixture
def client():
    app = create_app()
    app.config.update(TESTING=True)
    with app.test_client() as client:
        yield client


def test_health(client):
    res = client.get("/api/health")
    assert res.status_code == 200
    assert res.get_json() == {"status": "ok"}


def test_products_returns_five_or_more(client):
    res = client.get("/api/products")
    assert res.status_code == 200
    body = res.get_json()
    assert len(body) >= 5
    assert all({"id", "name", "icon"} <= set(p.keys()) for p in body)


def test_markets_returns_three_or_more(client):
    res = client.get("/api/markets")
    assert res.status_code == 200
    body = res.get_json()
    assert len(body) >= 3


def test_prices_returns_joined_shape(client):
    res = client.get("/api/prices")
    assert res.status_code == 200
    body = res.get_json()
    assert set(body.keys()) == {"products", "markets", "observations"}
    assert len(body["observations"]) > 0
    sample = body["observations"][0]
    assert {"id", "productId", "marketId", "price", "currency", "unit", "date"} <= set(sample.keys())


def test_prices_filters_by_product(client):
    res = client.get("/api/prices?product=maize")
    assert res.status_code == 200
    body = res.get_json()
    assert all(o["productId"] == "maize" for o in body["observations"])
    assert len(body["observations"]) > 0


def test_prices_filters_by_market(client):
    res = client.get("/api/prices?market=m-a")
    assert res.status_code == 200
    body = res.get_json()
    assert all(o["marketId"] == "m-a" for o in body["observations"])
