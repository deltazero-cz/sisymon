#!/usr/bin/env bash

resp.error() {
  cat <<EOF
Status: $1 $2
Content-type: application/json

{ "error": $1, "message": "$2" }
EOF
  exit 0
}
