FROM python:3.11-slim

WORKDIR /app

# Copy requirements first (for better caching)
COPY app/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Create directory for database volume
RUN mkdir -p /data

# Environment variable for database location
ENV DB_PATH=/data/tasks.db

# Expose port 8000
EXPOSE 8000

# Run with gunicorn (production-ready)
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--timeout", "60", "app:app"]