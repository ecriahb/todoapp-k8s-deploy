import pyodbc
from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import os

connection_string = os.environ.get('CONNECTION_STRING')
app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

class Incident(BaseModel):
    title: str
    description: str
    severity: str = "MEDIUM"
    service: str = "AKS"
    environment: str = "production"

@app.get("/")
def ready():
    return "Create-Incident API Ready."

@app.post("/tasks")
def create_incident(incident: Incident):
    with pyodbc.connect(connection_string) as conn:
        cursor = conn.cursor()
        cursor.execute("""
            IF OBJECT_ID('Tasks', 'U') IS NULL
            CREATE TABLE Tasks (
                ID int NOT NULL PRIMARY KEY IDENTITY,
                Title varchar(255),
                Description text,
                Severity varchar(20) DEFAULT 'MEDIUM',
                Service varchar(100) DEFAULT 'AKS',
                Environment varchar(50) DEFAULT 'production'
            )
        """)
        cursor.execute("""INSERT INTO Tasks (Title, Description, Severity, Service, Environment)
                          VALUES (?, ?, ?, ?, ?)""",
                       incident.title, incident.description, incident.severity,
                       incident.service, incident.environment)
        conn.commit()
    return incident

if __name__ == "__main__":
    ready()
