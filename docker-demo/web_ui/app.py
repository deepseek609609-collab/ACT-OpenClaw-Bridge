from flask import Flask, render_template, request, jsonify
import requests
import os

app = Flask(__name__)
GATEWAY_URL = os.environ.get("ACT_GATEWAY_URL", "http://localhost:9000")

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/api/call", methods=["POST"])
def call_tool():
    data = request.json
    intent = data.get("intent", "weather.get_current")
    params = data.get("params", {})
    try:
        resp = requests.post(f"{GATEWAY_URL}/act/dispatch", json={
            "intent": intent,
            "params": params
        }, timeout=5)
        return jsonify(resp.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)