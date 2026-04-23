FROM python:3.11-slim

WORKDIR /api

RUN pip install mysql-connector-python pymongo fastapi uvicorn

COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--proxy-headers", "--host", "0.0.0.0", "--port", "8000"]
