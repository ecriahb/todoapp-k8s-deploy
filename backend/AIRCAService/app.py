from flask import Flask, jsonify, request

app = Flask(__name__)

@app.get("/health")
def health():
    return jsonify({"status": "healthy", "service": "ai-rca"})

@app.post("/api/v1/rca")
def rca():
    payload = request.get_json(silent=True) or {}
    return jsonify({
        "service": "ai-rca",
        "status": "ready",
        "message": "RCA engine placeholder is deployed. Analysis logic will be added next.",
        "input": payload
    })
