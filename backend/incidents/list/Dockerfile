FROM python:3.9-slim-bookworm

WORKDIR /app
COPY . .

ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites from Debian 12 (Bookworm)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg \
 && rm -rf /var/lib/apt/lists/*

# Configure Microsoft repository for Debian 12.
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" \
    > /etc/apt/sources.list.d/mssql-release.list

# Install Microsoft ODBC Driver 17 and UnixODBC from compatible repositories.
RUN apt-get update \
 && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
    msodbcsql17 unixodbc unixodbc-dev \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
