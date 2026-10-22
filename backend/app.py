import json
from pathlib import Path

from flask import Flask, jsonify, request
from flask_cors import CORS

DATA_PATH = Path(__file__).parent / "data" / "prices.json"


def load_data():
    with open(DATA_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def create_app():
    app = Flask(__name__)
    CORS(app)

    @app.get("/api/health")
    def health():
        return jsonify({"status": "ok"})

    @app.get("/api/products")
    def products():
        return jsonify(load_data()["products"])

    @app.get("/api/markets")
    def markets():
        return jsonify(load_data()["markets"])

    @app.get("/api/prices")
    def prices():
        data = load_data()
        product_id = request.args.get("product")
        market_id = request.args.get("market")

        observations = data["observations"]
        if product_id:
            observations = [o for o in observations if o["productId"] == product_id]
        if market_id:
            observations = [o for o in observations if o["marketId"] == market_id]

        return jsonify(
            {
                "products": data["products"],
                "markets": data["markets"],
                "observations": observations,
            }
        )

    return app


app = create_app()

if __name__ == "__main__":
    app.run(port=5000, debug=True)
