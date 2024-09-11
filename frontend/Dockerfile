# Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny:latest

# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# Create and set working directory
RUN mkdir -p /mdap
WORKDIR mdap

# Copy R dependencies first to cache them
COPY dependencies.R ./dependencies.R

# Install R packages
RUN Rscript /mdap/dependencies.R

# Copy the rest of the files
COPY dependencies_load.R ./dependencies_load.R
COPY global.R ./global.R
COPY server.R ./server.R
COPY ui.R ./ui.R
COPY data/ ./data/
COPY modules/ ./modules/
COPY ui/ ./ui/
COPY utils/ ./utils/

# run global file before starting the shiny app
RUN Rscript /mdap/global.R

# expose port
EXPOSE 3838

# run app on container start
CMD ["R", "-e", "shiny::runApp('/mdap', host = '0.0.0.0', port = 3838)"]
