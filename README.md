# MongoDB Replica Set Docker Image

This repository provides a Docker image for MongoDB with replica set initialization and authentication. The image supports both `amd64` and `arm64` architectures and allows for dynamic configuration through environment variables.

## Features

- Replica set initialization on the first run
- User authentication with configurable database, user, and password
- Health checks for MongoDB availability

## Usage

### Running the Container

To run the container with default settings:

```bash
docker run -d \
  --name mongo-rs \
  -e MONGO_RS=rs0 \
  -e MONGO_AUTHDB=mydb \
  -e MONGO_USER=root \
  -e MONGO_PASSWORD=password \
  -p 27017:27017 \
  lucidfabrics/mongo-rs
```

### Running the Container with a Volume

To run the container with a volume to persist data:

```bash
docker run -d \
  --name mongo-rs \
  -e MONGO_RS=rs0 \
  -e MONGO_AUTHDB=mydb \
  -e MONGO_USER=root \
  -e MONGO_PASSWORD=password \
  -p 27017:27017 \
  -v mongo-data:/data/db \
  lucidfabrics/mongo-rs
```

### Environment Variables

- `MONGO_RS`: The name of the replica set (default: `rs0`)
- `MONGO_AUTHDB`: The database for authentication (default: `mydb`)
- `MONGO_USER`: The username for the root user (default: `root`)
- `MONGO_PASSWORD`: The password for the root user (default: `password`)

### Connection String

Use the following connection string to connect to the MongoDB instance:

```bash
mongodb://root:password@<your-ip>:27017/mydb?directConnection=true
```

## License

This project is licensed under the MIT License.
