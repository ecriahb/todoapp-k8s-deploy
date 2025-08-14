# # Use the official Python image as the base image
# FROM python:3.9

# # Set the working directory in the container
# WORKDIR /app

# # Copy the application files into the container
# COPY . .

# # Install necessary packages
# RUN apt-get update && apt-get install -y unixodbc unixodbc-dev
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
# RUN apt-get update
# RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17

# RUN pip install -r requirements.txt

# # Start the FastAPI application
# #CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
# CMD ["python", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
# #CMD uvicorn app:app --host 0.0.0.0 --port 8000


# ---------- Stage 1: Build environment ----------
FROM python:3.9-slim AS builder

WORKDIR /app

# Install build dependencies & ODBC packages for compiling Python deps
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    gnupg \
    unixodbc \
    unixodbc-dev

# Add Microsoft repo key (new method)
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Add Microsoft SQL Server repository
RUN curl -sSL https://packages.microsoft.com/config/debian/10/prod.list \
    -o /etc/apt/sources.list.d/mssql-release.list

# Install msodbcsql17
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Copy only requirements first (for Docker caching)
COPY requirements.txt .

# Install Python dependencies into a local directory (not global site-packages)
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ---------- Stage 2: Final runtime image ----------
FROM python:3.9-slim

WORKDIR /app

# Install only runtime ODBC libs
RUN apt-get update && apt-get install -y \
    unixodbc \
    msodbcsql17 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from builder
COPY --from=builder /install /usr/local

# Copy app source
COPY . .

# Run FastAPI app
CMD ["python", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
