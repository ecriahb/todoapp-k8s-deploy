FROM python:3.9

# Set working directory
WORKDIR /app

# Copy files
COPY . .

# Install dependencies for ODBC
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    unixodbc \
    unixodbc-dev

# Add Microsoft repo key (new method)
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Add Microsoft SQL Server repository
RUN curl -sSL https://packages.microsoft.com/config/debian/10/prod.list -o /etc/apt/sources.list.d/mssql-release.list

# Install msodbcsql17
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Run FastAPI app
CMD ["python", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
