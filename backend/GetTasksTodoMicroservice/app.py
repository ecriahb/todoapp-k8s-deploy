import pyodbc
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

connection_string = os.environ.get('CONNECTION_STRING')
app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

@app.get("/")
def ready():
    return "Incident Query API Ready."

@app.get("/tasks")
def get_incidents():
    incidents = []
    with pyodbc.connect(connection_string) as conn:
        cursor = conn.cursor()
        cursor.execute("""SELECT ID, Title, Description,
                          ISNULL(Severity,'MEDIUM'), ISNULL(Service,'AKS'),
                          ISNULL(Environment,'production') FROM Tasks ORDER BY ID DESC""")
        for row in cursor.fetchall():
            incidents.append({
                "ID": row[0], "Title": row[1], "Description": row[2],
                "Severity": row[3], "Service": row[4], "Environment": row[5]
            })
    return incidents

@app.get("/tasks/{task_id}")
def get_incident(task_id: int):
    with pyodbc.connect(connection_string) as conn:
        cursor = conn.cursor()
        cursor.execute("""SELECT ID, Title, Description,
                          ISNULL(Severity,'MEDIUM'), ISNULL(Service,'AKS'),
                          ISNULL(Environment,'production') FROM Tasks WHERE ID = ?""", task_id)
        row = cursor.fetchone()
        if row:
            return {"ID": row[0], "Title": row[1], "Description": row[2],
                    "Severity": row[3], "Service": row[4], "Environment": row[5]}
    return {"message": "Incident not found"}
