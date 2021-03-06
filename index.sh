#!/usr/bin/env bash

## load config
source <(grep "=" config.default.ini)
[[ -f config.ini ]] && source <(grep "=" config.ini)

## check dependencies
type -P jq &>/dev/null || resp.error 500 "Command \`jq\` Not Installed"

## import functions
for f in ./lib/*.sh; do
  source "$f"
done

## check auth
[[ "$HTTP_AUTHORIZATION" != "Bearer ${auth_bearer}" ]] && resp.error 403 "Unauthorized access"

## response
echo "Content-type: application/json"
echo

jq ".hostname = \"$(hostname)\"
  | .uptime = $(read.uptime)
  | .load = $(read.loadavg)
  | .memory = $(read.memory)
  | .raid = $(read.raid "${raid[@]}")
  | .storage = $(read.storage "${storage[@]}")
  | .services = $(read.services "${services[@]}")
  | .custom = $(read.custom "${custom[@]}")
" -c <<<'{}'
exit 0
