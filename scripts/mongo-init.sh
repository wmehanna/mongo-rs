#!/bin/bash
mongo <<EOF
use $MONGO_AUTHDB
db.createUser({
  user: "$MONGO_USER",
  pwd: "$MONGO_PASSWORD",
  roles: [{ role: "readWrite", db: "$MONGO_AUTHDB" }]
})
EOF