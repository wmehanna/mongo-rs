#!/bin/bash

# Set default values if not provided
MONGO_RS=${MONGO_RS:-rs0}
MONGO_AUTHDB=${MONGO_AUTHDB:-admin}
MONGO_USER=${MONGO_USER:-root}
MONGO_PASSWORD=${MONGO_PASSWORD:-password}

# Debug logs
echo "MONGO_RS: $MONGO_RS"
echo "MONGO_AUTHDB: $MONGO_AUTHDB"
echo "MONGO_USER: $MONGO_USER"
echo "MONGO_PASSWORD: $MONGO_PASSWORD"

# Initialize MongoDB with replica set and create user
if [ ! -d "/data/db/.mongodb" ]; then
    echo "Running mongod setup process"
    mongod --replSet $MONGO_RS --bind_ip_all --fork --logpath /var/log/mongodb.log --keyFile /security/keyfile

    echo "Waiting for mongod to start"
    sleep 10

    echo "Initiating replica set $MONGO_RS"
    mongosh <<SCRIPT
rs.initiate({
    _id: "$MONGO_RS",
    members: [ { _id: 0, host: "127.0.0.1:27017" } ]
});
SCRIPT

    echo "Creating user in $MONGO_AUTHDB"
    mongosh <<SCRIPT
use $MONGO_AUTHDB;
db.createUser({
    user: "$MONGO_USER",
    pwd: "$MONGO_PASSWORD",
    roles: [ { role: "root", db: "$MONGO_AUTHDB" } ]
});
SCRIPT

    touch /data/db/.mongodb
    mongod --shutdown
fi

echo "Starting mongod"
mongod --replSet $MONGO_RS --auth --keyFile /security/keyfile --bind_ip_all