# Use an official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.9-slim

# Allow statements and log messages to be sent straight to the logs
# without being buffered.
ENV PYTHONUNBUFFERED True

# Set the working directory in the container.
WORKDIR /app

# Copy the requirements file into the container.
COPY requirements.txt .

# Install the dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container.
COPY . .

# Set the command to run the application using Gunicorn.
# Gunicorn is a production-ready WSGI server for Python.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
