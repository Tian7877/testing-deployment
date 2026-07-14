import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'app'))

import pytest
from app import app as flask_app


@pytest.fixture
def client():
    flask_app.config['TESTING'] = True
    with flask_app.test_client() as client:
        yield client


def test_home(client):
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert "message" in data


def test_health(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert response.get_json()["status"] == "healthy"


def test_info(client):
    response = client.get('/api/info')
    assert response.status_code == 200
    assert "Docker" in response.get_json()["stack"]
