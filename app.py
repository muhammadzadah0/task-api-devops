import os
from flask import Flask, jsonify, request
import psycopg2
from psycopg2.extras import RealDictCursor
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

metrics = PrometheusMetrics(app)
metrics.info('app_info', 'Task API Application info', version='1.0.0')

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432"),
    "dbname": os.getenv("DB_NAME", "tasksdb"),
    "user": os.getenv("DB_USER", "appuser"),
    "password": os.getenv("DB_PASSWORD", "changeme"),
}

def get_conn():
    return psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)

def init_db():
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                id SERIAL PRIMARY KEY,
                title TEXT NOT NULL,
                done BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMPTZ DEFAULT NOW()
            );
        """)
    conn.commit()
    conn.close()

init_db()

@app.route("/health")
@metrics.do_not_track()
def health():
    try:
        conn = get_conn()
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
        conn.close()
        return jsonify({"status": "ok"}), 200
    except Exception as e:
        return jsonify({"status": "error", "detail": str(e)}), 503

@app.route("/api/tasks", methods=["GET"])
def list_tasks():
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM tasks ORDER BY id;")
        rows = cur.fetchall()
    conn.close()
    return jsonify(rows), 200

@app.route("/api/tasks", methods=["POST"])
def create_task():
    data = request.get_json(force=True) or {}
    title = data.get("title")
    if not title:
        return jsonify({"error": "title is required"}), 400
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute("INSERT INTO tasks (title) VALUES (%s) RETURNING *;", (title,))
        row = cur.fetchone()
    conn.commit()
    conn.close()
    return jsonify(row), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
