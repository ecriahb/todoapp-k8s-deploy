FROM python:3.9-slim

WORKDIR /app
COPY . .

ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites, add Microsoft signing key without apt-key, add MS repo and install ODBC driver
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg unixodbc unixodbc-dev lsb-release \
 && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg \
 && curl -fsSL https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
 && apt-get update \
 && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql17 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
