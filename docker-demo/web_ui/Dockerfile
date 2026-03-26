FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir flask requests

COPY app.py templates/ /app/

EXPOSE 8080
CMD ["python", "app.py"]