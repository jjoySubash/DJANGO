# Use the official lightweight Python image
FROM python:3.12-slim

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /app

# Install system dependencies (for psycopg2 and similar)
RUN apt-get update \
  && apt-get install -y build-essential libpq-dev curl \
  && apt-get clean

# Upgrade pip
RUN pip install --upgrade pip

# Copy dependency file first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install -r requirements.txt

# Copy the rest of your project
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose port for the application
EXPOSE 5000

# Start the app using gunicorn
CMD bash -c "gunicorn auth_project.wsgi:application --bind 127.0.0.1:${PORT:-5000}"
