import pyodbc
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

connection_string = os.environ.get('CONNECTION_STRING')
app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

@app.get("/")
def ready():
    return "Resolve-Incident API Ready."

@app.delete("/tasks/{task_id}")
def resolve_incident(task_id: int):
    with pyodbc.connect(connection_string) as conn:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Tasks WHERE ID = ?", task_id)
        conn.commit()
    return {"message": "Incident resolved", "id": task_id}
