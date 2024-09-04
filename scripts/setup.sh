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

initialize_replica_set_and_user() {
    # Initialize MongoDB with replica set and create user
    if [ ! -d "/data/db/.mongodb" ]; then
        echo "Running mongod setup process"
        mongod --replSet $MONGO_RS --bind_ip_all --fork --logpath /var/log/mongodb.log

        echo "Waiting for mongod to start"
        sleep 10

        echo "Initiating replica set $MONGO_RS"
        mongosh --eval "
            rs.initiate({
                _id: '$MONGO_RS',
                members: [ { _id: 0, host: '127.0.0.1:27017' } ]
            });
        "

        echo "Waiting for replica set to initialize"
        sleep 20  # Additional wait time to ensure replica set is fully initialized

        # Create the user at the replica set level with access to all databases
        echo "Creating user at the replica set level in $MONGO_AUTHDB"
        mongosh --eval "
            db = db.getSiblingDB('$MONGO_AUTHDB');
            db.createUser({
                user: '$MONGO_USER',
                pwd: '$MONGO_PASSWORD',
                roles: [
                    { role: 'root', db: 'admin' },
                    { role: 'readWriteAnyDatabase', db: 'admin' },
                    { role: 'dbAdminAnyDatabase', db: 'admin' },
                    { role: 'clusterAdmin', db: 'admin' }
                ]
            });
        "

        touch /data/db/.mongodb
        mongod --shutdown
    fi
}

# Initialize the replica set and user if needed
initialize_replica_set_and_user

# Start MongoDB with authentication
echo "Starting mongod"
mongod --replSet $MONGO_RS --auth --keyFile /security/keyfile --bind_ip_all &

# Wait for MongoDB to start
sleep 10

# Monitor for new database requests while the container is running
while true; do
    # This loop can be used to handle dynamic database operations
    sleep 30 # Check every 30 seconds (adjust as needed)
done
