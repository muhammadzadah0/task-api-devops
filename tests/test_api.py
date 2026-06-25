import requests
import os

BASE_URL = os.getenv("BASE_URL", "http://localhost:8000")

def test_health():
    r = requests.get(f"{BASE_URL}/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"

def test_create_task():
    r = requests.post(f"{BASE_URL}/api/tasks", json={"title": "Test"})
    assert r.status_code == 201
    assert r.json()["title"] == "Test"

def test_list_tasks():
    r = requests.get(f"{BASE_URL}/api/tasks")
    assert r.status_code == 200
    assert isinstance(r.json(), list)

def test_create_no_title():
    r = requests.post(f"{BASE_URL}/api/tasks", json={})
    assert r.status_code == 400

def test_metrics():
    r = requests.get(f"{BASE_URL}/metrics")
    assert r.status_code == 200
    assert "flask_http_request_total" in r.text
