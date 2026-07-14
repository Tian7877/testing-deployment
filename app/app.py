from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)


@app.route('/')
def home():
    return jsonify({
        "message": "Halo dari DevOps Learning Project!",
        "hostname": socket.gethostname(),
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "environment": os.getenv("APP_ENV", "development")
    })


@app.route('/health')
def health():
    """Endpoint ini dipakai oleh Docker HEALTHCHECK & Kubernetes liveness/readiness probe"""
    return jsonify({"status": "healthy"}), 200


@app.route('/api/info')
def info():
    return jsonify({
        "app": "devops-learning-project",
        "stack": ["Docker", "Kubernetes", "Terraform", "Jenkins"]
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
