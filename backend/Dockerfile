# base image
FROM python:3.12-alpine

# create a working directory
RUN mkdir -p /mdap

# Set working directory

WORKDIR mdap

# Copy all files into the set working directory
COPY ./ ./

# install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create a volume to persist data
VOLUME ["/mdap/data"]

# App start command
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]