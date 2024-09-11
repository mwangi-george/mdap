# base image
FROM python:3.12-alpine

# create a working directory
RUN mkdir -p /mdap

# Set working directory
WORKDIR /mdap

# Copy the requirements file first (for caching purposes)
COPY ./requirements.txt ./requirements.txt

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy all other files after installing dependencies
COPY ./ ./

# Create a volume to persist data
VOLUME ["/mdap/data"]

# App start command
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
