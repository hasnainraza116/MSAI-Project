# ===== Base image =====
FROM python:3.10-slim

# Avoid bytecode & force unbuffered output (better logs)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create work directory
WORKDIR /app

# --- Copy only requirements first (better build caching) ---
COPY Backend/requirements.txt /tmp/backend-req.txt
COPY Frontend/requirements.txt /tmp/frontend-req.txt

# Install system deps if needed (uncomment if your libs require build tools)
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential \
#  && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install -r Backend/requirements.txt
RUN pip install -r Frontend/requirements.txt

# --- Copy the whole project ---
COPY . .

# Expose the ports you'll serve on
EXPOSE 8001 8501

# Healthcheck for FastAPI (adjust path if you have a health endpoint)
# Optional: comment out if you don't have /docs or /health
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD \
  curl -f http://localhost:8001/docs || exit 1

# Default CMD starts both FastAPI and Streamlit
# - FastAPI: uvicorn Backend.main:app -> 0.0.0.0:8001
# - Streamlit: Frontend/app.py -> 0.0.0.0:8501
CMD bash -c "\
  uvicorn Backend.main:app --host 0.0.0.0 --port 8001 & \
  streamlit run Frontend/app.py --server.port 8501 --server.address 0.0.0.0 \
"
