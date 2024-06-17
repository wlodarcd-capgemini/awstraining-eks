# Use the official Elasticsearch Docker image as the base image
FROM docker.elastic.co/elasticsearch/elasticsearch:8.7.1

VOLUME /usr/share/elasticsearch/data

# Expose the port that Elasticsearch listens on
EXPOSE 9200
EXPOSE 9300

# Switch to root
USER 0

# copy the configuration file into the container
COPY elasticsearch.yml /usr/share/elasticsearch/config

COPY run.sh .
RUN chmod +x run.sh

# Provide a helpful comment for usage instructions
# To build the Docker image:
# docker build -t my-elasticsearch-image .
#
# To run the Docker container:
# docker run -d --name my-elasticsearch-container -p 9200:9200 custom-es
#
# The Elasticsearch server will be accessible at http://localhost:9200
# The container's name is 'my-elasticsearch-container'
# You can customize these values as needed..

# Start Elasticsearch when the container starts
#ENTRYPOINT  [ "bin/elasticsearch" ]

# Go back to standard user, as elasticsearch cannot be ran as root
USER 1000

ENTRYPOINT [ "./run.sh" ]