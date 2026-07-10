import os
import sqlite3
from datetime import datetime
from flask import Flask

app = Flask(__name__)
DB_PATH = os.environ.get("DB_PATH", "/data/visits.db")

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS visits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            visited_at TEXT NOT NULL
        )
    """)
    return conn

@app.route("/")
def index():
    conn = get_connection()
    conn.execute("INSERT INTO visits (visited_at) VALUES (?)", (datetime.utcnow().isoformat(),))
    conn.commit()
    total = conn.execute("SELECT COUNT(*) FROM visits").fetchone()[0]
    ultimas = conn.execute("SELECT visited_at FROM visits ORDER BY id DESC LIMIT 5").fetchall()
    conn.close()

    filas = "".join(f"<li>{v[0]} UTC</li>" for v in ultimas)
    return f"""
    <html>
    <head><title>Caso Practico 2 - App Kubernetes</title>
    <style>
      body {{ font-family: Arial, sans-serif; background: #16213e; color: #eaeaea; text-align: center; padding-top: 60px; }}
      h1 {{ color: #f72585; }}
      .box {{ display: inline-block; border: 1px solid #f72585; border-radius: 10px; padding: 30px 50px; }}
    </style>
    </head>
    <body>
      <div class="box">
        <h1>Caso Practico 2 - Kubernetes</h1>
        <p>Aplicacion con almacenamiento persistente (PVC)</p>
        <p><strong>Total de visitas registradas: {total}</strong></p>
        <p>Ultimas visitas:</p>
        <ul style="list-style:none; padding:0;">{filas}</ul>
      </div>
    </body>
    </html>
    """

@app.route("/health")
def health():
    return {"status": "ok"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
